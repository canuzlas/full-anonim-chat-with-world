import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String roomId;
  final String senderId;
  final String text; // Şifrelenmiş veya düz metin
  final DateTime sentAt;
  final bool isEncrypted;
  final int reportCount; // Kaç kere şikayet edildi
  final bool isDeleted; // Mesaj silindi mi?

  Message({
    required this.messageId,
    required this.roomId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.isEncrypted,
    this.reportCount = 0,
    this.isDeleted = false,
  });

  // Firestore'dan Message oluştur
  factory Message.fromFirestore(DocumentSnapshot doc, String roomId) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      messageId: doc.id,
      roomId: roomId,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isEncrypted: data['isEncrypted'] ?? false,
      reportCount: data['reportCount'] ?? 0,
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // Message'ı Firestore'a kaydet
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
      'isEncrypted': isEncrypted,
      'reportCount': reportCount,
      'isDeleted': isDeleted,
    };
  }

  Message copyWith({
    String? messageId,
    String? roomId,
    String? senderId,
    String? text,
    DateTime? sentAt,
    bool? isEncrypted,
    int? reportCount,
    bool? isDeleted,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      reportCount: reportCount ?? this.reportCount,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
