# StravaClone

![Build Status](https://github.com/EnesCetin96/StravaClone/actions/workflows/ci.yml/badge.svg)

Kişisel kullanım için basit koşu/bisiklet takip uygulaması. Swift + SwiftUI + CoreLocation + SwiftData ile yazıldı, harici bağımlılık yok (CocoaPods/SPM paketi gerekmiyor).

## Nasıl kurulur

1. **Xcode'da yeni proje aç**: File → New → Project → iOS → App
   - Product Name: `StravaClone`
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Minimum Deployment: iOS 17.0 veya üstü (iPhone 16 Pro zaten iOS 18 ile geliyor, sorun olmaz)

2. Xcode'un otomatik oluşturduğu `StravaCloneApp.swift`, `ContentView.swift` ve `Item.swift` dosyalarını sil.

3. Bu klasördeki tüm `.swift` dosyalarını (Models/, Services/, Views/, App/) sürükle-bırak ile Xcode projene ekle. "Copy items if needed" işaretli olsun.

4. **Info.plist / Signing & Capabilities ayarları** (çok önemli, bunlar olmadan konum izni istemez ve arka planda kayıt durur):
   - Target → Signing & Capabilities → **+ Capability** → **Background Modes** → "Location updates" kutucuğunu işaretle.
   - Target → Info sekmesine şu iki key'i ekle (Custom iOS Target Properties):
     - `Privacy - Location When In Use Usage Description` → örn: "Koşu ve bisiklet rotanı kaydetmek için konumuna ihtiyacım var."
     - `Privacy - Location Always and When In Use Usage Description` → örn: "Uygulama arka plandayken de rotanı kaydetmeye devam edebilmek için."

5. Kendi Apple Developer hesabınla (ücretsiz hesap da olur) fiziksel iPhone 16 Pro'na deploy et — GPS simülatörde gerçekçi çalışmaz, gerçek cihazda test etmen gerekir.

## Nasıl çalışır

- **StartTrackingView**: Koşu/Bisiklet seç, "Başla" de.
- **LocationTracker**: `CLLocationManager` ile GPS noktalarını dinler, kötü doğruluktaki ve gerçekçi olmayan hız sıçraması gösteren noktaları eler, kümülatif mesafeyi hesaplar.
- **TrackingView**: Canlı harita üzerinde rotanı çizer, mesafe/süre/hız gösterir. "Durdur ve Kaydet" ile aktivite SwiftData'ya kaydedilir.
- **HistoryView / ActivityDetailView**: Geçmiş aktiviteleri listeler, haritada rotayı tekrar gösterir.
- **GPXExporter**: Herhangi bir aktiviteyi standart `.gpx` dosyasına çevirir — bu dosyayı AirDrop/paylaş ile Google Maps, Google Earth, Strava gibi uygulamalara aktarabilirsin (GPX, Google Maps'in içe aktarabildiği evrensel bir format).

## Sonraki adımlar (istersen)

- **Duraklat/devam et** özelliği (şu an sadece başla/durdur var)
- **Apple Watch companion app** — bileğinden başlatıp telefonu cebinde bırakmak için
- **HealthKit entegrasyonu** — kalori, kalp atışı
- **Gerçek Google Maps SDK'sı** — eğer native MapKit yerine birebir Google Maps görünümü istersen (CocoaPods/SPM ile `GoogleMaps` paketi + API key gerekir)
- **iCloud senkronizasyonu** — SwiftData zaten CloudKit ile kolayca senkronize edilebilir, birden fazla cihazda görmek istersen

## Lisans önerisi (GitHub için)

Kişisel/açık kaynak bir proje için MIT lisansı genelde en pratik seçimdir — istersen ekleyebilirim.
