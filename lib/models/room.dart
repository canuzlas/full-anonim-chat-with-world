import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String roomId;
  final String name;
  final DateTime createdAt;
  final String createdBy;
  final bool isEncrypted;
  final String? encryptionKeyHash; // Şifrenin hash'i, doğrulama için
  final List<String> admins; // Admin kullanıcı ID'leri (ilk admin = createdBy)
  final List<String> moderators; // Moderator kullanıcı ID'leri
  final List<String> bannedUsers; // Banlanan kullanıcı ID'leri

  Room({
    required this.roomId,
    required this.name,
    required this.createdAt,
    required this.createdBy,
    required this.isEncrypted,
    this.encryptionKeyHash,
    List<String>? admins,
    List<String>? moderators,
    List<String>? bannedUsers,
  })  : admins = admins ?? [createdBy], // createdBy otomatik admin
        moderators = moderators ?? [],
        bannedUsers = bannedUsers ?? [];

  // Firestore'dan Room oluştur
  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      roomId: doc.id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      isEncrypted: data['isEncrypted'] ?? false,
      encryptionKeyHash: data['encryptionKeyHash'],
      admins: List<String>.from(data['admins'] ?? [data['createdBy']]),
      moderators: List<String>.from(data['moderators'] ?? []),
      bannedUsers: List<String>.from(data['bannedUsers'] ?? []),
    );
  }

  // Room'u Firestore'a kaydet
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'isEncrypted': isEncrypted,
      if (encryptionKeyHash != null) 'encryptionKeyHash': encryptionKeyHash,
      'admins': admins,
      'moderators': moderators,
      'bannedUsers': bannedUsers,
    };
  }

  // Room paylaşım linki oluştur
  String getShareableLink() {
    // Gerçek uygulama için deep link kullanılabilir
    return 'anonimchat://join/$roomId';
  }

  Room copyWith({
    String? roomId,
    String? name,
    DateTime? createdAt,
    String? createdBy,
    bool? isEncrypted,
    String? encryptionKeyHash,
    List<String>? admins,
    List<String>? moderators,
    List<String>? bannedUsers,
  }) {
    return Room(
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encryptionKeyHash: encryptionKeyHash ?? this.encryptionKeyHash,
      admins: admins ?? this.admins,
      moderators: moderators ?? this.moderators,
      bannedUsers: bannedUsers ?? this.bannedUsers,
    );
  }

  // Yetki kontrol metodları
  bool isAdmin(String userId) => admins.contains(userId);
  bool isModerator(String userId) => moderators.contains(userId);
  bool isAdminOrModerator(String userId) => isAdmin(userId) || isModerator(userId);
  bool isBanned(String userId) => bannedUsers.contains(userId);
}
