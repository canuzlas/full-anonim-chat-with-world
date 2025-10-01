import 'package:cloud_firestore/cloud_firestore.dart';

class Block {
  final String blockId;
  final String blockerUserId; // Engelleyen kullanıcı ID
  final String blockedUserId; // Engellenen kullanıcı ID
  final DateTime blockedAt;

  Block({
    required this.blockId,
    required this.blockerUserId,
    required this.blockedUserId,
    required this.blockedAt,
  });

  factory Block.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Block(
      blockId: doc.id,
      blockerUserId: data['blockerUserId'] ?? '',
      blockedUserId: data['blockedUserId'] ?? '',
      blockedAt: (data['blockedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'blockerUserId': blockerUserId,
      'blockedUserId': blockedUserId,
      'blockedAt': Timestamp.fromDate(blockedAt),
    };
  }

  Block copyWith({
    String? blockId,
    String? blockerUserId,
    String? blockedUserId,
    DateTime? blockedAt,
  }) {
    return Block(
      blockId: blockId ?? this.blockId,
      blockerUserId: blockerUserId ?? this.blockerUserId,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      blockedAt: blockedAt ?? this.blockedAt,
    );
  }
}
