import WidgetKit
import WeatherKit
import CoreLocation

struct WeatherProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.MayansParty.FurcastSwift")
    private let weatherService = WeatherKit.WeatherService()

    func placeholder(in context: Context) -> WeatherWidgetEntry {
        WeatherWidgetEntry(
            date: Date(),
            cityName: "Loading...",
            currentTemp: 20,
            highTemp: 25,
            lowTemp: 15,
            condition: "Clear",
            weatherIcon: "sun.max.fill",
            isCelsius: true,
            hourlyForecast: [],
            showingHourly: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> Void) {
        Task {
            let entry = await fetchWeatherEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> Void) {
        Task {
            let entry = await fetchWeatherEntry()

            // Update every 15 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchCurrentLocation() async -> CLLocation {
        if #available(iOS 17, *) {
            do {
                for try await update in CLLocationUpdate.liveUpdates() {
                    if let location = update.location {
                        defaults?.set(location.coordinate.latitude, forKey: "currentLocationLat")
                        defaults?.set(location.coordinate.longitude, forKey: "currentLocationLon")
                        return location
                    }
                    if update.authorizationDenied || update.authorizationRestricted {
                        break
                    }
                }
            } catch {
                print("Widget location error: \(error)")
            }
        }

        // Fall back to last known location from shared defaults
        let latitude = defaults?.double(forKey: "currentLocationLat") ?? 42.3601
        let longitude = defaults?.double(forKey: "currentLocationLon") ?? -71.0589
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    private func fetchWeatherEntry() async -> WeatherWidgetEntry {
        let isCelsius = defaults?.bool(forKey: "isCelsius") ?? true
        let showingHourly = defaults?.bool(forKey: "showingHourly") ?? false
        let location = await fetchCurrentLocation()

        do {
            let weather = try await weatherService.weather(for: location)

            let currentTemp = Int(weather.currentWeather.temperature.value)
            let highTemp = weather.dailyForecast.first.map { Int($0.highTemperature.value) } ?? currentTemp
            let lowTemp = weather.dailyForecast.first.map { Int($0.lowTemperature.value) } ?? currentTemp

            let condition = mapCondition(weather.currentWeather.condition)
            let icon = mapWeatherIcon(weather.currentWeather.condition)

            // Get city name
            let cityName = try? await getLocationName(for: location)

            // Map hourly forecast: filter to current hour onwards, take first 6
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "ha"
            let upcomingHours = weather.hourlyForecast.filter { $0.date >= now.addingTimeInterval(-3600) }
            let hourlyItems: [WidgetHourlyItem] = upcomingHours.prefix(6).enumerated().map { index, hour in
                let timeStr = index == 0 ? "Now" : formatter.string(from: hour.date)
                return WidgetHourlyItem(
                    time: timeStr,
                    temperature: Int(hour.temperature.converted(to: .celsius).value),
                    symbolName: mapWeatherIcon(hour.condition, isDaylight: hour.isDaylight),
                    precipChance: hour.precipitationChance > 0 ? Int(hour.precipitationChance * 100) : nil
                )
            }

            return WeatherWidgetEntry(
                date: Date(),
                cityName: cityName ?? "Current Location",
                currentTemp: currentTemp,
                highTemp: highTemp,
                lowTemp: lowTemp,
                condition: condition,
                weatherIcon: icon,
                isCelsius: isCelsius,
                hourlyForecast: hourlyItems,
                showingHourly: showingHourly
            )
        } catch {
            print("Widget weather fetch error: \(error)")
            return WeatherWidgetEntry(
                date: Date(),
                cityName: "Unavailable",
                currentTemp: 20,
                highTemp: 25,
                lowTemp: 15,
                condition: "Clear",
                weatherIcon: "sun.max.fill",
                isCelsius: isCelsius,
                hourlyForecast: [],
                showingHourly: showingHourly
            )
        }
    }

    private func mapCondition(_ condition: WeatherKit.WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear:
            return "Clear"
        case .cloudy, .mostlyCloudy:
            return "Cloudy"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .rain, .drizzle, .heavyRain:
            return "Rain"
        case .snow, .sleet, .flurries, .heavySnow:
            return "Snow"
        case .thunderstorms:
            return "Storms"
        default:
            return "Cloudy"
        }
    }

    private func mapWeatherIcon(_ condition: WeatherKit.WeatherCondition, isDaylight: Bool = true) -> String {
        switch condition {
        case .clear, .mostlyClear:
            return isDaylight ? "sun.max.fill" : "moon.stars.fill"
        case .cloudy, .mostlyCloudy:
            return "cloud.fill"
        case .partlyCloudy:
            return isDaylight ? "cloud.sun.fill" : "cloud.moon.fill"
        case .rain, .drizzle, .heavyRain:
            return "cloud.rain.fill"
        default:
            return "cloud.fill"
        }
    }

    private func getLocationName(for location: CLLocation) async throws -> String {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        if let placemark = placemarks.first {
            return placemark.locality ?? placemark.name ?? "Unknown"
        }

        return "Unknown"
    }
}
