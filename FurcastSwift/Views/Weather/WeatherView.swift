import SwiftUI

// MARK: - Weather View (Main Display for Each City)
struct WeatherView: View {
    let city: City
    @State private var weatherData: WeatherData?
    @State private var backgroundColor: Color
    @ObservedObject var temperatureSettings = TemperatureSettings.shared

    // Dynamic theming based on city's GIF
    private var gifName: String { city.gifName ?? "toiletpaperdance" }
    var gifBackgroundColor: Color { backgroundColor }
    private var textColor: Color { backgroundColor.contrastingTextColor() }

    init(city: City) {
        self.city = city
        let gifName = city.gifName ?? "toiletpaperdance"
        // Initialize with cached or extracted color synchronously
        _backgroundColor = State(initialValue: GIFView.extractBackgroundColor(from: gifName))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Current Weather Section
                    if let weather = weatherData {
                        CurrentWeatherView(weatherData: weather, textColor: textColor)
                            .padding(.top, 8)

                        // City-specific GIF
                        ZStack {
                            GIFView(gifName: gifName)
                                .frame(width: 256, height: 216)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(textColor.opacity(0.1))
                                )

                            // Invisible overlay to capture taps
                            Color.clear
                                .frame(width: 256, height: 216)
                                .contentShape(Rectangle())
                        }

                        HourlyForecastView(hourlyData: weather.hourlyForecast, textColor: textColor, description: weather.description)

                        DailyForecastView(dailyData: weather.dailyForecast, textColor: textColor)
                            .padding(.bottom, 30)
                    } else {
                        // Loading state
                        ProgressView("Loading weather for \(city.name)...")
                            .foregroundColor(textColor)
                            .padding(.top, 100)
                    }
                }
                .contentShape(Rectangle())
            }
            .contentShape(Rectangle())
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    temperatureSettings.toggle()
                }
        )
        .preferredColorScheme(.dark)
        .onAppear {
            loadWeatherData()
        }
    }

    private func loadWeatherData() {
        Task {
            do {
                let weather = try await WeatherService.shared.fetchWeather(
                    for: city.latitude,
                    longitude: city.longitude
                )
                weatherData = weather
            } catch {
                print("Error loading weather for \(city.name): \(error.localizedDescription)")
                // Fallback to sample data on error
                weatherData = WeatherData(
                    location: city.name,
                    currentTemp: 12,
                    condition: "Rain",
                    highTemp: 19,
                    lowTemp: 11,
                    description: "Sample data - WeatherKit setup required. Wind gusts up to 15 mph.",
                    hourlyForecast: WeatherData.sampleData.hourlyForecast,
                    dailyForecast: WeatherData.sampleData.dailyForecast
                )
            }
        }
    }
}

#Preview {
    WeatherView(city: City.sampleCities[0])
} 