import AppIntents
import WidgetKit

struct ToggleTemperatureIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Temperature Unit"

    @MainActor
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.MayansParty.FurcastSwift")
        let currentIsCelsius = defaults?.bool(forKey: "isCelsius") ?? true
        let newValue = !currentIsCelsius

        defaults?.set(newValue, forKey: "isCelsius")
        defaults?.synchronize() // Force immediate save

        print("Widget toggle: \(currentIsCelsius) -> \(newValue)")

        // Reload widget timelines
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}
