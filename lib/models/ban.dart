import 'package:cloud_firestore/cloud_firestore.dart';

class Ban {
  final String banId;
  final String userId; // Banlanan kullanıcı ID (Anonymous UID)
  final String? deviceId; // Cihaz ID
  final String? ipAddress; // IP adresi
  final String roomId; // Hangi odadan banlandı
  final String bannedBy; // Banlayan admin ID
  final String reason; // Ban nedeni
  final DateTime bannedAt;
  final DateTime? expiresAt; // Null ise permanent ban
  final bool isActive; // Ban aktif mi?

  Ban({
    required this.banId,
    required this.userId,
    this.deviceId,
    this.ipAddress,
    required this.roomId,
    required this.bannedBy,
    required this.reason,
    required this.bannedAt,
    this.expiresAt,
    this.isActive = true,
  });

  factory Ban.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ban(
      banId: doc.id,
      userId: data['userId'] ?? '',
      deviceId: data['deviceId'],
      ipAddress: data['ipAddress'],
      roomId: data['roomId'] ?? '',
      bannedBy: data['bannedBy'] ?? '',
      reason: data['reason'] ?? '',
      bannedAt: (data['bannedAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      if (deviceId != null) 'deviceId': deviceId,
      if (ipAddress != null) 'ipAddress': ipAddress,
      'roomId': roomId,
      'bannedBy': bannedBy,
      'reason': reason,
      'bannedAt': Timestamp.fromDate(bannedAt),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'isActive': isActive,
    };
  }

  // Ban süresi doldu mu?
  bool get isExpired {
    if (expiresAt == null) return false; // Permanent ban
    return DateTime.now().isAfter(expiresAt!);
  }

  // Ban hala geçerli mi?
  bool get isValid => isActive && !isExpired;

  Ban copyWith({
    String? banId,
    String? userId,
    String? deviceId,
    String? ipAddress,
    String? roomId,
    String? bannedBy,
    String? reason,
    DateTime? bannedAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return Ban(
      banId: banId ?? this.banId,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      roomId: roomId ?? this.roomId,
      bannedBy: bannedBy ?? this.bannedBy,
      reason: reason ?? this.reason,
      bannedAt: bannedAt ?? this.bannedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
