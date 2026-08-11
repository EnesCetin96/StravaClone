import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Activity.startDate, order: .reverse) private var activities: [Activity]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if activities.isEmpty {
                    ContentUnavailableView(
                        "Henüz aktivite yok",
                        systemImage: "figure.run",
                        description: Text("İlk koşunu veya bisiklet turunu kaydetmek için Kayıt sekmesine git.")
                    )
                } else {
                    List {
                        ForEach(activities) { activity in
                            NavigationLink {
                                ActivityDetailView(activity: activity)
                            } label: {
                                row(for: activity)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Geçmiş")
        }
    }

    private func row(for activity: Activity) -> some View {
        HStack {
            Image(systemName: activity.type.sfSymbol)
                .font(.title2)
                .frame(width: 36)
                .foregroundStyle(.tint)

            VStack(alignment: .leading) {
                Text(activity.type.rawValue).font(.headline)
                Text(activity.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "%.2f km", activity.distanceKm)).font(.subheadline.bold())
                Text(activity.durationString).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(activities[index])
        }
    }
}
