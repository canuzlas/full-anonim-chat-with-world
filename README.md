# 🔐 Anonim Chat - Tamamen Anonim & Şifrelenmiş Sohbet Uygulaması

Flutter + Firebase ile geliştirilmiş, tamamen anonim ve uçtan uca şifrelenebilir, admin/moderatör sistemi ve gelişmiş güvenlik özellikleri ile donatılmış profesyonel sohbet odaları uygulaması.

## ✨ Özellikler

### 🎭 Tamamen Anonim
- **Hesap oluşturma gerekmez** - Firebase Anonymous Authentication kullanır
- **Rastgele kullanıcı adları** - Otomatik oluşturulan benzersiz User#timestamp formatı
- **Kimlik bilgisi istenmez** - Email, telefon, isim vb. gerekmez
- **Kullanıcı adı kopyalama** - Kolay moderatör ataması için
- **İzlenme yok** - Minimal kullanıcı verisi

### 🔒 Güvenlik & Şifreleme
- **İki katmanlı şifreleme** - Tüm mesajlar app-level + oda-level şifreleme
- **AES-256 şifreleme** - Endüstri standardı güvenlik
- **Client-side encryption** - Mesajlar cihazda şifrelenir
- **Şifre korumalı odalar** - İsteğe bağlı oda şifreleme
- **Firestore Security Rules** - Production-ready güvenlik kuralları
- **Admin/Moderator/Ban kontrolü** - Firestore seviyesinde yetki kontrolü

### 👥 Admin & Moderasyon Sistemi
- **Otomatik admin ataması** - Oda oluştururken creator admin olur
- **Moderatör yönetimi** - Username ile moderatör atama/kaldırma
- **Kullanıcı yasaklama** - Permanent ve geçici ban sistemi
- **Mesaj moderasyonu** - Admin/mod mesaj silme yetkisi
- **Kullanıcı atma (Kick)** - Otomatik oda çıkışı
- **Yasaklılar listesi** - Yasak kaldırma ile birlikte
- **Admin mesajı koruması** - Moderatörler admin mesajlarını silemez

### 🛡️ Kullanıcı Kontrolleri
- **Engelleme sistemi** - Kullanıcıları engelleme/engel kaldırma
- **Engellenenler listesi** - Engellenen kullanıcıları yönetme
- **Ban kontrolü** - Real-time ban durumu dinleme
- **Otomatik odadan çıkış** - Kicklenince/ban yiyince otomatik çıkış
- **Mesaj filtreleme** - Engellenen kullanıcıların mesajları gizlenir

### 💬 Sohbet Özellikleri
- **Real-time mesajlaşma** - Anlık mesajlaşma
- **Global Chat Room** - Herkes için ortak oda
- **Özel oda oluşturma** - Şifreli veya açık odalar
- **Oda paylaşma** - Oda ID'si ile kolay paylaşım
- **Katıldığım odalar** - Odaları kaydetme ve hızlı erişim
- **Odadan çıkış** - İstediğiniz zaman odadan ayrılın
- **Username gösterimi** - Mesajlarda kullanıcı adı gösterimi
- **Tarih ayırıcıları** - Mesajlarda tarih gösterimi

### 🎨 UI/UX Özellikleri
- **Material 3 Design** - Modern ve şık tasarım
- **Dark/Light Theme Support** - (Planlanıyor)
- **Responsive Design** - Tüm ekran boyutlarına uyumlu
- **Long-press menüler** - Mesaj işlemleri için
- **Toast bildirimleri** - Başarı/hata mesajları
- **Loading states** - Kullanıcı dostu yükleme ekranları

## 🏗️ Teknoloji Stack

### Frontend
- **Flutter 3.x** - Cross-platform UI framework
- **Riverpod 2.6.1** - State management
- **Material 3** - Modern UI design

### Backend & Services
- **Firebase Authentication** - Anonim kimlik doğrulama
- **Cloud Firestore** - Real-time database
- **Firestore Security Rules** - Production-ready güvenlik
- **Firebase Storage** - (Gelecek özellikler için)

### Şifreleme & Güvenlik
- **encrypt 5.0.3** - AES-256 şifreleme
- **crypto 3.0.3** - SHA-256 hashing ve IV generation

### Yardımcı Paketler
- **uuid** - Benzersiz ID oluşturma
- **intl** - Tarih formatlaması
- **share_plus** - Oda paylaşımı
- **shared_preferences** - Yerel veri saklama
- **device_info_plus** - Cihaz bilgisi (gelecek özellikler için)
- **http** - API istekleri (gelecek özellikler için)

## 📁 Proje Yapısı

```
lib/
├── models/                 # Veri modelleri
│   ├── room.dart          # Oda modeli (admin, moderators, bannedUsers)
│   ├── message.dart       # Mesaj modeli (reportCount, isDeleted)
│   ├── user.dart          # Kullanıcı modeli (username)
│   ├── ban.dart           # Ban kaydı modeli
│   ├── block.dart         # Engelleme modeli
│   └── report.dart        # Şikayet modeli
├── services/              # İş mantığı servisleri
│   ├── auth_service.dart  # Kimlik doğrulama + username creation
│   ├── room_service.dart  # Oda yönetimi
│   ├── message_service.dart # Mesajlaşma + app-level encryption
│   ├── encryption_service.dart # İki katmanlı şifreleme
│   ├── admin_service.dart # Admin/moderatör işlemleri (9 fonksiyon)
│   ├── block_service.dart # Engelleme sistemi
│   ├── user_service.dart  # Username yönetimi
│   └── joined_rooms_service.dart # Katılınan odaları saklama
├── providers/             # Riverpod providers
│   └── providers.dart     # State management (20+ provider)
├── screens/               # UI ekranları
│   ├── home_screen.dart   # Ana sayfa + Engellenenler
│   ├── create_room_screen.dart # Oda oluşturma
│   ├── join_room_screen.dart # Oda katılma + Ban kontrolü
│   └── chat_screen.dart   # Mesajlaşma + Admin menü + Moderasyon
└── main.dart              # Ana uygulama + Firebase init
```

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Firebase CLI
- Android Studio / VS Code
- iOS için: Xcode (macOS)

### 1. Flutter SDK'yı yükleyin
```bash
flutter doctor
```

### 2. Projeyi klonlayın
```bash
git clone https://github.com/canuzlas/full-anonim-chat-with-world.git
cd anonimchat
```

### 3. Bağımlılıkları yükleyin
```bash
flutter pub get
```

### 4. Firebase Kurulumu

#### a. Firebase projesi oluşturun
- [Firebase Console](https://console.firebase.google.com/) üzerinden yeni proje oluşturun
- Analytics isteğe bağlı

#### b. Firebase Authentication'ı etkinleştirin
- Authentication > Sign-in method
- "Anonymous" seçeneğini etkinleştirin

#### c. Cloud Firestore'u oluşturun
- Firestore Database > Create database
- Production mode ile başlayın (güvenlik kurallarını daha sonra yükleyeceğiz)
- Lokasyon seçin (örn: europe-west1)

#### d. Firebase yapılandırma dosyalarını ekleyin

**UYARI: Bu dosyalar .gitignore'da! Kendi Firebase projenizden indirin:**

**Android için:**
```bash
# Firebase Console'dan google-services.json indirin
# Dosyayı buraya koyun: android/app/google-services.json
```

**iOS için:**
```bash
# Firebase Console'dan GoogleService-Info.plist indirin  
# Dosyayı buraya koyun: ios/Runner/GoogleService-Info.plist
```

**Web için:**
```html
<!-- web/index.html dosyasına Firebase config'i ekleyin -->
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js"></script>
<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

#### e. Firestore Security Rules'ı yükleyin
```bash
# Firebase CLI kurulumu (tek seferlik)
npm install -g firebase-tools
firebase login

# Firebase projesini başlat
firebase init firestore

# Güvenlik kurallarını yükle
firebase deploy --only firestore:rules
```

**firestore.rules dosyası production-ready güvenlik içerir:**
- Admin/Moderator yetki kontrolleri
- Ban kontrolleri
- Kullanıcı engelleme kontrolleri
- Mesaj silme yetkileri
- Oda yönetimi yetkileri

### 5. Uygulamayı çalıştırın
```bash
# Debug mode
flutter run

# Release mode (Android)
flutter run --release

# Specific device
flutter run -d chrome  # Web
flutter run -d emulator-5554  # Android emulator
```

## 🔐 Güvenlik Özellikleri

### İki Katmanlı Şifreleme Mimarisi

#### 1. App-Level Şifreleme (Tüm mesajlar)
```dart
// Sabit uygulama anahtarı ile tüm mesajlar şifrelenir
final encryptedText = encryptionService.encryptAppLevel(plainText);
// Firestore'a şifreli metin kaydedilir
```

#### 2. User-Level Şifreleme (Şifreli odalar)
```dart
// Kullanıcının belirlediği şifre ile ekstra şifreleme
final doubleEncrypted = encryptionService.encryptUserLevel(
  encryptedText, 
  userPassword
);
```

### Firestore Security Rules
```javascript
// Admin kontrolü
function isAdmin(roomId) {
  return request.auth.uid in get(/databases/$(database)/documents/rooms/$(roomId)).data.admins;
}

// Ban kontrolü
function isBanned(roomId) {
  return request.auth.uid in get(/databases/$(database)/documents/rooms/$(roomId)).data.bannedUsers;
}

// Mesaj okuma: Banlı değilse
allow read: if isAuthenticated() && !isBanned(roomId);

// Mesaj silme: Kendi mesajı veya admin/mod
allow delete: if isAuthenticated() && 
  (resource.data.senderId == request.auth.uid || isAdminOrModerator(roomId));
```

## 📱 Kullanım Kılavuzu

### Oda Oluşturma
1. Ana ekranda "Yeni Oda Oluştur" butonuna tıklayın
2. Oda adını girin (örn: "Proje Grubu")
3. **İsteğe bağlı:** "Oda Şifrele" anahtarını aktif edin
4. Şifre belirleyin (min. 6 karakter)
5. "Oda Oluştur" butonuna tıklayın
6. **Otomatik admin olursunuz**
7. Oda ID'sini ve şifreyi güvenli paylaşın

### Odaya Katılma
1. Ana ekranda "Odaya Katıl" butonuna tıklayın
2. Oda ID'sini yapıştırın
3. Eğer oda şifreliyse, şifreyi girin
4. **Ban kontrolü yapılır** - Yasaklıysanız giremezsiniz
5. Chat ekranına yönlendirilirsiniz

### Admin/Moderatör İşlemleri
1. **Admin menüsü** - Chat ekranında shield icon (🛡️)
2. **Moderatör ata:** Username girin (örn: User#12345678)
3. **Moderatör kaldır:** Username ile kaldırın
4. **Yasaklılar:** Liste göster + yasak kaldır
5. **Odayı sil:** Tüm kullanıcılar anasayfaya yönlendirilir

### Mesaj İşlemleri
1. **Mesajı sil:** Kendi mesajınızı sil (uzun bas)
2. **Mod silme:** Admin/mod başkasının mesajını sil
3. **Kullanıcı at:** Odadan atma (kick)
4. **Engelle:** Kullanıcıyı engelle (mesajları gizlenir)
5. **Şikayet et:** Mesajı raporla (gelecek)

### Engelleme Yönetimi
1. Ana sayfa → 🚫 Engellenenler butonu
2. Engellenen kullanıcılar listesi
3. ✅ Engeli kaldır butonu
4. Kullanıcı engellenince mesajları "[Engellenen kullanıcının mesajı]" olur

### Odadan Çıkış
1. Chat ekranı → ⋮ Menü → "Odadan Çık"
2. Onay ver
3. Oda "Katıldığım Odalar" sekmesinden silinir
4. Anasayfaya yönlendirilirsiniz

## 🔧 Geliştirici Notları

### Admin Service API
```dart
// Moderatör ekleme
await adminService.addModerator(
  roomId: 'room123',
  adminUserId: 'admin-uid',
  targetUserId: 'user-uid',
);

// Kullanıcı atma
await adminService.kickUser(
  roomId: 'room123',
  modUserId: 'mod-uid',
  targetUserId: 'user-uid',
  reason: 'Spam',
);

// Ban kaldırma
await adminService.unbanUser(
  roomId: 'room123',
  adminUserId: 'admin-uid',
  targetUserId: 'user-uid',
);
```

### Username Service API
```dart
// Kullanıcı oluştur/getir (otomatik username)
final user = await userService.getOrCreateUser(userId);

// Username'den userId bul
final userId = await userService.getUserByUsername('User#12345678');

// Username stream (real-time)
final usernameStream = userService.getUsernameStream(userId);
```

### Providers
```dart
// Ban durumu (Stream)
ref.watch(isBannedProvider((roomId: roomId, userId: userId)));

// Admin/Mod kontrolü
ref.watch(isAdminOrModeratorProvider((roomId: roomId, userId: userId)));

// Engellenen kullanıcılar (Stream)
ref.watch(blockedUsersProvider(userId));

// Username (Stream)
ref.watch(usernameProvider(userId));
```

## 🛠️ Test & Debug

### Test
```bash
# Unit testler
flutter test

# Widget testler
flutter test test/widget_test.dart

# Integration testler
flutter drive --target=test_driver/app.dart
```

### Debug
```bash
# Debug logs
flutter logs

# Firebase debug
firebase emulators:start

# Firestore rules test
firebase emulators:exec --only firestore "flutter test"
```

### Build

```bash
# Android APK (Debug)
flutter build apk --debug

# Android APK (Release)
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle

# iOS (Release)
flutter build ios --release

# Web
flutter build web --release
```

## 🚀 Deployment

### Android (Google Play)
1. `android/key.properties` oluşturun (signing için)
2. `flutter build appbundle`
3. `build/app/outputs/bundle/release/app-release.aab` dosyasını yükleyin

### iOS (App Store)
1. Xcode'da signing ayarlarını yapın
2. `flutter build ios --release`
3. Archive & Upload to App Store

### Web (Firebase Hosting)
```bash
flutter build web --release
firebase init hosting
firebase deploy --only hosting
```

## 🎯 Gelecek Özellikler (Roadmap)

### Yakın Gelecek
- [x] Admin/Moderator sistemi
- [x] Ban/Kick sistemi
- [x] Engelleme sistemi
- [x] Username sistemi
- [x] Odadan çıkış
- [ ] Mesaj raporlama (Report sistemi tamamlanacak)
- [ ] AI içerik moderasyonu
- [ ] Device ID tracking
- [ ] IP address tracking

### Orta Vadeli
- [ ] Push notifications (FCM)
- [ ] Mesaj düzenleme
- [ ] Mesaj yanıtlama (reply)
- [ ] Mesaj reactions (emoji)
- [ ] Typing indicator
- [ ] Online/offline status
- [ ] Read receipts
- [ ] Dark mode

### Uzun Vadeli
- [ ] Dosya/resim paylaşımı (Firebase Storage)
- [ ] Ses mesajları
- [ ] Video arama (WebRTC)
- [ ] Ses arama
- [ ] Random anonim avatarlar
- [ ] Oda kategorileri
- [ ] Oda arama/filtreleme
- [ ] Oda istatistikleri

## 🤝 Katkıda Bulunma

1. Fork edin (`https://github.com/canuzlas/full-anonim-chat-with-world/fork`)
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

### Katkıda Bulunma Kuralları
- Kod formatını koruyun (`flutter format .`)
- Lint hatalarını düzeltin (`flutter analyze`)
- Testler ekleyin
- README'yi güncelleyin
- Commit mesajlarını açıklayıcı yazın

## 📄 Lisans

Bu proje MIT lisansı altındadır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🙏 Teşekkürler

- **Flutter Team** - Amazing framework
- **Firebase Team** - Backend infrastructure
- **Riverpod Community** - State management
- **encrypt paketi** - Güvenli şifreleme
- **Tüm katkıda bulunanlar** - Teşekkürler!

## 📞 İletişim

- **GitHub:** [@canuzlas](https://github.com/canuzlas)
- **Repository:** [full-anonim-chat-with-world](https://github.com/canuzlas/full-anonim-chat-with-world)

---

**⚠️ GÜVENLİK NOTU:**
- Firebase yapılandırma dosyaları `.gitignore`'da
- `google-services.json` ve `GoogleService-Info.plist` asla commit etmeyin
- Production kullanımı için ek güvenlik önlemleri alın
- API anahtarlarını environment variables'da saklayın
- Firestore rules'ı düzenli olarak gözden geçirin

**💡 ÖNEMLİ:** 
Bu uygulama production-ready durumda ancak ölçeklenebilirlik için Cloud Functions ve rate limiting eklenmesi önerilir.

---

**Made with ❤️ using Flutter & Firebase**

## ✨ Özellikler

### 🎭 Tamamen Anonim
- **Hesap oluşturma gerekmez** - Firebase Anonymous Authentication kullanır
- **Kimlik bilgisi istenmez** - Email, telefon, isim vb. gerekmez
- **İzlenme yok** - Kullanıcı verisi saklanmaz

### 🔒 Güvenlik & Şifreleme
- **Uçtan uca şifreleme** - AES-256 ile mesajlar cihazda şifrelenir
- **Client-side encryption** - Mesajlar Firebase'e şifreli olarak gönderilir
- **Şifre korumalı odalar** - İsteğe bağlı oda şifreleme
- **Firestore Security Rules** - Sıkı güvenlik kuralları

### 💬 Özel Sohbet Odaları
- **Oda oluşturma** - Kolayca yeni özel odalar oluşturun
- **Oda paylaşma** - Oda ID'si ve şifre ile paylaşın
- **Real-time mesajlaşma** - Anlık mesajlaşma
- **Çoklu platform** - Android, iOS, Web desteği

## 🏗️ Teknoloji Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **Material 3** - Modern UI design

### Backend & Services
- **Firebase Authentication** - Anonim kimlik doğrulama
- **Cloud Firestore** - Real-time database
- **Firestore Security Rules** - Veri güvenliği

### Şifreleme
- **encrypt** paketi - AES şifreleme
- **crypto** paketi - SHA-256 hashing

## 📁 Proje Yapısı

```
lib/
├── models/                 # Veri modelleri
│   ├── room.dart          # Oda modeli
│   └── message.dart       # Mesaj modeli
├── services/              # İş mantığı servisleri
│   ├── auth_service.dart  # Kimlik doğrulama
│   ├── room_service.dart  # Oda yönetimi
│   ├── message_service.dart # Mesajlaşma
│   └── encryption_service.dart # Şifreleme
├── providers/             # Riverpod providers
│   └── providers.dart     # State management
├── screens/               # UI ekranları
│   ├── home_screen.dart
│   ├── create_room_screen.dart
│   ├── join_room_screen.dart
│   └── chat_screen.dart
└── main.dart              # Ana uygulama
```

## 🚀 Kurulum

### 1. Flutter SDK'yı yükleyin
```bash
flutter doctor
```

### 2. Projeyi klonlayın
```bash
git clone <repository-url>
cd anonimchat
```

### 3. Bağımlılıkları yükleyin
```bash
flutter pub get
```

### 4. Firebase Kurulumu

#### a. Firebase projesi oluşturun
- [Firebase Console](https://console.firebase.google.com/) üzerinden yeni proje oluşturun

#### b. Firebase Authentication'ı etkinleştirin
- Authentication > Sign-in method
- "Anonymous" seçeneğini etkinleştirin

#### c. Cloud Firestore'u oluşturun
- Firestore Database > Create database
- Test mode ile başlayın

#### d. Firestore Security Rules'ı yükleyin
```bash
firebase deploy --only firestore:rules
```

#### e. Firebase yapılandırma dosyalarını ekleyin
- Android için: `android/app/google-services.json`
- iOS için: `ios/Runner/GoogleService-Info.plist`
- Web için: Firebase config'i `web/index.html`'e ekleyin

### 5. Uygulamayı çalıştırın
```bash
flutter run
```

## 🔐 Güvenlik Özellikleri

### Şifreleme Mimarisi
1. **Mesaj Gönderme:**
   - Kullanıcı mesajı yazar
   - Mesaj cihazda AES-256 ile şifrelenir
   - Şifreli metin Firestore'a kaydedilir
   - Server düz metni asla görmez

2. **Mesaj Okuma:**
   - Şifreli mesaj Firestore'dan çekilir
   - Kullanıcının şifresi ile çözülür
   - Yalnızca doğru şifreye sahip olanlar okuyabilir

### Firestore Security Rules
- Yalnızca authenticated kullanıcılar erişebilir
- Kullanıcılar sadece kendi mesajlarını silebilir
- Oda sahipleri odalarını yönetebilir
- Mesajlar güncellenemez (immutable)

## 📱 Kullanım

### Oda Oluşturma
1. Ana ekranda "Yeni Oda Oluştur" butonuna tıklayın
2. Oda adını girin
3. İsteğe bağlı: Şifreleme aktif edin ve şifre belirleyin
4. "Oda Oluştur" butonuna tıklayın
5. Oda ID'sini ve şifreyi paylaşın

### Odaya Katılma
1. Ana ekranda "Odaya Katıl" butonuna tıklayın
2. Oda ID'sini girin
3. Eğer oda şifreliyse, şifreyi girin
4. Chat ekranına yönlendirileceksiniz

### Mesajlaşma
- Mesajlar gerçek zamanlı olarak görünür
- Şifreli odalarda mesajlar otomatik olarak şifrelenir/çözülür
- Sadece doğru şifreye sahip olanlar mesajları okuyabilir

## 🛠️ Geliştirme

### Ek Özellikler (Gelecek)
- [ ] Push notifications (FCM)
- [ ] Mesaj silme özelliği
- [ ] Otomatik oda silme (zamanlayıcı)
- [ ] Dosya/resim paylaşımı
- [ ] Ses mesajları
- [ ] Random anonim avatarlar
- [ ] Dark mode

### Test
```bash
flutter test
```

### Build
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altındadır.

## 🙏 Teşekkürler

- Flutter Team
- Firebase Team
- Riverpod Community
- encrypt paketi geliştiricileri

---

**⚠️ Güvenlik Notu:** Bu uygulama eğitim amaçlıdır. Production kullanımı için ek güvenlik önlemleri almanız önerilir.
