import Foundation
import SwiftUI

// MARK: - Weather Data Models
struct WeatherData {
    let location: String
    let currentTemp: Int // Stored in Celsius
    let condition: String
    let highTemp: Int // Stored in Celsius
    let lowTemp: Int // Stored in Celsius
    let description: String
    let hourlyForecast: [HourlyWeather]
    let dailyForecast: [DailyWeather]

    // Helper methods to get converted temperatures
    func getCurrentTemp(in unit: TemperatureUnit) -> Int {
        unit.convert(fromCelsius: currentTemp)
    }

    func getHighTemp(in unit: TemperatureUnit) -> Int {
        unit.convert(fromCelsius: highTemp)
    }

    func getLowTemp(in unit: TemperatureUnit) -> Int {
        unit.convert(fromCelsius: lowTemp)
    }
}

struct HourlyWeather {
    let time: String
    let temperature: Int // Stored in Celsius
    let condition: WeatherCondition
    let precipitationChance: Int?

    func getTemperature(in unit: TemperatureUnit) -> Int {
        unit.convert(fromCelsius: temperature)
    }
}

struct DailyWeather {
    let day: String
    let condition: WeatherCondition
    let lowTemp: Int // Stored in Celsius
    let highTemp: Int // Stored in Celsius
    let precipitationChance: Int?

    func getLowTemp(in unit: TemperatureUnit) -> Int {
        unit.convert(fromCelsius: lowTemp)
    }

    func getHighTemp(in unit: TemperatureUnit) -> Int {
        unit.convert(fromCelsius: highTemp)
    }
}

enum WeatherCondition {
    case sunny
    case cloudy
    case rainy
    case partlyCloudy

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

// MARK: - Sample Data
extension WeatherData {
    static let sampleData = WeatherData(
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
} 