import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/room.dart';
import '../services/encryption_service.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Rooms koleksiyonuna referans
  CollectionReference get _roomsCollection => _firestore.collection('rooms');

  // Yeni oda oluştur
  Future<Room> createRoom({
    required String name,
    required String createdBy,
    required bool isEncrypted,
    String? password,
  }) async {
    try {
      // Eğer şifrelenecekse, şifrenin hash'ini oluştur
      String? encryptionKeyHash;
      if (isEncrypted && password != null && password.isNotEmpty) {
        encryptionKeyHash = EncryptionService.hashPassword(password);
      }

      final roomId = _uuid.v4();
      final room = Room(
        roomId: roomId,
        name: name,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        isEncrypted: isEncrypted,
        encryptionKeyHash: encryptionKeyHash,
      );

      await _roomsCollection.doc(roomId).set(room.toFirestore());
      return room;
    } catch (e) {
      throw Exception('Oda oluşturulamadı: $e');
    }
  }

  // Global chat room oluştur veya al
  Future<Room> createGlobalRoom({required String createdBy}) async {
    try {
      const roomId = 'global-chat-room';

      // Oda zaten varsa, onu döndür
      final existingRoom = await getRoomById(roomId);
      if (existingRoom != null) {
        return existingRoom;
      }

      // Yoksa oluştur
      final room = Room(
        roomId: roomId,
        name: '🌍 Global Chat',
        createdAt: DateTime.now(),
        createdBy: createdBy,
        isEncrypted: false,
      );

      await _roomsCollection.doc(roomId).set(room.toFirestore());
      return room;
    } catch (e) {
      throw Exception('Global oda oluşturulamadı: $e');
    }
  }

  // Oda ID ile oda bilgilerini al
  Future<Room?> getRoomById(String roomId) async {
    try {
      final doc = await _roomsCollection.doc(roomId).get();
      if (!doc.exists) {
        return null;
      }
      return Room.fromFirestore(doc);
    } catch (e) {
      throw Exception('Oda bilgileri alınamadı: $e');
    }
  }

  // Odanın şifresini doğrula
  Future<bool> verifyRoomPassword(String roomId, String password) async {
    try {
      final room = await getRoomById(roomId);
      if (room == null) {
        return false;
      }

      // Eğer oda şifreli değilse, doğrulama gerekmez
      if (!room.isEncrypted || room.encryptionKeyHash == null) {
        return true;
      }

      // Şifreyi doğrula
      return EncryptionService.verifyPassword(
        password,
        room.encryptionKeyHash!,
      );
    } catch (e) {
      return false;
    }
  }

  // Odayı sil (sadece oda sahibi silebilir)
  Future<void> deleteRoom(String roomId, String userId) async {
    try {
      final room = await getRoomById(roomId);
      if (room == null) {
        throw Exception('Oda bulunamadı');
      }

      if (room.createdBy != userId) {
        throw Exception('Bu odayı silme yetkiniz yok');
      }

      // Odadaki tüm mesajları sil
      final messagesQuery = await _roomsCollection
          .doc(roomId)
          .collection('messages')
          .get();

      for (var doc in messagesQuery.docs) {
        await doc.reference.delete();
      }

      // Odayı sil
      await _roomsCollection.doc(roomId).delete();
    } catch (e) {
      throw Exception('Oda silinemedi: $e');
    }
  }

  // Kullanıcının oluşturduğu odaları getir (opsiyonel)
  Stream<List<Room>> getUserRooms(String userId) {
    return _roomsCollection
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          // Client-side sorting yapıyoruz
          final rooms = snapshot.docs
              .map((doc) => Room.fromFirestore(doc))
              .toList();
          rooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return rooms;
        });
  }

  // Oda adını güncelle
  Future<void> updateRoomName(
    String roomId,
    String newName,
    String userId,
  ) async {
    try {
      final room = await getRoomById(roomId);
      if (room == null) {
        throw Exception('Oda bulunamadı');
      }

      if (room.createdBy != userId) {
        throw Exception('Bu odayı güncelleme yetkiniz yok');
      }

      await _roomsCollection.doc(roomId).update({'name': newName});
    } catch (e) {
      throw Exception('Oda adı güncellenemedi: $e');
    }
  }
}
