import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String reportId;
  final String roomId;
  final String messageId;
  final String encodedMessageContent; // Base64 encoded mesaj içeriği
  final String reportedBy; // Şikayet eden kullanıcı ID
  final String reportedUser; // Şikayet edilen kullanıcı ID
  final String reason; // Şikayet nedeni
  final DateTime reportedAt;
  final String? deviceId; // Şikayet edilen kullanıcının cihaz ID'si
  final String? ipAddress; // Şikayet edilen kullanıcının IP'si
  final bool isResolved; // Şikayet çözüldü mü?
  final String? resolvedBy; // Çözen admin ID
  final DateTime? resolvedAt;

  Report({
    required this.reportId,
    required this.roomId,
    required this.messageId,
    required this.encodedMessageContent,
    required this.reportedBy,
    required this.reportedUser,
    required this.reason,
    required this.reportedAt,
    this.deviceId,
    this.ipAddress,
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      reportId: doc.id,
      roomId: data['roomId'] ?? '',
      messageId: data['messageId'] ?? '',
      encodedMessageContent: data['encodedMessageContent'] ?? '',
      reportedBy: data['reportedBy'] ?? '',
      reportedUser: data['reportedUser'] ?? '',
      reason: data['reason'] ?? '',
      reportedAt: (data['reportedAt'] as Timestamp).toDate(),
      deviceId: data['deviceId'],
      ipAddress: data['ipAddress'],
      isResolved: data['isResolved'] ?? false,
      resolvedBy: data['resolvedBy'],
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'messageId': messageId,
      'encodedMessageContent': encodedMessageContent,
      'reportedBy': reportedBy,
      'reportedUser': reportedUser,
      'reason': reason,
      'reportedAt': Timestamp.fromDate(reportedAt),
      if (deviceId != null) 'deviceId': deviceId,
      if (ipAddress != null) 'ipAddress': ipAddress,
      'isResolved': isResolved,
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
    };
  }

  Report copyWith({
    String? reportId,
    String? roomId,
    String? messageId,
    String? encodedMessageContent,
    String? reportedBy,
    String? reportedUser,
    String? reason,
    DateTime? reportedAt,
    String? deviceId,
    String? ipAddress,
    bool? isResolved,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return Report(
      reportId: reportId ?? this.reportId,
      roomId: roomId ?? this.roomId,
      messageId: messageId ?? this.messageId,
      encodedMessageContent:
          encodedMessageContent ?? this.encodedMessageContent,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedUser: reportedUser ?? this.reportedUser,
      reason: reason ?? this.reason,
      reportedAt: reportedAt ?? this.reportedAt,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
      isResolved: isResolved ?? this.isResolved,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
