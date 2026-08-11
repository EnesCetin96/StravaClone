import SwiftUI

struct StartTrackingView: View {
    @State private var selectedType: ActivityType = .running
    @State private var showTracking = false
    @StateObject private var tracker = LocationTracker()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Picker("Aktivite", selection: $selectedType) {
                    ForEach(ActivityType.allCases) { type in
                        Label(type.rawValue, systemImage: type.sfSymbol).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Image(systemName: selectedType.sfSymbol)
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)

                Button {
                    tracker.requestPermission()
                    showTracking = true
                } label: {
                    Text("Başla")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Yeni Aktivite")
            .fullScreenCover(isPresented: $showTracking) {
                TrackingView(activityType: selectedType, tracker: tracker)
            }
        }
    }
}

#Preview {
    StartTrackingView()
}
