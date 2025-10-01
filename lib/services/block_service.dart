import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/block.dart';

class BlockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcıyı engelle
  Future<void> blockUser({
    required String blockerUserId,
    required String blockedUserId,
  }) async {
    try {
      // Zaten engellenmiş mi kontrol et
      final existing = await _firestore
          .collection('blocks')
          .where('blockerUserId', isEqualTo: blockerUserId)
          .where('blockedUserId', isEqualTo: blockedUserId)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Kullanıcı zaten engellenmiş');
      }

      // Engelleme kaydı oluştur
      final block = Block(
        blockId: '',
        blockerUserId: blockerUserId,
        blockedUserId: blockedUserId,
        blockedAt: DateTime.now(),
      );

      await _firestore.collection('blocks').add(block.toFirestore());
    } catch (e) {
      throw Exception('Kullanıcı engellenemedi: $e');
    }
  }

  // Engeli kaldır
  Future<void> unblockUser({
    required String blockerUserId,
    required String blockedUserId,
  }) async {
    try {
      final blocksSnapshot = await _firestore
          .collection('blocks')
          .where('blockerUserId', isEqualTo: blockerUserId)
          .where('blockedUserId', isEqualTo: blockedUserId)
          .get();

      for (var doc in blocksSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Engel kaldırılamadı: $e');
    }
  }

  // Kullanıcı engellenmiş mi?
  Future<bool> isBlocked({
    required String blockerUserId,
    required String blockedUserId,
  }) async {
    try {
      final blocksSnapshot = await _firestore
          .collection('blocks')
          .where('blockerUserId', isEqualTo: blockerUserId)
          .where('blockedUserId', isEqualTo: blockedUserId)
          .limit(1)
          .get();

      return blocksSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Engellenen kullanıcıları getir
  Stream<List<Block>> getBlockedUsers(String userId) {
    return _firestore
        .collection('blocks')
        .where('blockerUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Block.fromFirestore(doc)).toList());
  }

  // Beni engelleyenleri getir
  Stream<List<Block>> getBlockers(String userId) {
    return _firestore
        .collection('blocks')
        .where('blockedUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Block.fromFirestore(doc)).toList());
  }
}
