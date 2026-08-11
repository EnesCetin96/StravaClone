import SwiftUI
import MapKit

struct ActivityDetailView: View {
    let activity: Activity
    @State private var exportedURL: URL?
    @State private var showShareSheet = false

    private var coordinates: [CLLocationCoordinate2D] {
        activity.route
            .sorted { $0.timestamp < $1.timestamp }
            .map(\.coordinate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if coordinates.count > 1 {
                    Map {
                        MapPolyline(coordinates: coordinates)
                            .stroke(Color.accentColor, lineWidth: 5)
                    }
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }

                HStack {
                    stat("Mesafe", String(format: "%.2f km", activity.distanceKm))
                    stat("Süre", activity.durationString)
                    if activity.type == .running {
                        stat("Tempo", activity.paceString)
                    } else {
                        stat("Ort. Hız", String(format: "%.1f km/s", activity.averageSpeedKmh))
                    }
                }
                .padding(.horizontal)

                Button {
                    exportedURL = GPXExporter.export(activity: activity)
                    showShareSheet = exportedURL != nil
                } label: {
                    Label("GPX Olarak Paylaş (Google Maps'te aç)", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical)
        }
        .navigationTitle(activity.type.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let exportedURL {
                ShareSheet(items: [exportedURL])
            }
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack {
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

/// UIActivityViewController'ı SwiftUI'a bağlayan basit wrapper - GPX dosyasını
/// AirDrop, Google Maps, Dosyalar vb. ile paylaşmaya yarar.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
