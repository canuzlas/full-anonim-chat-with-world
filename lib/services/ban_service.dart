import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../models/ban.dart';

class BanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Device ID alma
  Future<String?> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // iOS Vendor ID
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Kullanıcı banlandı mı kontrol et
  Future<bool> isBanned({
    required String roomId,
    required String userId,
    String? deviceId,
  }) async {
    try {
      // User ID ile kontrol
      var bansSnapshot = await _firestore
          .collection('bans')
          .where('userId', isEqualTo: userId)
          .where('roomId', isEqualTo: roomId)
          .where('isActive', isEqualTo: true)
          .get();

      // Geçerli bir ban var mı?
      for (var doc in bansSnapshot.docs) {
        final ban = Ban.fromFirestore(doc);
        if (ban.isValid) return true;
      }

      // Device ID ile kontrol (eğer varsa)
      if (deviceId != null) {
        bansSnapshot = await _firestore
            .collection('bans')
            .where('deviceId', isEqualTo: deviceId)
            .where('roomId', isEqualTo: roomId)
            .where('isActive', isEqualTo: true)
            .get();

        for (var doc in bansSnapshot.docs) {
          final ban = Ban.fromFirestore(doc);
          if (ban.isValid) return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Süresi dolan banları temizle
  Future<void> cleanExpiredBans() async {
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final bansSnapshot = await _firestore
          .collection('bans')
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isLessThan: now)
          .get();

      for (var doc in bansSnapshot.docs) {
        await doc.reference.update({'isActive': false});
      }
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // Kullanıcının tüm banlarını getir
  Stream<List<Ban>> getUserBans(String userId) {
    return _firestore
        .collection('bans')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Ban.fromFirestore(doc)).toList());
  }

  // Odanın tüm banlarını getir (admin için)
  Stream<List<Ban>> getRoomBans(String roomId) {
    return _firestore
        .collection('bans')
        .where('roomId', isEqualTo: roomId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Ban.fromFirestore(doc)).toList());
  }
}
