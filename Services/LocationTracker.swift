import Foundation
import CoreLocation
import Combine

/// Kayıt sırasında GPS'i yönetir: konum güncellemelerini alır, mesafeyi hesaplar,
/// hatalı/sıçramalı GPS noktalarını filtreler ve canlı istatistikleri yayınlar.
@MainActor
final class LocationTracker: NSObject, ObservableObject {

    // MARK: - Published state (UI buraya bağlanır)
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

    // Hatalı GPS noktalarını elemek için eşik değerler
    private let maxAcceptableAccuracy: Double = 25 // metre - bundan kötü doğrulukları at
    private let maxPlausibleSpeed: Double = 15 // m/s (~54 km/s) - bisiklet için bile makul üst sınır

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = 5 // 5 metreden az hareketleri yok say (gürültüyü azaltır)
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

    /// Kaydı durdurur ve kaydedilmeye hazır bir Activity döndürür (henüz SwiftData'ya eklenmedi)
    func stop() -> (points: [CLLocation], distance: Double, duration: TimeInterval, start: Date, end: Date)? {
        guard isTracking, let start = startDate else { return nil }
        isTracking = false
        manager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil

        let result = (points: routePoints, distance: distanceMeters, duration: elapsedSeconds, start: start, end: Date())
        return result
    }

    private func processNewLocation(_ location: CLLocation) {
        // 1) Doğruluğu kötü olan noktaları at
        guard location.horizontalAccuracy >= 0, location.horizontalAccuracy <= maxAcceptableAccuracy else {
            return
        }

        currentLocation = location

        if let last = routePoints.last {
            let delta = location.distance(from: last)
            let timeDelta = location.timestamp.timeIntervalSince(last.timestamp)

            // 2) Sıçrama kontrolü: gerçekçi olmayan hızda "teleport" eden noktaları at
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
        print("Konum hatası: \(error.localizedDescription)")
    }
}
