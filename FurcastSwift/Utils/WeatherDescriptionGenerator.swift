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
        let prompt = """
        Write a funny, witty, single-sentence weather description for \(location).
        Current temp: \(temperature)°C, Condition: \(condition), High: \(highTemp)°C, Low: \(lowTemp)°C.
        Be casual, humorous, and under 100 characters. Include a relevant emoji.
        """

        do {
            let query = ChatQuery(
                messages: [.init(role: .user, content: prompt)!],
                model: .gpt4_o_mini,
                maxTokens: 50
            )

            let result = try await openAI.chats(query: query)

            if let description = result.choices.first?.message.content?.string {
                return description.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("OpenAI error: \(error)")
        }

        // Fallback
        return "\(condition) conditions throughout the day."
    }
}
