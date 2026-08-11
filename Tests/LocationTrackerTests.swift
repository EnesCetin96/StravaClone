import XCTest
import CoreLocation
@testable import StravaClone

@MainActor
final class LocationTrackerTests: XCTestCase {

    /// Helper that builds a fake GPS reading with the values we want to test.
    private func makeLocation(lat: Double, lon: Double, accuracy: Double, timestamp: Date) -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            altitude: 0,
            horizontalAccuracy: accuracy,
            verticalAccuracy: 0,
            course: 0,
            speed: 0,
            timestamp: timestamp
        )
    }

    func testDiscardsPointsWithPoorAccuracy() {
        let tracker = LocationTracker()
        let badPoint = makeLocation(lat: 0, lon: 0, accuracy: 50, timestamp: Date())

        tracker.processNewLocation(badPoint)

        XCTAssertEqual(tracker.routePoints.count, 0, "A point with accuracy worse than 25m should be discarded")
    }

    func testAcceptsPointsWithGoodAccuracy() {
        let tracker = LocationTracker()
        let goodPoint = makeLocation(lat: 0, lon: 0, accuracy: 10, timestamp: Date())

        tracker.processNewLocation(goodPoint)

        XCTAssertEqual(tracker.routePoints.count, 1, "A point within the accuracy threshold should be accepted")
    }

    func testDiscardsImplausibleSpeedJump() {
        let tracker = LocationTracker()
        let start = Date()

        tracker.processNewLocation(makeLocation(lat: 0, lon: 0, accuracy: 10, timestamp: start))

        // ~1000 meters away, only 1 second later -> ~1000 m/s, far above the 15 m/s limit
        let teleportPoint = makeLocation(lat: 0.009, lon: 0, accuracy: 10, timestamp: start.addingTimeInterval(1))
        tracker.processNewLocation(teleportPoint)

        XCTAssertEqual(tracker.routePoints.count, 1, "An implausible speed jump should be discarded")
        XCTAssertEqual(tracker.distanceMeters, 0, "Distance should not increase from a discarded point")
    }

    func testAccumulatesDistanceForRealisticMovement() {
        let tracker = LocationTracker()
        let start = Date()

        tracker.processNewLocation(makeLocation(lat: 0, lon: 0, accuracy: 10, timestamp: start))

        // ~11 meters away, 5 seconds later -> ~2.2 m/s, a realistic running pace
        let secondPoint = makeLocation(lat: 0.0001, lon: 0, accuracy: 10, timestamp: start.addingTimeInterval(5))
        tracker.processNewLocation(secondPoint)

        XCTAssertEqual(tracker.routePoints.count, 2, "Realistic movement should be accepted")
        XCTAssertGreaterThan(tracker.distanceMeters, 0, "Distance should increase for accepted points")
    }
}