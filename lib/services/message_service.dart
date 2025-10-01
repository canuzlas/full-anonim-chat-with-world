import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../services/encryption_service.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Messages koleksiyonuna referans
  CollectionReference _messagesCollection(String roomId) {
    return _firestore.collection('rooms').doc(roomId).collection('messages');
  }

  // Mesaj gönder
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
    required bool isEncrypted,
    String? encryptionPassword,
  }) async {
    try {
      String messageText = text;

      // 1. ÖNCE: User-level encryption (şifreli odalarda)
      if (isEncrypted &&
          encryptionPassword != null &&
          encryptionPassword.isNotEmpty) {
        messageText = EncryptionService.encryptText(text, encryptionPassword);
      }

      // 2. SONRA: App-level encryption (TÜM mesajlar için)
      // Uygulama dışında mesajların okunamaması için
      messageText = EncryptionService.encryptAppLevel(messageText);

      final message = Message(
        messageId: '', // Firestore otomatik oluşturacak
        roomId: roomId,
        senderId: senderId,
        text: messageText,
        sentAt: DateTime.now(),
        isEncrypted: isEncrypted,
      );

      await _messagesCollection(roomId).add(message.toFirestore());
    } catch (e) {
      throw Exception('Mesaj gönderilemedi: $e');
    }
  }

  // Mesajları real-time dinle
  Stream<List<Message>> getMessages(String roomId) {
    return _messagesCollection(
      roomId,
    ).orderBy('sentAt', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final message = Message.fromFirestore(doc, roomId);
        
        // App-level decryption (TÜM mesajlar için)
        try {
          final appDecrypted = EncryptionService.decryptAppLevel(message.text);
          return message.copyWith(text: appDecrypted);
        } catch (e) {
          // Eski mesajlar (app-level encryption olmadan)
          return message;
        }
      }).toList();
    });
  }

  // Mesajları çözerek getir
  List<Message> decryptMessages(List<Message> messages, String? password) {
    return messages.map((message) {
      if (message.isEncrypted && password != null && password.isNotEmpty) {
        try {
          final decryptedText = EncryptionService.decryptText(
            message.text,
            password,
          );
          return message.copyWith(text: decryptedText);
        } catch (e) {
          // Şifre çözülemezse, şifreli metin olarak bırak
          return message.copyWith(text: '🔒 [Şifreli Mesaj]');
        }
      }
      return message;
    }).toList();
  }

  // Tek bir mesajı sil (sadece gönderen silebilir)
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final doc = await _messagesCollection(roomId).doc(messageId).get();
      if (!doc.exists) {
        throw Exception('Mesaj bulunamadı');
      }

      final message = Message.fromFirestore(doc, roomId);
      if (message.senderId != userId) {
        throw Exception('Bu mesajı silme yetkiniz yok');
      }

      await _messagesCollection(roomId).doc(messageId).delete();
    } catch (e) {
      throw Exception('Mesaj silinemedi: $e');
    }
  }

  // Odadaki tüm mesajları sil
  Future<void> deleteAllMessages(String roomId) async {
    try {
      final snapshot = await _messagesCollection(roomId).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Mesajlar silinemedi: $e');
    }
  }

  // Mesaj sayısını al
  Future<int> getMessageCount(String roomId) async {
    try {
      final snapshot = await _messagesCollection(roomId).get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
