import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JoinedRoom {
  final String roomId;
  final String roomName;
  final bool isEncrypted;
  final String? password; // Şifreyi sakla
  final DateTime joinedAt;

  JoinedRoom({
    required this.roomId,
    required this.roomName,
    required this.isEncrypted,
    this.password,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'isEncrypted': isEncrypted,
      'password': password,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory JoinedRoom.fromJson(Map<String, dynamic> json) {
    return JoinedRoom(
      roomId: json['roomId'],
      roomName: json['roomName'],
      isEncrypted: json['isEncrypted'] ?? false,
      password: json['password'],
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}

class JoinedRoomsService {
  static const String _key = 'joined_rooms';

  // Katılınan odaları al
  Future<List<JoinedRoom>> getJoinedRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? roomsJson = prefs.getString(_key);

      if (roomsJson == null || roomsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = json.decode(roomsJson);
      return decoded.map((item) => JoinedRoom.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Oda ekle
  Future<void> addJoinedRoom(JoinedRoom room) async {
    try {
      final rooms = await getJoinedRooms();

      // Eğer oda zaten ekliyse, güncelle
      rooms.removeWhere((r) => r.roomId == room.roomId);
      rooms.insert(0, room); // En başa ekle

      // Maksimum 50 oda sakla
      if (rooms.length > 50) {
        rooms.removeRange(50, rooms.length);
      }

      await _saveRooms(rooms);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  // Oda sil
  Future<void> removeJoinedRoom(String roomId) async {
    try {
      final rooms = await getJoinedRooms();
      rooms.removeWhere((r) => r.roomId == roomId);
      await _saveRooms(rooms);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  // Tüm odaları temizle
  Future<void> clearAllRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  // Odaları kaydet
  Future<void> _saveRooms(List<JoinedRoom> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(rooms.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  // Oda var mı kontrol et
  Future<bool> isRoomJoined(String roomId) async {
    final rooms = await getJoinedRooms();
    return rooms.any((r) => r.roomId == roomId);
  }

  // Oda şifresini al
  Future<String?> getRoomPassword(String roomId) async {
    final rooms = await getJoinedRooms();
    final room = rooms.firstWhere(
      (r) => r.roomId == roomId,
      orElse: () => JoinedRoom(
        roomId: '',
        roomName: '',
        isEncrypted: false,
        joinedAt: DateTime.now(),
      ),
    );
    return room.password;
  }
}
