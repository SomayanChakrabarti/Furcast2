import Foundation
import WeatherKit
import CoreLocation

// MARK: - Weather Service
@MainActor
class WeatherService: ObservableObject {
    static let shared = WeatherService()
    private let service = WeatherKit.WeatherService()
    private var cache: [String: (data: WeatherData, timestamp: Date)] = [:]
    private let cacheExpiration: TimeInterval = 600 // 10 minutes

    private init() {}

    /// Fetch weather data for a given location
    func fetchWeather(for latitude: Double, longitude: Double) async throws -> WeatherData {
        let cacheKey = "\(latitude),\(longitude)"

        // Check cache
        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheExpiration {
            return cached.data
        }

        let location = CLLocation(latitude: latitude, longitude: longitude)

        let weather = try await service.weather(for: location)

        // Convert WeatherKit data to our WeatherData model
        let currentTemp = Int(weather.currentWeather.temperature.value)
        let condition = mapCondition(weather.currentWeather.condition)

        // Get daily forecast for high/low temps
        let today = weather.dailyForecast.first
        let highTemp = today.map { Int($0.highTemperature.value) } ?? currentTemp
        let lowTemp = today.map { Int($0.lowTemperature.value) } ?? currentTemp

        // Map hourly forecast (24 hours)
        let hourlyForecast = weather.hourlyForecast.prefix(24).enumerated().map { index, hour in
            HourlyWeather(
                time: index == 0 ? "Now" : formatHour(hour.date),
                temperature: Int(hour.temperature.value),
                condition: mapWeatherCondition(hour.condition),
                precipitationChance: hour.precipitationChance > 0 ? roundToNearest5(hour.precipitationChance * 100) : nil
            )
        }

        // Map daily forecast (WeatherKit provides up to 10 days)
        let dailyForecast = weather.dailyForecast.enumerated().map { index, day in
            DailyWeather(
                day: index == 0 ? "Today" : formatDay(day.date),
                condition: mapWeatherCondition(day.condition),
                lowTemp: Int(day.lowTemperature.value),
                highTemp: Int(day.highTemperature.value),
                precipitationChance: day.precipitationChance > 0 ? roundToNearest5(day.precipitationChance * 100) : nil
            )
        }

        // Get location name using reverse geocoding
        let locationName = try await getLocationName(for: location)

        let weatherData = WeatherData(
            location: locationName,
            currentTemp: currentTemp,
            condition: condition,
            highTemp: highTemp,
            lowTemp: lowTemp,
            description: generateDescription(from: weather),
            hourlyForecast: Array(hourlyForecast),
            dailyForecast: Array(dailyForecast)
        )

        // Cache the result
        cache[cacheKey] = (data: weatherData, timestamp: Date())

        return weatherData
    }

    // MARK: - Helper Methods

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

    private func mapWeatherCondition(_ condition: WeatherKit.WeatherCondition) -> FurcastSwift.WeatherCondition {
        switch condition {
        case .clear, .mostlyClear:
            return .sunny
        case .cloudy, .mostlyCloudy:
            return .cloudy
        case .partlyCloudy:
            return .partlyCloudy
        case .rain, .drizzle, .heavyRain:
            return .rainy
        default:
            return .cloudy
        }
    }

    private func formatHour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date)
    }

    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func generateDescription(from weather: Weather) -> String {
        let condition = mapCondition(weather.currentWeather.condition)
        let wind = Int(weather.currentWeather.wind.speed.value)
        return "\(condition) conditions throughout the day. Wind gusts up to \(wind) mph."
    }

    private func getLocationName(for location: CLLocation) async throws -> String {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        if let placemark = placemarks.first {
            return placemark.locality ?? placemark.name ?? "Unknown Location"
        }

        return "Unknown Location"
    }

    private func roundToNearest5(_ value: Double) -> Int {
        return Int((value / 5.0).rounded() * 5.0)
    }
}
