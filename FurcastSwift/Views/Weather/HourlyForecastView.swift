import SwiftUI

// MARK: - Hourly Forecast View
struct HourlyForecastView: View {
    let hourlyData: [HourlyWeather]
    let textColor: Color
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(description)
                .font(.callout)
                .foregroundColor(textColor.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.horizontal, 12)
            
            Divider()
                .background(textColor.opacity(0.5))
                .frame(height: 1)
                .padding(.horizontal, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(hourlyData.enumerated()), id: \.offset) { index, hour in
                        HourlyItemView(hourly: hour, textColor: textColor)
                    }
                }
                .padding(.leading, 12)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(textColor.opacity(0.1))
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Hourly Item View
struct HourlyItemView: View {
    let hourly: HourlyWeather
    let textColor: Color
    @ObservedObject var temperatureSettings = TemperatureSettings.shared

    var body: some View {
        VStack {
            Text(hourly.time)
                .font(.caption)
                .foregroundColor(textColor)
                .fontWeight(.medium)

            Spacer(minLength: 4)

            if let precipChance = hourly.precipitationChance {
                VStack(spacing: 2) {
                    Image(systemName: hourly.condition.systemImage)
                        .font(.title2)
                        .symbolRenderingMode(.multicolor)

                    Text("\(precipChance)%")
                        .font(.caption2)
                        .foregroundColor(.cyan)
                        .fontWeight(.medium)
                }
            } else {
                Image(systemName: hourly.condition.systemImage)
                    .font(.title2)
                    .symbolRenderingMode(.multicolor)
            }

            Spacer(minLength: 4)

            Text("\(hourly.getTemperature(in: temperatureSettings.unit))°")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(textColor)
        }
        .frame(width: 44)
    }
}

#Preview {
    HourlyForecastView(
        hourlyData: WeatherData.sampleData.hourlyForecast,
        textColor: .white,
        description: WeatherData.sampleData.description
    )
    .background(Color.blue)
} 