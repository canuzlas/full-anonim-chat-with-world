import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import '../models/ban.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yetki kontrol metodları
  Future<bool> isAdmin(String roomId, String userId) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) return false;
      
      final room = Room.fromFirestore(roomDoc);
      return room.isAdmin(userId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isModerator(String roomId, String userId) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) return false;
      
      final room = Room.fromFirestore(roomDoc);
      return room.isModerator(userId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> isAdminOrModerator(String roomId, String userId) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) return false;
      
      final room = Room.fromFirestore(roomDoc);
      return room.isAdminOrModerator(userId);
    } catch (e) {
      return false;
    }
  }

  // Admin: Moderator atama (sadece admin yapabilir)
  Future<void> addModerator({
    required String roomId,
    required String adminUserId,
    required String targetUserId,
  }) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı');
      }

      final room = Room.fromFirestore(roomDoc);
      
      // Yetki kontrolü
      if (!room.isAdmin(adminUserId)) {
        throw Exception('Bu işlem için admin olmalısınız');
      }

      // Zaten moderator mu?
      if (room.isModerator(targetUserId)) {
        throw Exception('Kullanıcı zaten moderator');
      }

      // Moderator ekle
      final newModerators = List<String>.from(room.moderators)..add(targetUserId);
      await _firestore.collection('rooms').doc(roomId).update({
        'moderators': newModerators,
      });
    } catch (e) {
      throw Exception('Moderator eklenemedi: $e');
    }
  }

  // Admin: Moderator kaldırma
  Future<void> removeModerator({
    required String roomId,
    required String adminUserId,
    required String targetUserId,
  }) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı');
      }

      final room = Room.fromFirestore(roomDoc);
      
      // Yetki kontrolü
      if (!room.isAdmin(adminUserId)) {
        throw Exception('Bu işlem için admin olmalısınız');
      }

      // Moderator kaldır
      final newModerators = List<String>.from(room.moderators)
        ..remove(targetUserId);
      await _firestore.collection('rooms').doc(roomId).update({
        'moderators': newModerators,
      });
    } catch (e) {
      throw Exception('Moderator kaldırılamadı: $e');
    }
  }

  // Admin/Moderator: Kullanıcıyı odadan atma
  Future<void> kickUser({
    required String roomId,
    required String modUserId,
    required String targetUserId,
    String? reason,
  }) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı');
      }

      final room = Room.fromFirestore(roomDoc);
      
      // Yetki kontrolü (admin veya moderator)
      if (!room.isAdminOrModerator(modUserId)) {
        throw Exception('Bu işlem için admin veya moderator olmalısınız');
      }

      // Kullanıcıyı ban listesine ekle
      final newBannedUsers = List<String>.from(room.bannedUsers)
        ..add(targetUserId);
      await _firestore.collection('rooms').doc(roomId).update({
        'bannedUsers': newBannedUsers,
      });

      // Ban kaydı oluştur
      final ban = Ban(
        banId: '',
        userId: targetUserId,
        roomId: roomId,
        bannedBy: modUserId,
        reason: reason ?? 'Odadan atıldı',
        bannedAt: DateTime.now(),
      );

      await _firestore.collection('bans').add(ban.toFirestore());
    } catch (e) {
      throw Exception('Kullanıcı atılamadı: $e');
    }
  }

  // Admin/Moderator: Mesaj silme
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
    required String modUserId,
  }) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı');
      }

      final room = Room.fromFirestore(roomDoc);
      
      // Yetki kontrolü (admin veya moderator)
      if (!room.isAdminOrModerator(modUserId)) {
        throw Exception('Bu işlem için admin veya moderator olmalısınız');
      }

      // Mesajı sil
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Mesaj silinemedi: $e');
    }
  }

  // Admin: Oda silme (sadece admin yapabilir)
  Future<void> deleteRoom({
    required String roomId,
    required String adminUserId,
  }) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı');
      }

      final room = Room.fromFirestore(roomDoc);
      
      // Yetki kontrolü
      if (!room.isAdmin(adminUserId)) {
        throw Exception('Bu işlem için admin olmalısınız');
      }

      // Önce tüm mesajları sil
      final messagesSnapshot = await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .get();
      
      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Sonra odayı sil
      await _firestore.collection('rooms').doc(roomId).delete();
    } catch (e) {
      throw Exception('Oda silinemedi: $e');
    }
  }

  // Admin: Kullanıcıyı banlama (permanent)
  Future<void> banUserPermanently({
    required String roomId,
    required String adminUserId,
    required String targetUserId,
    required String reason,
    String? deviceId,
    String? ipAddress,
  }) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı');
      }

      final room = Room.fromFirestore(roomDoc);
      
      // Yetki kontrolü
      if (!room.isAdmin(adminUserId)) {
        throw Exception('Bu işlem için admin olmalısınız');
      }

      // Kullanıcıyı ban listesine ekle
      final newBannedUsers = List<String>.from(room.bannedUsers)
        ..add(targetUserId);
      await _firestore.collection('rooms').doc(roomId).update({
        'bannedUsers': newBannedUsers,
      });

      // Permanent ban kaydı oluştur
      final ban = Ban(
        banId: '',
        userId: targetUserId,
        deviceId: deviceId,
        ipAddress: ipAddress,
        roomId: roomId,
        bannedBy: adminUserId,
        reason: reason,
        bannedAt: DateTime.now(),
        expiresAt: null, // Permanent
      );

      await _firestore.collection('bans').add(ban.toFirestore());
    } catch (e) {
      throw Exception('Kullanıcı banlanamadı: $e');
    }
  }

  // Admin: Kullanıcıyı geçici banlama
  Future<void> banUserTemporary({
    required String roomId,
    required String adminUserId,
    required String targetUserId,
    required String reason,
    required Duration duration,
    String? deviceId,
    String? ipAddress,
  }) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı');
      }

      final room = Room.fromFirestore(roomDoc);
      
      // Yetki kontrolü
      if (!room.isAdmin(adminUserId)) {
        throw Exception('Bu işlem için admin olmalısınız');
      }

      // Kullanıcıyı ban listesine ekle
      final newBannedUsers = List<String>.from(room.bannedUsers)
        ..add(targetUserId);
      await _firestore.collection('rooms').doc(roomId).update({
        'bannedUsers': newBannedUsers,
      });

      // Geçici ban kaydı oluştur
      final ban = Ban(
        banId: '',
        userId: targetUserId,
        deviceId: deviceId,
        ipAddress: ipAddress,
        roomId: roomId,
        bannedBy: adminUserId,
        reason: reason,
        bannedAt: DateTime.now(),
        expiresAt: DateTime.now().add(duration),
      );

      await _firestore.collection('bans').add(ban.toFirestore());
    } catch (e) {
      throw Exception('Kullanıcı banlanamadı: $e');
    }
  }

  // Ban kaldırma
  Future<void> unbanUser({
    required String roomId,
    required String adminUserId,
    required String targetUserId,
  }) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Oda bulunamadı');
      }

      final room = Room.fromFirestore(roomDoc);
      
      // Yetki kontrolü
      if (!room.isAdmin(adminUserId)) {
        throw Exception('Bu işlem için admin olmalısınız');
      }

      // Kullanıcıyı ban listesinden çıkar
      final newBannedUsers = List<String>.from(room.bannedUsers)
        ..remove(targetUserId);
      await _firestore.collection('rooms').doc(roomId).update({
        'bannedUsers': newBannedUsers,
      });

      // Ban kaydını pasif yap
      final bansSnapshot = await _firestore
          .collection('bans')
          .where('userId', isEqualTo: targetUserId)
          .where('roomId', isEqualTo: roomId)
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in bansSnapshot.docs) {
        await doc.reference.update({'isActive': false});
      }
    } catch (e) {
      throw Exception('Ban kaldırılamadı: $e');
    }
  }

  // Odanın banlı kullanıcılarını getir
  Future<List<String>> getBannedUsers(String roomId) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) return [];
      
      final room = Room.fromFirestore(roomDoc);
      return room.bannedUsers;
    } catch (e) {
      return [];
    }
  }
}
