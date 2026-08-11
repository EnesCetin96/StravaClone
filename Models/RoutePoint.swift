import Foundation
import SwiftData
import CoreLocation

@Model
final class RoutePoint {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var timestamp: Date
    var speed: Double // m/s, negatif olabilir (geçersiz) - kullanmadan önce kontrol et
    var horizontalAccuracy: Double

    // SwiftData ilişkisi: bu nokta hangi aktiviteye ait
    var activity: Activity?

    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.timestamp = location.timestamp
        self.speed = location.speed
        self.horizontalAccuracy = location.horizontalAccuracy
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: -1, timestamp: timestamp)
    }
}
