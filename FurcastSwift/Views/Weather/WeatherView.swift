import SwiftUI

// MARK: - Weather View (Main Display for Each City)
struct WeatherView: View {
    let city: City
    @State private var weatherData: WeatherData?
    
    // Dynamic theming based on city's GIF
    private var gifName: String { city.gifName ?? "toiletpaperdance" }
    var gifBackgroundColor: Color { GIFView.extractBackgroundColor(from: gifName) }
    private var textColor: Color { gifBackgroundColor.contrastingTextColor() }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Current Weather Section
                    if let weather = weatherData {
                        CurrentWeatherView(weatherData: weather, textColor: textColor)
                            .padding(.top, 8)
                        
                        // City-specific GIF
                        GIFView(gifName: gifName)
                            .frame(width: 256, height: 216)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(textColor.opacity(0.1))
                            )
                        
                        HourlyForecastView(hourlyData: weather.hourlyForecast, textColor: textColor)
                        
                        DailyForecastView(dailyData: weather.dailyForecast, textColor: textColor)
                            .padding(.bottom, 30)
                    } else {
                        // Loading state
                        ProgressView("Loading weather for \(city.name)...")
                            .foregroundColor(textColor)
                            .padding(.top, 100)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadWeatherData()
        }
    }
    
    private func loadWeatherData() {
        // For now, use sample data - later this will call WeatherKit
        // TODO: Replace with actual WeatherKit integration
        weatherData = WeatherData.sampleData
    }
}

#Preview {
    WeatherView(city: City.sampleCities[0])
} 