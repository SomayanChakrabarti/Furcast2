import Foundation
import OpenAI

class WeatherDescriptionGenerator {
    static let shared = WeatherDescriptionGenerator()

    private lazy var openAI = OpenAI(apiToken: Config.openAIAPIKey)

    private init() {}

    func generateDescription(
        location: String,
        temperature: Int,
        condition: String,
        highTemp: Int,
        lowTemp: Int
    ) async -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        if hour < 12 {
            timeOfDay = "morning"
        } else if hour < 17 {
            timeOfDay = "afternoon"
        } else {
            timeOfDay = "evening"
        }

        let prompt = """
        Write a funny, witty weather description for \(location) this \(timeOfDay).
        Current temp: \(temperature)°C, Condition: \(condition), High: \(highTemp)°C, Low: \(lowTemp)°C.
        Include what to wear and be casual, humorous, under 200 characters. Include a relevant emoji.
        """

        do {
            let query = ChatQuery(
                messages: [.init(role: .user, content: prompt)!],
                model: .gpt4_o_mini
            )

            let result = try await openAI.chats(query: query)

            if let description = result.choices.first?.message.content {
                return description
            }
        } catch {
            print("OpenAI error: \(error)")
        }

        // Fallback
        return "\(condition) conditions throughout the day."
    }
}
