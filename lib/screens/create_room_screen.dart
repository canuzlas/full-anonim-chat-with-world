import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../services/joined_rooms_service.dart';
import 'chat_screen.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEncrypted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEncrypted && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreli oda için şifre girmelisiniz')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final roomService = ref.read(roomServiceProvider);
      final authService = ref.read(authServiceProvider);

      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      final room = await roomService.createRoom(
        name: _roomNameController.text.trim(),
        createdBy: userId,
        isEncrypted: _isEncrypted,
        password: _isEncrypted ? _passwordController.text : null,
      );

      if (!mounted) return;

      // Şifreyi provider'a kaydet
      if (_isEncrypted) {
        ref.read(roomPasswordProvider(room.roomId).notifier).state =
            _passwordController.text;
      }

      // Oda oluşturuldu mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oda başarıyla oluşturuldu! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      // Paylaşım seçeneği sun
      await _showShareDialog(room.roomId, room.name);

      // Katılınan odayı kaydet
      final joinedRoomsService = ref.read(joinedRoomsServiceProvider);
      await joinedRoomsService.addJoinedRoom(
        JoinedRoom(
          roomId: room.roomId,
          roomName: room.name,
          isEncrypted: _isEncrypted,
          password: _isEncrypted ? _passwordController.text : null,
          joinedAt: DateTime.now(),
        ),
      );

      // Chat ekranına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            roomId: room.roomId,
            roomName: room.name,
            isEncrypted: _isEncrypted,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oda oluşturulamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showShareDialog(String roomId, String roomName) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oda Oluşturuldu!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Oda Adı: $roomName'),
            const SizedBox(height: 8),
            Text('Oda ID: $roomId'),
            const SizedBox(height: 16),
            const Text(
              'Bu oda ID\'sini paylaşarak başkalarının odaya katılmasını sağlayabilirsiniz.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: roomId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Oda ID kopyalandı')),
              );
            },
            child: const Text('ID\'yi Kopyala'),
          ),
          TextButton(
            onPressed: () {
              final shareText = _isEncrypted
                  ? 'Anonim Chat odama katıl!\n\nOda: $roomName\nOda ID: $roomId\nŞifre: ${_passwordController.text}'
                  : 'Anonim Chat odama katıl!\n\nOda: $roomName\nOda ID: $roomId';
              Share.share(shareText);
            },
            child: const Text('Paylaş'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Oda Oluştur'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.add_circle_outline,
                size: 80,
                color: Colors.deepPurple.shade300,
              ),
              const SizedBox(height: 40),

              // Oda adı
              TextFormField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  labelText: 'Oda Adı',
                  hintText: 'Örn: Arkadaşlar Grubu',
                  prefixIcon: const Icon(Icons.meeting_room),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Oda adı gerekli';
                  }
                  if (value.trim().length < 3) {
                    return 'Oda adı en az 3 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Şifreleme anahtarı
              Card(
                child: SwitchListTile(
                  title: const Text('Şifreli Oda'),
                  subtitle: const Text('Mesajlar uçtan uca şifrelensin'),
                  value: _isEncrypted,
                  onChanged: (value) {
                    setState(() => _isEncrypted = value);
                  },
                  secondary: Icon(
                    _isEncrypted ? Icons.lock : Icons.lock_open,
                    color: _isEncrypted ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Şifre alanı (sadece şifreli oda seçiliyse)
              if (_isEncrypted) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Oda Şifresi',
                    hintText: 'Güçlü bir şifre belirleyin',
                    prefixIcon: const Icon(Icons.vpn_key),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Bu şifreyi odaya katılacak kişilerle paylaşın',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_isEncrypted && (value == null || value.isEmpty)) {
                      return 'Şifreli oda için şifre gerekli';
                    }
                    if (_isEncrypted && value!.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Bilgi kartı
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Bilgi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEncrypted
                            ? '• Mesajlar cihazınızda şifrelenir\n'
                                  '• Yalnızca şifreyi bilenler okuyabilir\n'
                                  '• Şifre sunucuda saklanmaz'
                            : '• Oda herkese açık olacak\n'
                                  '• Oda ID\'si ile herkes katılabilir\n'
                                  '• Mesajlar şifrelenmez',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Oluştur butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Oda Oluştur', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
