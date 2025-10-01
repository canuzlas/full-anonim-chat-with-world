# 🔥 Firebase Kurulum Rehberi

Bu belge, Anonim Chat uygulaması için Firebase kurulumunu adım adım açıklar.

## 1️⃣ Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. "Add Project" veya "Proje Ekle" butonuna tıklayın
3. Proje adını girin (örn: "anonim-chat")
4. Google Analytics'i isteğe bağlı olarak etkinleştirin
5. Projeyi oluşturun

## 2️⃣ Firebase Authentication Kurulumu

1. Firebase Console'da projenizi açın
2. Sol menüden **Build > Authentication** seçin
3. "Get Started" butonuna tıklayın
4. **Sign-in method** sekmesine gidin
5. **Anonymous** satırını bulun ve aktif edin
6. "Enable" (Etkinleştir) toggle'ını açın
7. "Save" (Kaydet) butonuna tıklayın

✅ Anonim kimlik doğrulama artık aktif!

## 3️⃣ Cloud Firestore Kurulumu

1. Sol menüden **Build > Firestore Database** seçin
2. "Create database" butonuna tıklayın
3. **Start in test mode** seçeneğini seçin (geçici)
4. Location seçin (örn: europe-west)
5. "Enable" butonuna tıklayın

### Firestore Security Rules Yükleme

1. Firebase Console'da **Firestore Database > Rules** sekmesine gidin
2. Proje kök dizinindeki `firestore.rules` dosyasının içeriğini kopyalayın
3. Rules editörüne yapıştırın
4. "Publish" butonuna tıklayın

Veya Firebase CLI ile:
```bash
firebase deploy --only firestore:rules
```

## 4️⃣ Platform Kurulumları

### 📱 Android Kurulumu

1. Firebase Console'da Android simgesine tıklayın
2. Android package name girin (örn: `com.example.anonimchat`)
   - `android/app/build.gradle` dosyasındaki `applicationId` ile aynı olmalı
3. "Register app" butonuna tıklayın
4. `google-services.json` dosyasını indirin
5. İndirilen dosyayı `android/app/` klasörüne kopyalayın
6. Gerekli gradle bağımlılıklarını ekleyin (genellikle otomatik):

`android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

`android/app/build.gradle`:
```gradle
plugins {
    id 'com.android.application'
    id 'com.google.gms.google-services'
}
```

### 🍎 iOS Kurulumu

1. Firebase Console'da iOS simgesine tıklayın
2. iOS bundle ID girin (örn: `com.example.anonimchat`)
   - Xcode'da `ios/Runner.xcodeproj` > Runner > General > Bundle Identifier
3. "Register app" butonuna tıklayın
4. `GoogleService-Info.plist` dosyasını indirin
5. Xcode'da `ios/Runner` klasörüne sürükleyip bırakın
   - ✅ "Copy items if needed" seçeneğini işaretleyin
   - ✅ "Runner" target'ını seçin

### 🌐 Web Kurulumu

1. Firebase Console'da Web simgesine (</>) tıklayın
2. App nickname girin
3. Firebase config bilgilerini kopyalayın
4. `web/index.html` dosyasını açın
5. `</body>` etiketinden önce ekleyin:

```html
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
  import { getAuth } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js";
  import { getFirestore } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js";

  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
  };

  const app = initializeApp(firebaseConfig);
</script>
```

## 5️⃣ Firebase CLI Kurulumu (Opsiyonel)

Firebase CLI, rules ve functions yönetimi için kullanışlıdır.

```bash
# Node.js yüklü olmalı
npm install -g firebase-tools

# Firebase'e giriş yapın
firebase login

# Proje dizininde Firebase'i başlatın
firebase init

# Firestore ve Functions seçin
# Mevcut projenizi seçin
```

## 6️⃣ Test & Doğrulama

### Flutter Projesini Çalıştırın
```bash
flutter clean
flutter pub get
flutter run
```

### Firebase Bağlantısını Kontrol Edin

1. Uygulamayı açın
2. Ana ekran görünmelidir
3. Firebase Console > Authentication > Users
   - Yeni bir anonim kullanıcı görünmelidir

4. "Yeni Oda Oluştur" butonuna tıklayın
5. Oda oluşturun
6. Firebase Console > Firestore Database > Data
   - `rooms` koleksiyonunda yeni oda görünmelidir

## 🔒 Güvenlik Kontrolleri

### ✅ Yapılması Gerekenler

1. **Production'da Test Mode Kapatın**
   - Firestore Rules'ı production için güncelleyin
   - `firestore.rules` dosyasındaki kurallar zaten güvenli

2. **API Key Güvenliği**
   - Firebase API keys public olabilir (Firebase'in tasarımı böyle)
   - Güvenlik Firestore Rules ile sağlanır
   - Ancak sensitive data varsa environment variables kullanın

3. **Firestore Indexes**
   - Büyük veri setlerinde performans için indexes oluşturun
   - Firebase otomatik önerir

## 🆘 Sık Karşılaşılan Sorunlar

### "Default FirebaseApp is not initialized"
**Çözüm:** `main.dart` içinde `await Firebase.initializeApp();` çalıştırıldığından emin olun.

### Android'de Google Services hatası
**Çözüm:** 
- `google-services.json` dosyası `android/app/` içinde mi?
- Package name eşleşiyor mu?
- Gradle sync yapıldı mı?

### iOS'ta Firebase bağlanmıyor
**Çözüm:**
- `GoogleService-Info.plist` Xcode'da Runner target'ına eklenmiş mi?
- Bundle ID eşleşiyor mu?
- `pod install` çalıştırıldı mı?

## 📞 Destek

Firebase dokümantasyonu: https://firebase.google.com/docs

Flutter Firebase: https://firebase.flutter.dev

---

✨ Firebase kurulumu tamamlandı! Artık uygulamanızı kullanabilirsiniz.
