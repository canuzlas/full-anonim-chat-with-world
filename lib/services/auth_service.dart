import 'package:firebase_auth/firebase_auth.dart';
import './user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Kullanıcının UID'sini al
  String? get currentUserId => _auth.currentUser?.uid;

  // Kullanıcı oturum durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Anonim olarak giriş yap
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      
      // Kullanıcı için username oluştur
      if (user != null) {
        await _userService.getOrCreateUser(user.uid);
      }
      
      return user;
    } catch (e) {
      throw Exception('Anonim giriş yapılamadı: $e');
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Çıkış yapılamadı: $e');
    }
  }

  // Kullanıcının giriş yapmış olup olmadığını kontrol et
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Eğer kullanıcı giriş yapmamışsa otomatik anonim giriş yap
  Future<User?> ensureSignedIn() async {
    if (isSignedIn()) {
      // Mevcut kullanıcı için de username kontrolü yap
      final userId = currentUserId;
      if (userId != null) {
        await _userService.getOrCreateUser(userId);
      }
      return currentUser;
    }
    return await signInAnonymously();
  }
}
