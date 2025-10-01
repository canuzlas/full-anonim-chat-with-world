import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String username; // Rastgele oluşturulan username (User#1234)
  final DateTime createdAt;

  User({
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      userId: doc.id,
      username: data['username'] ?? 'User#0000',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  User copyWith({
    String? userId,
    String? username,
    DateTime? createdAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
