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
        City(name: "Joniec", latitude: 50.0, longitude: 20.0, gifName: "1"),
        City(name: "New York", latitude: 40.7128, longitude: -74.0060, gifName: "2"),
        City(name: "London", latitude: 51.5074, longitude: -0.1278, gifName: "3"),
        City(name: "Tokyo", latitude: 35.6762, longitude: 139.6503, gifName: "4")
    ]
} 
