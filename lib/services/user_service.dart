import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Rastgele username oluştur (User#timestamp-random formatında - Global unique)
  String _generateRandomUsername() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    final randomInt = random.nextInt(9999) + 1000; // 1000-10998 arası 4 haneli
    return 'User#$timestamp$randomInt';
  }

  // Kullanıcıyı oluştur veya getir
  Future<User> getOrCreateUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return User.fromFirestore(doc);
      } else {
        // Yeni kullanıcı oluştur
        final username = _generateRandomUsername();
        final user = User(
          userId: userId,
          username: username,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(userId).set(user.toFirestore());
        return user;
      }
    } catch (e) {
      throw Exception('Kullanıcı bilgisi alınamadı: $e');
    }
  }

  // Kullanıcı bilgisini getir
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return User.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  // Username'e göre kullanıcı ara (admin moderator atarken kullanılacak)
  Future<User?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) return null;
      return User.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  // Username stream (real-time)
  Stream<String?> getUsernameStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return User.fromFirestore(doc).username;
        });
  }

  // Kullanıcı bilgisi stream
  Stream<User?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return User.fromFirestore(doc);
        });
  }
}
