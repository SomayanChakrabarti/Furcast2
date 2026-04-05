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
        ZStack(alignment: .bottom) {
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

            CityPageIndicator(numberOfPages: cities.count, currentPage: $selectedCityIndex)
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


// MARK: - Liquid Glass Page Indicator
struct CityPageIndicator: View {
    let numberOfPages: Int
    @Binding var currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                if index == 0 {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(index == currentPage ? .white : .white.opacity(0.4))
                } else {
                    Circle()
                        .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                        .frame(width: 7, height: 7)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .liquidGlass(in: Capsule())
        .overlay(
            GeometryReader { geo in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - 20
                                let slotWidth = (geo.size.width - 40) / CGFloat(numberOfPages)
                                let index = Int(x / slotWidth)
                                let clamped = max(0, min(numberOfPages - 1, index))
                                if clamped != currentPage {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        currentPage = clamped
                                    }
                                }
                            }
                    )
            }
        )
    }
}

private extension View {
    @ViewBuilder
    func liquidGlass(in shape: some Shape) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular.interactive(), in: shape)
        } else {
            self.background(shape.fill(.ultraThinMaterial))
        }
    }
}

#Preview {
    CityPageView()
} 
