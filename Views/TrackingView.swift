import SwiftUI
import SwiftData
import MapKit

struct TrackingView: View {
    let activityType: ActivityType
    @ObservedObject var tracker: LocationTracker

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                UserAnnotation()
                if tracker.routePoints.count > 1 {
                    MapPolyline(coordinates: tracker.routePoints.map(\.coordinate))
                        .stroke(Color.accentColor, lineWidth: 5)
                }
            }
            .mapControls { MapUserLocationButton() }
            .ignoresSafeArea(edges: .top)

            statsPanel
        }
        .onAppear {
            tracker.start(activity: activityType)
        }
    }

    private var statsPanel: some View {
        VStack(spacing: 16) {
            HStack {
                statBlock(title: "Mesafe", value: String(format: "%.2f km", tracker.distanceMeters / 1000))
                statBlock(title: "Süre", value: formattedTime(tracker.elapsedSeconds))
                statBlock(title: "Hız", value: String(format: "%.1f km/s", currentSpeedKmh))
            }

            Button(role: .destructive) {
                stopAndSave()
            } label: {
                Text("Durdur ve Kaydet")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding()
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack {
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var currentSpeedKmh: Double {
        guard tracker.elapsedSeconds > 0 else { return 0 }
        return (tracker.distanceMeters / tracker.elapsedSeconds) * 3.6
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func stopAndSave() {
        guard let result = tracker.stop() else { return }

        let activity = Activity(
            type: activityType,
            startDate: result.start,
            endDate: result.end,
            distanceMeters: result.distance,
            durationSeconds: result.duration
        )
        modelContext.insert(activity)

        for location in result.points {
            let point = RoutePoint(location: location)
            point.activity = activity
            modelContext.insert(point)
        }

        try? modelContext.save()
        dismiss()
    }
}
