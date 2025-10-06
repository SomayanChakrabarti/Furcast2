import SwiftUI
import CoreLocation

// MARK: - City Page View (Swipeable Container)
struct CityPageView: View {
    @State private var cities: [City] = []
    @State private var selectedCityIndex = 0
    @ObservedObject private var locationManager = LocationManager.shared
    
    private var currentBackgroundColor: Color {
        guard selectedCityIndex < cities.count else { return .clear }
        let gifName = cities[selectedCityIndex].gifName ?? "toiletpaperdance"
        return GIFView.extractBackgroundColor(from: gifName)
    }
    
    var body: some View {
        TabView(selection: $selectedCityIndex) {
            ForEach(Array(cities.enumerated()), id: \.element.id) { index, city in
                WeatherView(city: city)
                    .tag(index)
            }
        }
        .background(currentBackgroundColor)
        .animation(.easeInOut(duration: 0.3), value: currentBackgroundColor)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            // Custom page indicator
            PageIndicator(
                numberOfPages: cities.count,
                currentPage: selectedCityIndex
            )
            .padding(.bottom, 0)
        }
        .onAppear {
            initializeCitiesWithRandomGIFs()
            locationManager.requestPermission()
            preloadWeatherForAllCities()
        }
        .onChange(of: locationManager.currentLocation) { oldValue, newLocation in
            if let location = newLocation {
                updateCurrentLocationCity(with: location)
            }
        }
    }

    private func initializeCitiesWithRandomGIFs() {
        // Assign random GIFs from 1-27 to each city
        let availableGIFs = Array(1...27).shuffled()
        cities = City.sampleCities.enumerated().map { index, city in
            City(
                name: city.name,
                latitude: city.latitude,
                longitude: city.longitude,
                gifName: "\(availableGIFs[index])"
            )
        }
    }

    private func updateCurrentLocationCity(with location: CLLocation) {
        // Update the first city with actual location coordinates
        cities[0] = City(
            name: "Current Location",
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            gifName: cities[0].gifName
        )
    }

    private func preloadWeatherForAllCities() {
        // Preload weather data for all cities in the background
        for city in cities {
            Task {
                do {
                    _ = try await WeatherService.shared.fetchWeather(
                        for: city.latitude,
                        longitude: city.longitude
                    )
                } catch {
                    // Silently fail - individual views will handle errors
                    print("Failed to preload weather for \(city.name)")
                }
            }
        }
    }
}

// MARK: - Custom Page Indicator
struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.2))
        )
    }
}

// MARK: - Background Blur Extension
extension View {
    func backdrop() -> some View {
        self.background(.ultraThinMaterial.opacity(0.3))
    }
}

#Preview {
    CityPageView()
} 
