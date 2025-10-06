import WidgetKit
import SwiftUI

struct WeatherWidgetEntryView: View {
    var entry: WeatherWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
                // Left side: Current weather
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.cityName)
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(alignment: .top, spacing: 2) {
                        Text("\(entry.displayCurrentTemp)")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                        Text(entry.tempUnit)
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 8)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: entry.weatherIcon)
                            .font(.title3)
                            .foregroundColor(.white)
                            .symbolRenderingMode(.multicolor)

                        Text(entry.condition)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

                Spacer()

                // Right side: High/Low + Toggle
                VStack(alignment: .trailing, spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .font(.caption2)
                            Text("\(entry.displayHighTemp)°")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white.opacity(0.9))

                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.caption2)
                            Text("\(entry.displayLowTemp)°")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    // Temperature unit toggle button
                    Button(intent: ToggleTemperatureIntent()) {
                        HStack(spacing: 2) {
                            Text("°C")
                                .fontWeight(entry.isCelsius ? .bold : .regular)
                            Text("/")
                            Text("°F")
                                .fontWeight(entry.isCelsius ? .regular : .bold)
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
    }
}

struct FurcastWidget: Widget {
    let kind: String = "FurcastWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.15, green: 0.2, blue: 0.3)
                }
        }
        .configurationDisplayName("Weather")
        .description("Current weather with temperature toggle")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    FurcastWidget()
} timeline: {
    WeatherWidgetEntry(
        date: .now,
        cityName: "Somerville",
        currentTemp: 18,
        highTemp: 28,
        lowTemp: 15,
        condition: "Clear",
        weatherIcon: "sun.max.fill",
        isCelsius: true
    )
    WeatherWidgetEntry(
        date: .now,
        cityName: "Somerville",
        currentTemp: 18,
        highTemp: 28,
        lowTemp: 15,
        condition: "Clear",
        weatherIcon: "sun.max.fill",
        isCelsius: false
    )
}
