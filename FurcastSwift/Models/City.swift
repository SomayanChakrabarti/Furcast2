import Foundation

// MARK: - City Model
struct City: Identifiable, Codable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let gifName: String? // Optional custom GIF for each city
    
    init(name: String, latitude: Double, longitude: Double, gifName: String? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.gifName = gifName
    }
}

// MARK: - Sample Cities
extension City {
    static let sampleCities = [
        City(name: "Current Location", latitude: 0.0, longitude: 0.0, gifName: "1"), // Will be updated with actual location
        City(name: "Vancouver", latitude: 49.2827, longitude: -123.1207, gifName: "2"),
        City(name: "Boston", latitude: 42.3601, longitude: -71.0589, gifName: "3"),
        City(name: "Sandwich", latitude: 43.7792, longitude: -71.4050, gifName: "4"), // Sandwich, NH
        City(name: "New York", latitude: 40.7128, longitude: -74.0060, gifName: "5"),
        City(name: "Salt Lake City", latitude: 40.7608, longitude: -111.8910, gifName: "6"),
        City(name: "San Francisco", latitude: 37.7749, longitude: -122.4194, gifName: "7")
    ]
} 
