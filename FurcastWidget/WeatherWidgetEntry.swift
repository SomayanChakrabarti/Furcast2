import WidgetKit

struct WeatherWidgetEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let currentTemp: Int  // in Celsius
    let highTemp: Int     // in Celsius
    let lowTemp: Int      // in Celsius
    let condition: String
    let weatherIcon: String
    let isCelsius: Bool

    var displayCurrentTemp: Int {
        isCelsius ? currentTemp : Int(round(Double(currentTemp) * 9.0 / 5.0 + 32.0))
    }

    var displayHighTemp: Int {
        isCelsius ? highTemp : Int(round(Double(highTemp) * 9.0 / 5.0 + 32.0))
    }

    var displayLowTemp: Int {
        isCelsius ? lowTemp : Int(round(Double(lowTemp) * 9.0 / 5.0 + 32.0))
    }

    var tempUnit: String {
        isCelsius ? "°C" : "°F"
    }
}
