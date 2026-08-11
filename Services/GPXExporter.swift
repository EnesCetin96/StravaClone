import Foundation

/// Aktiviteyi standart .gpx formatına çevirir. GPX dosyaları Google Maps, Google Earth,
/// Strava, Komoot gibi hemen hemen tüm harita/spor uygulamaları tarafından okunabilir.
enum GPXExporter {

    static func export(activity: Activity) -> URL? {
        let iso = ISO8601DateFormatter()
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="StravaClone" xmlns="http://www.topografix.com/GPX/1/1">
          <trk>
            <name>\(activity.type.rawValue) - \(iso.string(from: activity.startDate))</name>
            <trkseg>

        """

        for point in activity.route.sorted(by: { $0.timestamp < $1.timestamp }) {
            gpx += """
                <trkpt lat="\(point.latitude)" lon="\(point.longitude)">
                  <ele>\(point.altitude)</ele>
                  <time>\(iso.string(from: point.timestamp))</time>
                </trkpt>

            """
        }

        gpx += """
            </trkseg>
          </trk>
        </gpx>
        """

        let fileName = "activity-\(activity.startDate.timeIntervalSince1970).gpx"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try gpx.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("GPX export hatası: \(error)")
            return nil
        }
    }
}
