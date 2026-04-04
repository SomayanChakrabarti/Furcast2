import WidgetKit

struct WidgetHourlyItem {
    let time: String        // e.g. "6PM", "Now"
    let temperature: Int    // Celsius
    let symbolName: String  // SF Symbol name
    let precipChance: Int?
}

struct WeatherWidgetEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let currentTemp: Int  // in Celsius
    let highTemp: Int     // in Celsius
    let lowTemp: Int      // in Celsius
    let condition: String
    let weatherIcon: String
    let isCelsius: Bool
    let hourlyForecast: [WidgetHourlyItem]
    let showingHourly: Bool

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

    var timeAgoString: String {
        let minutes = Int(Date().timeIntervalSince(date) / 60)
        if minutes < 1 { return "Just now" }
        return "\(minutes)min ago"
    }

    func displayHourlyTemp(_ item: WidgetHourlyItem) -> Int {
        isCelsius ? item.temperature : Int(Double(item.temperature) * 9/5 + 32)
    }
}
