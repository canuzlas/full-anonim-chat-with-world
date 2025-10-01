#!/bin/bash

# Firebase FlutterFire CLI Kurulum Script
# Bu script Firebase yapılandırmasını otomatik olarak ayarlar

echo "🔥 Firebase FlutterFire CLI Kurulumu Başlıyor..."
echo ""

# 1. FlutterFire CLI'yi yükle
echo "📦 FlutterFire CLI yükleniyor..."
dart pub global activate flutterfire_cli

echo ""
echo "✅ FlutterFire CLI yüklendi!"
echo ""

# 2. Kullanıcıya talimatlar
echo "🎯 Şimdi Firebase projenizi yapılandırmak için şu komutu çalıştırın:"
echo ""
echo "   flutterfire configure"
echo ""
echo "Bu komut:"
echo "  - Firebase projelerinizi listeler"
echo "  - Proje seçmenizi ister"
echo "  - Tüm platformlar için otomatik yapılandırma yapar"
echo "  - firebase_options.dart dosyasını oluşturur"
echo ""
echo "Hazır olduğunuzda yukarıdaki komutu çalıştırın! 🚀"
