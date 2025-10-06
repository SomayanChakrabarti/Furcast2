import Foundation

// MARK: - Temperature Unit
enum TemperatureUnit: String, Codable {
    case celsius
    case fahrenheit

    var symbol: String {
        switch self {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }

    /// Convert temperature from Celsius to the target unit
    func convert(fromCelsius temp: Int) -> Int {
        switch self {
        case .celsius:
            return temp
        case .fahrenheit:
            return Int(round(Double(temp) * 9.0 / 5.0 + 32.0))
        }
    }

    /// Toggle between units
    func toggled() -> TemperatureUnit {
        switch self {
        case .celsius:
            return .fahrenheit
        case .fahrenheit:
            return .celsius
        }
    }
}

// MARK: - Temperature Settings Manager
class TemperatureSettings: ObservableObject {
    static let shared = TemperatureSettings()

    @Published var unit: TemperatureUnit {
        didSet {
            UserDefaults.standard.set(unit.rawValue, forKey: "temperatureUnit")
        }
    }

    private init() {
        // Load saved preference or default to Celsius
        if let savedUnit = UserDefaults.standard.string(forKey: "temperatureUnit"),
           let unit = TemperatureUnit(rawValue: savedUnit) {
            self.unit = unit
        } else {
            self.unit = .celsius
        }
    }

    func toggle() {
        unit = unit.toggled()
    }
}
