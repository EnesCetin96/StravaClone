import Foundation

enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case running = "Koşu"
    case cycling = "Bisiklet"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        }
    }

    /// CoreLocation'a bu aktivite için doğru hareket profilini söylüyoruz.
    /// Bu, GPS'in pil kullanımını ve doğruluğunu aktiviteye göre optimize etmesini sağlar.
    var clActivityType: Int {
        switch self {
        case .running: return 2 // CLActivityType.fitness
        case .cycling: return 1 // CLActivityType.automotiveNavigation'a yakın davranış istemiyoruz, fitness kullanacağız
        }
    }
}
