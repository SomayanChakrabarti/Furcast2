import SwiftUI

// MARK: - City Page View (Swipeable Container)
struct CityPageView: View {
    @State private var cities = City.sampleCities
    @State private var selectedCityIndex = 0
    
    // Create WeatherView instances to access their background colors
    private var weatherViews: [WeatherView] {
        cities.map { WeatherView(city: $0) }
    }
    
    private var currentBackgroundColor: Color {
        guard selectedCityIndex < weatherViews.count else { return .clear }
        return weatherViews[selectedCityIndex].gifBackgroundColor
        
//        let colors = [Color.red, Color.blue, Color.green, Color.yellow]
//        return colors[selectedCityIndex]
    }
    
    var body: some View {
        TabView(selection: $selectedCityIndex) {
            ForEach(Array(cities.enumerated()), id: \.element.id) { index, city in
                WeatherView(city: city)
                    .tag(index)
            }
        }
        .background(currentBackgroundColor)
        .animation(.easeInOut(duration: 0.3), value: currentBackgroundColor)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            // Custom page indicator
            PageIndicator(
                numberOfPages: cities.count,
                currentPage: selectedCityIndex
            )
            .padding(.bottom)
        }
    }
}

// MARK: - Custom Page Indicator
struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.2))
        )
    }
}

// MARK: - Background Blur Extension
extension View {
    func backdrop() -> some View {
        self.background(.ultraThinMaterial.opacity(0.3))
    }
}

#Preview {
    CityPageView()
} 
