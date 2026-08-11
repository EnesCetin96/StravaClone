import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            StartTrackingView()
                .tabItem { Label("Kayıt", systemImage: "record.circle") }

            HistoryView()
                .tabItem { Label("Geçmiş", systemImage: "list.bullet") }
        }
    }
}

#Preview {
    ContentView()
}
