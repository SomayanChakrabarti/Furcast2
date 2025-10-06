import SwiftUI

// MARK: - Current Weather View
struct CurrentWeatherView: View {
    let weatherData: WeatherData
    let textColor: Color
    @ObservedObject var temperatureSettings = TemperatureSettings.shared

    var body: some View {
        VStack(spacing: 4) {
            Text(weatherData.location)
                .font(.title)
                .fontWeight(.thin)
                .foregroundColor(textColor)

            Text("\(weatherData.getCurrentTemp(in: temperatureSettings.unit))°")
                .font(.system(size: 64, weight: .regular))
                .foregroundColor(textColor)

            VStack(spacing: 4) {
                Text(weatherData.condition)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(textColor.opacity(0.7))

                Text("H:\(weatherData.getHighTemp(in: temperatureSettings.unit))° L:\(weatherData.getLowTemp(in: temperatureSettings.unit))°")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
            }
        }
    }
}

#Preview {
    CurrentWeatherView(
        weatherData: WeatherData.sampleData,
        textColor: .white
    )
    .background(Color.blue)
} 