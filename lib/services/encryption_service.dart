import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:crypto/crypto.dart';

class EncryptionService {
  // APP-LEVEL şifreleme key'i (tüm mesajlar için)
  // Production'da bu key'i güvenli bir yerde saklamalısınız (örn: Firebase Remote Config)
  static const String _appLevelKey = 'anonimchat-secure-key-2025-v1';

  // AES şifreleme için key oluştur (UTF-8 uyumlu)
  static encrypt_pkg.Key _generateKey(String password) {
    // Şifreyi 32 byte'lık bir key'e dönüştür
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    // Hash bytes'ını direkt kullan (32 byte)
    return encrypt_pkg.Key(Uint8List.fromList(hash.bytes));
  }

  // IV (Initialization Vector) oluştur - SABİT
  static encrypt_pkg.IV _generateIV() {
    // Sabit bir IV kullanıyoruz (16 byte sıfır)
    // Production'da random olmalı ve mesajla birlikte saklanmalı
    return encrypt_pkg.IV(Uint8List.fromList(List<int>.filled(16, 0)));
  }

  // Metni şifrele
  static String encryptText(String plainText, String password) {
    try {
      final key = _generateKey(password);
      final iv = _generateIV();
      final encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(key));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Şifreleme hatası: $e');
    }
  }

  // Şifreli metni çöz
  static String decryptText(String encryptedText, String password) {
    try {
      final key = _generateKey(password);
      final iv = _generateIV();
      final encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(key));

      // Base64 string'i Encrypted objesine çevir
      final encrypted = encrypt_pkg.Encrypted.fromBase64(encryptedText);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      throw Exception('Şifre çözme hatası: Yanlış şifre veya bozuk veri');
    }
  }

  // Şifre hash'i oluştur (doğrulama için)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Şifreyi doğrula
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  // APP-LEVEL Encryption (tüm mesajlar için)
  // Uygulama dışında mesajların okunamaması için
  static String encryptAppLevel(String plainText) {
    return encryptText(plainText, _appLevelKey);
  }

  static String decryptAppLevel(String encryptedText) {
    return decryptText(encryptedText, _appLevelKey);
  }
}
