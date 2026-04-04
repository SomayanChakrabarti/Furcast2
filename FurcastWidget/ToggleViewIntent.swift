import AppIntents
import WidgetKit

struct ToggleViewIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Hourly View"

    @MainActor
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.MayansParty.FurcastSwift")
        let current = defaults?.bool(forKey: "showingHourly") ?? false
        let newValue = !current

        defaults?.set(newValue, forKey: "showingHourly")
        defaults?.synchronize()

        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}
