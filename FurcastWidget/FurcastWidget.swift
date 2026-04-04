import WidgetKit
import SwiftUI

private func widgetGradient(condition: String, date: Date) -> LinearGradient {
    let hour = Calendar.current.component(.hour, from: date)
    let isDay = hour >= 7 && hour < 20

    let colors: [Color]
    switch condition.lowercased() {
    case let c where c.contains("clear") || c.contains("sunny"):
        colors = isDay
            ? [Color(red: 0.23, green: 0.48, blue: 0.84), Color(red: 0.54, green: 0.77, blue: 0.88)]
            : [Color(red: 0.05, green: 0.11, blue: 0.16), Color(red: 0.11, green: 0.19, blue: 0.28)]
    case let c where c.contains("partly"):
        colors = isDay
            ? [Color(red: 0.29, green: 0.50, blue: 0.65), Color(red: 0.48, green: 0.69, blue: 0.79)]
            : [Color(red: 0.10, green: 0.17, blue: 0.24), Color(red: 0.17, green: 0.25, blue: 0.33)]
    case let c where c.contains("rain") || c.contains("drizzle"):
        colors = isDay
            ? [Color(red: 0.17, green: 0.29, blue: 0.43), Color(red: 0.29, green: 0.45, blue: 0.60)]
            : [Color(red: 0.07, green: 0.12, blue: 0.16), Color(red: 0.12, green: 0.19, blue: 0.25)]
    default: // cloudy, overcast, etc.
        colors = isDay
            ? [Color(red: 0.33, green: 0.42, blue: 0.48), Color(red: 0.54, green: 0.67, blue: 0.72)]
            : [Color(red: 0.12, green: 0.16, blue: 0.20), Color(red: 0.18, green: 0.24, blue: 0.29)]
    }
    return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
}

private struct CurrentWeatherView: View {
    let entry: WeatherWidgetEntry

    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top, spacing: 1) {
                Text("\(entry.displayCurrentTemp)")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white)
                Text(entry.tempUnit)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.top, 8)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.condition)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Text("H:\(entry.displayHighTemp)° L:\(entry.displayLowTemp)°")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
}

private struct HourlyRowView: View {
    let entry: WeatherWidgetEntry

    var body: some View {
        HStack {
            ForEach(entry.hourlyForecast.prefix(6), id: \.time) { item in
                VStack(spacing: 8) {
                    Text(item.time)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    Image(systemName: item.symbolName)
                        .symbolRenderingMode(.multicolor)
                        .font(.title3)
                    Text("\(entry.displayHourlyTemp(item))°")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct WeatherWidgetEntryView: View {
    var entry: WeatherWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if entry.showingHourly {
                // Hourly view: forecast row is the first thing shown
                HourlyRowView(entry: entry)
            } else {
                // Current weather view: header + big temp
                HStack {
                    Text(entry.cityName)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: entry.weatherIcon)
                        .font(.title3)
                        .symbolRenderingMode(.multicolor)
                }

                Spacer(minLength: 0).frame(maxHeight: 4)

                CurrentWeatherView(entry: entry)
            }

            Spacer(minLength: 0)

            // Bottom: staleness | unit toggle | view toggle
            HStack {
                Text(entry.timeAgoString)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.white.opacity(0.55))

                Spacer()

                Button(intent: ToggleTemperatureIntent()) {
                    Text(entry.isCelsius ? "°F" : "°C")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 64)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.25)))
                }
                .buttonStyle(.plain)

                Button(intent: ToggleViewIntent()) {
                    Group {
                        if entry.showingHourly {
                            Text("Now")
                                .font(.subheadline)
                        } else {
                            Image(systemName: "clock")
                                .font(.subheadline)
                        }
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 64)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.15)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
    }
}

struct FurcastWidget: Widget {
    let kind: String = "FurcastWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
                .containerBackground(widgetGradient(condition: entry.condition, date: entry.date), for: .widget)
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
        isCelsius: true,
        hourlyForecast: [
            WidgetHourlyItem(time: "Now", temperature: 18, symbolName: "sun.max.fill", precipChance: nil),
            WidgetHourlyItem(time: "2PM", temperature: 20, symbolName: "sun.max.fill", precipChance: nil),
            WidgetHourlyItem(time: "3PM", temperature: 22, symbolName: "cloud.sun.fill", precipChance: nil),
            WidgetHourlyItem(time: "4PM", temperature: 21, symbolName: "cloud.fill", precipChance: nil),
            WidgetHourlyItem(time: "5PM", temperature: 19, symbolName: "cloud.rain.fill", precipChance: 40),
            WidgetHourlyItem(time: "6PM", temperature: 17, symbolName: "cloud.rain.fill", precipChance: 60),
        ],
        showingHourly: false
    )
    WeatherWidgetEntry(
        date: .now,
        cityName: "Somerville",
        currentTemp: 18,
        highTemp: 28,
        lowTemp: 15,
        condition: "Clear",
        weatherIcon: "sun.max.fill",
        isCelsius: false,
        hourlyForecast: [
            WidgetHourlyItem(time: "Now", temperature: 18, symbolName: "sun.max.fill", precipChance: nil),
            WidgetHourlyItem(time: "2PM", temperature: 20, symbolName: "sun.max.fill", precipChance: nil),
            WidgetHourlyItem(time: "3PM", temperature: 22, symbolName: "cloud.sun.fill", precipChance: nil),
            WidgetHourlyItem(time: "4PM", temperature: 21, symbolName: "cloud.fill", precipChance: nil),
            WidgetHourlyItem(time: "5PM", temperature: 19, symbolName: "cloud.rain.fill", precipChance: 40),
            WidgetHourlyItem(time: "6PM", temperature: 17, symbolName: "cloud.rain.fill", precipChance: 60),
        ],
        showingHourly: true
    )
}
