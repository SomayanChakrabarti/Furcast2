import Foundation
import CoreLocation
import Combine

// MARK: - Location Manager
@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()
    private let defaults = UserDefaults(suiteName: "group.MayansParty.FurcastSwift")

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }

    /// Request location permission
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Start updating location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    /// Stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    /// Get current location once
    func getCurrentLocation() {
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location

        // Save to shared defaults for widget access
        defaults?.set(location.coordinate.latitude, forKey: "currentLocationLat")
        defaults?.set(location.coordinate.longitude, forKey: "currentLocationLon")
        defaults?.synchronize()

        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            getCurrentLocation()
        default:
            break
        }
    }
}
