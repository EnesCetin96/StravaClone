import Foundation
import SwiftData

@Model
final class Activity {
    var typeRaw: String
    var startDate: Date
    var endDate: Date
    var distanceMeters: Double // toplam mesafe
    var durationSeconds: Double

    @Relationship(deleteRule: .cascade, inverse: \RoutePoint.activity)
    var route: [RoutePoint] = []

    init(type: ActivityType, startDate: Date, endDate: Date, distanceMeters: Double, durationSeconds: Double) {
        self.typeRaw = type.rawValue
        self.startDate = startDate
        self.endDate = endDate
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
    }

    var type: ActivityType {
        ActivityType(rawValue: typeRaw) ?? .running
    }

    var distanceKm: Double {
        distanceMeters / 1000
    }

    /// Ortalama hız (km/s)
    var averageSpeedKmh: Double {
        guard durationSeconds > 0 else { return 0 }
        return (distanceMeters / durationSeconds) * 3.6
    }

    /// Koşu için pace (dakika/km), "5:32" formatında string döner
    var paceString: String {
        guard distanceKm > 0 else { return "-" }
        let secondsPerKm = durationSeconds / distanceKm
        let minutes = Int(secondsPerKm) / 60
        let seconds = Int(secondsPerKm) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }

    var durationString: String {
        let h = Int(durationSeconds) / 3600
        let m = (Int(durationSeconds) % 3600) / 60
        let s = Int(durationSeconds) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}
