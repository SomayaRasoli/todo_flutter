# Yapılacak işler uygulaması Uygulaması 📝

Firebase entegrasyonu, kullanıcı kimlik doğrulaması, takvim görünümü ve yerel bildirimler içeren zengin özellikli bir Flutter yapılacaklar listesi uygulaması.

## Özellikler ✨

- 🔐 **Kullanıcı Kimlik Doğrulama** - Firebase Authentication ile güvenli giriş ve kayıt
- 📝 **Görev Yönetimi** - Görevleri kolayca oluşturma, okuma, güncelleme ve silme
- ✅ **Görev Tamamlama** - Görevleri tamamlandı/tamamlanmadı olarak işaretleme
- 📅 **Takvim Görünümü** - Görevleri takvim arayüzünde görselleştirme
- 🔔 **Yerel Bildirimler** - Görevleriniz için doğru zamanda hatırlatma alın
- ☁️ **Bulut Senkronizasyonu** - Firebase Firestore ile gerçek zamanlı veri senkronizasyonu
- 🎨 **Modern Arayüz** - Temiz ve sezgisel Material Design 3 arayüzü


## Teknoloji Yığını 🛠️

- **Framework:** Flutter 3.10.3
- **Durum Yönetimi:** Provider
- **Backend:** Firebase (Authentication + Firestore)
- **Takvim:** table_calendar
- **Bildirimler:** flutter_local_notifications
- **Arayüz:** Material Design 3

### Ana Bağımlılıklar

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.1
  table_calendar: ^3.1.2
  flutter_local_notifications: ^18.0.1
  provider: ^6.1.2
  intl: ^0.19.0
  timezone: ^0.9.4
```

## Başlangıç 🚀

### Ön Gereksinimler

- Flutter SDK (3.10.3 veya üzeri)
- Dart SDK
- Firebase hesabı
- Android Studio / Xcode (mobil geliştirme için)

### Kurulum

1. **Depoyu klonlayın**
   ```bash
   git clone https://github.com/SomayaRasoli/todo_flutter.git
   cd todo_flutter
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Firebase Kurulumu**
   
   - [Firebase Console](https://console.firebase.google.com/)'da yeni bir Firebase projesi oluşturun
   - **Authentication**'ı etkinleştirin (Email/Password sağlayıcısı)
   - **Cloud Firestore** veritabanını etkinleştirin
   - Yapılandırma dosyalarını indirin:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Yapılandırma için FlutterFire CLI'yi çalıştırın:
     ```bash
     flutterfire configure
     ```

4. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## Proje Yapısı 📂

```
lib/
├── main.dart                      # Uygulama giriş noktası
├── firebase_options.dart          # Firebase yapılandırması
├── models/
│   └── todo_model.dart           # Todo veri modeli
├── providers/
│   └── todo_provider.dart        # Durum yönetimi
├── screens/
│   ├── login_screen.dart         # Giriş arayüzü
│   ├── register_screen.dart      # Kayıt arayüzü
│   ├── home_screen.dart          # Ana navigasyon
│   ├── todo_list_screen.dart     # Görev listesi görünümü
│   ├── calendar_screen.dart      # Takvim görünümü
│   └── add_edit_todo_screen.dart # Görev oluşturma/düzenleme
└── services/
    ├── auth_service.dart         # Kimlik doğrulama mantığı
    ├── database_service.dart     # Firestore işlemleri
    ├── notification_service.dart # Bildirim yönetimi
    └── task_monitor_service.dart # Görev izleme
```

## Kullanım 💡

### Kimlik Doğrulama
1. E-posta ve şifre ile yeni bir hesap oluşturun
2. Kimlik bilgilerinizle giriş yapın
3. Oturumunuz çıkış yapana kadar devam eder

### Görev Yönetimi
- **Görev Ekle:** '+' butonuna dokunun, detayları doldurun (başlık, açıklama, tarih, saat)
- **Görev Düzenle:** Detaylarını düzenlemek için bir göreve dokunun
- **Görev Tamamla:** Görevin yanındaki onay kutusunu işaretleyin/işareti kaldırın
- **Görev Sil:** Kaydırın veya silme butonunu kullanın

### Takvim Görünümü
- Alt gezinmeden takvim görünümüne geçin
- Belirli tarihlerdeki görevleri görün
- Görsel göstergeler günlük görev yoğunluğunu gösterir

### Bildirimler
- İstendiğinde bildirim izinlerini verin
- Görevler planlanmış zamanlarında bildirim tetikler
- Bildirimler uygulama kapalıyken bile çalışır

## Firebase Yapılandırması 🔥

### Firestore Veritabanı Yapısı

```
users/{userId}/todos/{todoId}
  ├── title: string
  ├── description: string
  ├── isCompleted: boolean
  ├── date: Timestamp
  └── createdAt: Timestamp
```

### Güvenlik Kuralları (Önerilen)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/todos/{todoId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Üretim için Derleme 🏗️

### Android
```bash
flutter build apk --release
# veya
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Sorun Giderme 🔧

### Yaygın Sorunlar

1. **Firebase başlatılmadı**
   - `flutterfire configure` komutunun çalıştırıldığından emin olun
   - `firebase_options.dart` dosyasının var olduğunu kontrol edin

2. **Bildirimler çalışmıyor**
   - İzinlerin verildiğini doğrulayın
   - Timezone paketinin düzgün yapılandırıldığını kontrol edin
   - Bildirim servisinin `main.dart`'ta başlatıldığından emin olun

3. **Derleme hataları**
   - `flutter clean && flutter pub get` komutunu çalıştırın
   - Flutter ve Dart SDK sürümlerini kontrol edin
   - Tüm bağımlılıkların uyumlu olduğunu doğrulayın

## Katkıda Bulunma 🤝

Katkılarınızı bekliyoruz! Lütfen bir Pull Request göndermekten çekinmeyin.

## Lisans 📄

Bu proje eğitim ve kişisel kullanım için mevcuttur.

## İletişim 📧

Sorularınız veya geri bildirimleriniz için lütfen depoda bir issue açın.

---

**Flutter ile ❤️ ile geliştirildi**
