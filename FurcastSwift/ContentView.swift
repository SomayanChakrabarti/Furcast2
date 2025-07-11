//
//  ContentView.swift
//  FurcastSwift
//
//  Created by Somayan Chakrabarti on 6/10/25.
//

import SwiftUI
import CoreData
import WebKit

// MARK: - Data Models
struct WeatherData {
    let location: String
    let currentTemp: Int
    let condition: String
    let highTemp: Int
    let lowTemp: Int
    let description: String
    let hourlyForecast: [HourlyWeather]
    let dailyForecast: [DailyWeather]
}

struct HourlyWeather {
    let time: String
    let temperature: Int
    let condition: WeatherCondition
    let precipitationChance: Int?
}

struct DailyWeather {
    let day: String
    let condition: WeatherCondition
    let lowTemp: Int
    let highTemp: Int
    let precipitationChance: Int?
}

enum WeatherCondition {
    case sunny, cloudy, rainy, partlyCloudy
    
    var systemImage: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        }
    }
}

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

// MARK: - GIF Background Color Extraction
extension GIFView {
    static func extractBackgroundColor(from gifName: String) -> Color {
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

// MARK: - Color Contrast Utilities
extension Color {
    /// Returns black or white text color for optimal contrast against this background color
    func contrastingTextColor() -> Color {
        // Convert to UIColor to access RGB components
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate relative luminance using WCAG formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        // Return white text for dark backgrounds, black text for light backgrounds
        return luminance > 0.5 ? Color(uiColor: UIColor(displayP3Red: 60/255, green: 60/255, blue: 60/255, alpha: 1)) : .white
    }
}

struct ContentView: View {
    private let gifBackgroundColor = GIFView.extractBackgroundColor(from: "toiletpaperdance")
    private var textColor: Color { gifBackgroundColor.contrastingTextColor() }
    
    let weatherData = WeatherData(
        location: "Joniec",
        currentTemp: 12,
        condition: "Rain",
        highTemp: 19,
        lowTemp: 11,
        description: "Cloudy conditions expected around 8AM. Wind gusts are up to 15 mph.",
        hourlyForecast: [
            HourlyWeather(time: "Now", temperature: 12, condition: .rainy, precipitationChance: nil),
            HourlyWeather(time: "6AM", temperature: 12, condition: .rainy, precipitationChance: 35),
            HourlyWeather(time: "7AM", temperature: 13, condition: .rainy, precipitationChance: 30),
            HourlyWeather(time: "8AM", temperature: 14, condition: .cloudy, precipitationChance: nil),
            HourlyWeather(time: "9AM", temperature: 14, condition: .cloudy, precipitationChance: nil),
            HourlyWeather(time: "10AM", temperature: 15, condition: .cloudy, precipitationChance: nil)
        ],
        dailyForecast: [
            DailyWeather(day: "Today", condition: .rainy, lowTemp: 11, highTemp: 19, precipitationChance: 70),
            DailyWeather(day: "Thu", condition: .sunny, lowTemp: 8, highTemp: 19, precipitationChance: nil),
            DailyWeather(day: "Fri", condition: .cloudy, lowTemp: 8, highTemp: 20, precipitationChance: nil),
            DailyWeather(day: "Sat", condition: .sunny, lowTemp: 10, highTemp: 23, precipitationChance: nil)
        ]
    )
    
    var body: some View {
        ZStack {
            // Background gradient using GIF's background color
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    gifBackgroundColor.opacity(0.8),
//                    gifBackgroundColor.opacity(0.6),
//                    gifBackgroundColor.opacity(0.4)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Current Weather Section
                    CurrentWeatherView(weatherData: weatherData, textColor: textColor)
                        .padding(.top, 8)
                    
                    GIFView(gifName: "toiletpaperdance")
                        .frame(width: 256, height: 216)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(textColor.opacity(0.1))
                        )
//                        .shadow(color: textColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    HourlyForecastView(hourlyData: weatherData.hourlyForecast, textColor: textColor)
                    
                    // Daily Forecast
                    DailyForecastView(dailyData: weatherData.dailyForecast, textColor: textColor)
                        .padding(.bottom, 30)

                }
            }
        }
        .background(gifBackgroundColor)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Current Weather View
struct CurrentWeatherView: View {
    let weatherData: WeatherData
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(weatherData.location)
                .font(.title)
                .fontWeight(.thin)
                .foregroundColor(textColor)
            
            Text("\(weatherData.currentTemp)°")
                .font(.system(size: 64, weight: .regular))
                .foregroundColor(textColor)
            
            VStack(spacing: 4) {
                Text(weatherData.condition)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(textColor.opacity(0.7))
                
                Text("H:\(weatherData.highTemp)° L:\(weatherData.lowTemp)°")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
            }
        }
    }
}

// MARK: - Hourly Forecast View
struct HourlyForecastView: View {
    let hourlyData: [HourlyWeather]
    let textColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cloudy conditions expected around 8AM. Wind gusts are up to 15 mph.")
                .font(.callout)
                .foregroundColor(textColor.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.horizontal, 12)
            
            Divider()
                .background(textColor.opacity(0.5))
                .frame(height: 1)
                .padding(.horizontal, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(hourlyData.enumerated()), id: \.offset) { index, hour in
                        HourlyItemView(hourly: hour, textColor: textColor)
                    }
                }
                .padding(.leading, 12)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(textColor.opacity(0.1))
        )
        .padding(.horizontal, 20)
    }
}

struct HourlyItemView: View {
    let hourly: HourlyWeather
    let textColor: Color
    
    var body: some View {
        VStack {
            Text(hourly.time)
                .font(.caption)
                .foregroundColor(textColor)
                .fontWeight(.medium)
            
            Spacer(minLength: 4)
            
            if let precipChance = hourly.precipitationChance {
                VStack(spacing: 2) {
                    Image(systemName: hourly.condition.systemImage)
                        .font(.title2)
                        .foregroundColor(textColor)
                    
                    Text("\(precipChance)%")
                        .font(.caption2)
                        .foregroundColor(.cyan)
                        .fontWeight(.medium)
                }
            } else {
                Image(systemName: hourly.condition.systemImage)
                    .font(.title2)
                    .foregroundColor(textColor)
            }
            
            Spacer(minLength: 4)
            
            Text("\(hourly.temperature)°")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(textColor)
        }
        .frame(width: 44)
    }
}

// MARK: - Daily Forecast View
struct DailyForecastView: View {
    let dailyData: [DailyWeather]
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(Array(dailyData.enumerated()), id: \.offset) { index, day in
                    DailyItemView(daily: day, textColor: textColor)
                    
                    if index < dailyData.count - 1 {
                        Divider()
                            .background(textColor.opacity(0.2))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(textColor.opacity(0.1))
            )
            .padding(.horizontal, 20)
        }
    }
}

struct DailyItemView: View {
    let daily: DailyWeather
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Text(daily.day)
                .font(.title3)
                .foregroundColor(textColor)
                .frame(width: 64, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: daily.condition.systemImage)
                    .font(.title2)
                    .foregroundColor(textColor)
                
                if let precipChance = daily.precipitationChance {
                    Text("\(precipChance)%")
                        .font(.caption2)
                        .foregroundColor(.cyan)
                        .fontWeight(.medium)
                        .frame(width: 30)
                } else {
                    Spacer()
                        .frame(width: 30)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("L: \(daily.lowTemp)°")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                    .frame(width: 64, alignment: .leading)
                
                Text("H: \(daily.highTemp)°")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                    .frame(width: 64, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Background Blur Extension
extension View {
    func backdrop() -> some View {
        self.background(.ultraThinMaterial.opacity(0.3))
    }
}

#Preview {
    ContentView()
}
