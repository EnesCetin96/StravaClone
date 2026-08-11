import Foundation
import CoreLocation

/// Contract that any location-tracking implementation must satisfy.
/// The real GPS implementation (LocationTracker) and any mock/test
/// implementation both conform to this, so the rest of the app never
/// needs to know which one it's talking to.
protocol LocationTracking: AnyObject, ObservableObject {
    var isTracking: Bool { get }
    var currentLocation: CLLocation? { get }
    var routePoints: [CLLocation] { get }
    var distanceMeters: Double { get }
    var elapsedSeconds: TimeInterval { get }
    var authorizationStatus: CLAuthorizationStatus { get }

    func requestPermission()
    func start(activity: ActivityType)
    func stop() -> (points: [CLLocation], distance: Double, duration: TimeInterval, start: Date, end: Date)?
}