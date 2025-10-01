import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import '../services/message_service.dart';
import '../services/joined_rooms_service.dart';
import '../services/admin_service.dart';
import '../services/block_service.dart';
import '../services/user_service.dart';
import '../models/room.dart';
import '../models/message.dart';
import '../models/user.dart' as app_user;

// Service Provider'ları
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService();
});

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});

final joinedRoomsServiceProvider = Provider<JoinedRoomsService>((ref) {
  return JoinedRoomsService();
});

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

final blockServiceProvider = Provider<BlockService>((ref) {
  return BlockService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Auth State Provider
final authStateProvider = StreamProvider((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUserId;
});

// User Rooms Provider (kullanıcının oluşturduğu odalar)
final userRoomsProvider = StreamProvider.family<List<Room>, String>((
  ref,
  userId,
) {
  final roomService = ref.watch(roomServiceProvider);
  return roomService.getUserRooms(userId);
});

// Room Provider (belirli bir oda)
final roomProvider = FutureProvider.family<Room?, String>((ref, roomId) async {
  final roomService = ref.watch(roomServiceProvider);
  return await roomService.getRoomById(roomId);
});

// Room Stream Provider (oda değişikliklerini dinle)
final roomStreamProvider = StreamProvider.family<Room?, String>((ref, roomId) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('rooms')
      .doc(roomId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return null;
        return Room.fromFirestore(snapshot);
      });
});

// Messages Provider (belirli bir odanın mesajları)
final messagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  roomId,
) {
  final messageService = ref.watch(messageServiceProvider);
  return messageService.getMessages(roomId);
});

// Room Password State Provider (şifre saklama için)
final roomPasswordProvider = StateProvider.family<String?, String>((
  ref,
  roomId,
) {
  return null;
});

// Decrypted Messages Provider (şifresi çözülmüş mesajlar)
final decryptedMessagesProvider = Provider.family<List<Message>, String>((
  ref,
  roomId,
) {
  final messages = ref.watch(messagesProvider(roomId));
  final password = ref.watch(roomPasswordProvider(roomId));
  final messageService = ref.watch(messageServiceProvider);

  return messages.when(
    data: (messagesList) {
      if (password == null) {
        return messagesList;
      }
      return messageService.decryptMessages(messagesList, password);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Loading State Provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Error Message Provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Admin/Moderator Check Providers
final isAdminProvider = FutureProvider.family<bool, ({String roomId, String userId})>((
  ref,
  params,
) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.isAdmin(params.roomId, params.userId);
});

final isModeratorProvider = FutureProvider.family<bool, ({String roomId, String userId})>((
  ref,
  params,
) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.isModerator(params.roomId, params.userId);
});

final isAdminOrModeratorProvider = FutureProvider.family<bool, ({String roomId, String userId})>((
  ref,
  params,
) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.isAdminOrModerator(params.roomId, params.userId);
});

// Block Check Provider
final isBlockedProvider = FutureProvider.family<bool, ({String blockerUserId, String blockedUserId})>((
  ref,
  params,
) async {
  final blockService = ref.watch(blockServiceProvider);
  return await blockService.isBlocked(
    blockerUserId: params.blockerUserId,
    blockedUserId: params.blockedUserId,
  );
});

// Blocked Users Provider
final blockedUsersProvider = StreamProvider.family<List<String>, String>((
  ref,
  userId,
) {
  final blockService = ref.watch(blockServiceProvider);
  return blockService.getBlockedUsers(userId).map(
    (blocks) => blocks.map((block) => block.blockedUserId).toList(),
  );
});

// User Provider (username için)
final userProvider = FutureProvider.family<app_user.User?, String>((
  ref,
  userId,
) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUser(userId);
});

// Username Provider (stream)
final usernameProvider = StreamProvider.family<String?, String>((
  ref,
  userId,
) {
  final userService = ref.watch(userServiceProvider);
  return userService.getUsernameStream(userId);
});

// Banned Check Provider (kullanıcı banlı mı)
final isBannedProvider = StreamProvider.family<bool, ({String roomId, String userId})>((
  ref,
  params,
) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('rooms')
      .doc(params.roomId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return false;
        final data = snapshot.data();
        if (data == null) return false;
        final bannedUsers = List<String>.from(data['bannedUsers'] ?? []);
        return bannedUsers.contains(params.userId);
      });
});
