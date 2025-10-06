import WidgetKit
import WeatherKit
import CoreLocation

struct WeatherProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.MayansParty.FurcastSwift")
    private let weatherService = WeatherKit.WeatherService()

    func placeholder(in context: Context) -> WeatherWidgetEntry {
        WeatherWidgetEntry(
            date: Date(),
            cityName: "Loading...",
            currentTemp: 20,
            highTemp: 25,
            lowTemp: 15,
            condition: "Clear",
            weatherIcon: "sun.max.fill",
            isCelsius: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> Void) {
        Task {
            let entry = await fetchWeatherEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> Void) {
        Task {
            let entry = await fetchWeatherEntry()

            // Update every 30 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchWeatherEntry() async -> WeatherWidgetEntry {
        let isCelsius = defaults?.bool(forKey: "isCelsius") ?? true

        // Get user's current location from shared defaults
        let latitude = defaults?.double(forKey: "currentLocationLat") ?? 42.3601
        let longitude = defaults?.double(forKey: "currentLocationLon") ?? -71.0589
        let location = CLLocation(latitude: latitude, longitude: longitude)

        do {
            let weather = try await weatherService.weather(for: location)

            let currentTemp = Int(weather.currentWeather.temperature.value)
            let highTemp = weather.dailyForecast.first.map { Int($0.highTemperature.value) } ?? currentTemp
            let lowTemp = weather.dailyForecast.first.map { Int($0.lowTemperature.value) } ?? currentTemp

            let condition = mapCondition(weather.currentWeather.condition)
            let icon = mapWeatherIcon(weather.currentWeather.condition)

            // Get city name
            let cityName = try? await getLocationName(for: location)

            return WeatherWidgetEntry(
                date: Date(),
                cityName: cityName ?? "Current Location",
                currentTemp: currentTemp,
                highTemp: highTemp,
                lowTemp: lowTemp,
                condition: condition,
                weatherIcon: icon,
                isCelsius: isCelsius
            )
        } catch {
            print("Widget weather fetch error: \(error)")
            return WeatherWidgetEntry(
                date: Date(),
                cityName: "Unavailable",
                currentTemp: 20,
                highTemp: 25,
                lowTemp: 15,
                condition: "Clear",
                weatherIcon: "sun.max.fill",
                isCelsius: isCelsius
            )
        }
    }

    private func mapCondition(_ condition: WeatherKit.WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear:
            return "Clear"
        case .cloudy, .mostlyCloudy, .partlyCloudy:
            return "Cloudy"
        case .rain, .drizzle, .heavyRain:
            return "Rain"
        case .snow, .sleet, .flurries, .heavySnow:
            return "Snow"
        case .thunderstorms:
            return "Storms"
        default:
            return "Cloudy"
        }
    }

    private func mapWeatherIcon(_ condition: WeatherKit.WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear:
            return "sun.max.fill"
        case .cloudy, .mostlyCloudy:
            return "cloud.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .rain, .drizzle, .heavyRain:
            return "cloud.rain.fill"
        default:
            return "cloud.fill"
        }
    }

    private func getLocationName(for location: CLLocation) async throws -> String {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        if let placemark = placemarks.first {
            return placemark.locality ?? placemark.name ?? "Unknown"
        }

        return "Unknown"
    }
}
