import Foundation
import UIKit
import CoreLocation

struct TrainingSession: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var distanceKm: Double
    var durationMinutes: Int
    var description: String
    var type: String?
}

struct TrainingGoal: Codable {
    var goalName: String
    var distanceKm: Double
    var targetDate: Date
}

struct RoutePoint: Codable {
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}

struct RunRoute: Identifiable, Codable {
    var id = UUID()
    var name: String
    var date: Date
    var points: [RoutePoint]
    var durationMinutes: Int
    var distanceKm: Double

    var summary: String {
        String(format: "%.1f km / %d min", distanceKm, durationMinutes)
    }

    var coordinates: [CLLocationCoordinate2D] {
        points.map { $0.coordinate }
    }
}

struct RunLog: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var distanceKm: Double
    var durationMinutes: Int

    var averagePace: Double {
        guard distanceKm > 0 else { return 0 }
        return Double(durationMinutes) / distanceKm
    }

    var notes: String
}

struct MediaItem: Identifiable {
    var id = UUID()
    var image: UIImage?
    var videoURL: URL?
    var caption: String
}
