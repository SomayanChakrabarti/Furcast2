import SwiftUI
import WebKit

// MARK: - GIF View using WebKit
struct GIFView: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.layer.cornerRadius = 12
        webView.clipsToBounds = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let gifURL = Bundle.main.url(forResource: gifName, withExtension: "gif"),
              let gifData = try? Data(contentsOf: gifURL) else {
            return
        }
        
        uiView.load(gifData, mimeType: "image/gif", characterEncodingName: "", baseURL: URL(fileURLWithPath: ""))
    }
}

// MARK: - GIF Background Color Extraction with Caching
extension GIFView {
    private static var colorCache: [String: Color] = [:]
    private static let cacheQueue = DispatchQueue(label: "com.furcast.gifColorCache")

    static func extractBackgroundColor(from gifName: String) -> Color {
        // Check cache first
        return cacheQueue.sync {
            if let cachedColor = colorCache[gifName] {
                return cachedColor
            }

            // Extract color if not cached
            let extractedColor = performColorExtraction(from: gifName)
            colorCache[gifName] = extractedColor
            return extractedColor
        }
    }

    private static func performColorExtraction(from gifName: String) -> Color {
        guard let gifURL = Bundle.main.url(forResource: gifName, withExtension: "gif"),
              let gifData = try? Data(contentsOf: gifURL),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil),
              let firstFrame = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return Color.clear
        }

        let width = firstFrame.width
        let height = firstFrame.height

        // Sample corner pixels (top-left, top-right, bottom-left, bottom-right)
        let corners = [(0, 0), (width-1, 0), (0, height-1), (width-1, height-1)]

        guard let context = CGContext(data: nil, width: width, height: height,
                                    bitsPerComponent: 8, bytesPerRow: width * 4,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let pixelData = context.data?.bindMemory(to: UInt8.self, capacity: width * height * 4) else {
            return Color.clear
        }

        context.draw(firstFrame, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Get the most common corner color
        var colorCounts: [UInt32: Int] = [:]
        for (x, y) in corners {
            let pixelIndex = (y * width + x) * 4
            let r = pixelData[pixelIndex]
            let g = pixelData[pixelIndex + 1]
            let b = pixelData[pixelIndex + 2]
            let colorKey = (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
            colorCounts[colorKey, default: 0] += 1
        }

        guard let dominantColor = colorCounts.max(by: { $0.value < $1.value })?.key else {
            return Color.clear
        }

        let r = Double((dominantColor >> 16) & 0xFF) / 255.0
        let g = Double((dominantColor >> 8) & 0xFF) / 255.0
        let b = Double(dominantColor & 0xFF) / 255.0

        return Color(red: r, green: g, blue: b)
    }
} 