import SwiftUI

// MARK: - Daily Forecast View
struct DailyForecastView: View {
    let dailyData: [DailyWeather]
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(Array(dailyData.enumerated()), id: \.offset) { index, day in
                    DailyItemView(daily: day, textColor: textColor)
                    
                    if index < dailyData.count - 1 {
                        Divider()
                            .background(textColor.opacity(0.2))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(textColor.opacity(0.1))
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Daily Item View
struct DailyItemView: View {
    let daily: DailyWeather
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Text(daily.day)
                .font(.title3)
                .foregroundColor(textColor)
                .frame(width: 64, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: daily.condition.systemImage)
                    .font(.title2)
                    .foregroundColor(textColor)
                
                if let precipChance = daily.precipitationChance {
                    Text("\(precipChance)%")
                        .font(.caption2)
                        .foregroundColor(.cyan)
                        .fontWeight(.medium)
                        .frame(width: 30)
                } else {
                    Spacer()
                        .frame(width: 30)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("L: \(daily.lowTemp)°")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                    .frame(width: 64, alignment: .leading)
                
                Text("H: \(daily.highTemp)°")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                    .frame(width: 64, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    DailyForecastView(
        dailyData: WeatherData.sampleData.dailyForecast,
        textColor: .white
    )
    .background(Color.blue)
} 