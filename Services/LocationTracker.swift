import Foundation
import CoreLocation
import Combine

/// Manages GPS during an active recording session: receives location updates,
/// calculates cumulative distance, filters out inaccurate/implausible GPS
/// points, and publishes live stats for the UI to observe.
@MainActor
final class LocationTracker: NSObject, LocationTracking {

    // MARK: - Published state (the UI binds to these)
    @Published var isTracking = false
    @Published var currentLocation: CLLocation?
    @Published var routePoints: [CLLocation] = []
    @Published var distanceMeters: Double = 0
    @Published var elapsedSeconds: TimeInterval = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Private
    private let manager = CLLocationManager()
    private var timer: Timer?
    private var startDate: Date?
    private var activityType: ActivityType = .running

    // Thresholds used to filter out bad GPS points
    private let maxAcceptableAccuracy: Double = 25 // meters - discard anything worse than this
    private let maxPlausibleSpeed: Double = 15 // m/s (~54 km/h) - reasonable upper bound even for cycling

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = 5 // ignore movements smaller than 5 meters (reduces noise)
        manager.pausesLocationUpdatesAutomatically = false
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }

    func start(activity: ActivityType) {
        guard !isTracking else { return }
        activityType = activity
        routePoints.removeAll()
        distanceMeters = 0
        elapsedSeconds = 0
        startDate = Date()
        isTracking = true

        manager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            Task { @MainActor in
                self.elapsedSeconds = Date().timeIntervalSince(start)
            }
        }
    }

    /// Stops the current recording and returns the raw data needed to build
    /// an Activity. Does not touch persistence (SwiftData) itself.
    func stop() -> (points: [CLLocation], distance: Double, duration: TimeInterval, start: Date, end: Date)? {
        guard isTracking, let start = startDate else { return nil }
        isTracking = false
        manager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil

        let result = (points: routePoints, distance: distanceMeters, duration: elapsedSeconds, start: start, end: Date())
        return result
    }

    func processNewLocation(_ location: CLLocation) {
        // 1) Discard points with poor accuracy
        guard location.horizontalAccuracy >= 0, location.horizontalAccuracy <= maxAcceptableAccuracy else {
            return
        }

        currentLocation = location

        if let last = routePoints.last {
            let delta = location.distance(from: last)
            let timeDelta = location.timestamp.timeIntervalSince(last.timestamp)

            // 2) Jump check: discard points that imply an unrealistic "teleport" speed
            if timeDelta > 0 {
                let impliedSpeed = delta / timeDelta
                if impliedSpeed > maxPlausibleSpeed {
                    return
                }
            }
            distanceMeters += delta
        }

        routePoints.append(location)
    }
}

extension LocationTracker: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            for location in locations {
                self.processNewLocation(location)
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}