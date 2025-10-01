import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../services/joined_rooms_service.dart';
import 'chat_screen.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPasswordField = false;

  @override
  void dispose() {
    _roomIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final roomService = ref.read(roomServiceProvider);
      final roomId = _roomIdController.text.trim();
      final currentUserId = ref.read(currentUserIdProvider);

      // Kullanıcı giriş yapmış mı kontrol et
      if (currentUserId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen önce giriş yapın'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Oda var mı kontrol et
      final room = await roomService.getRoomById(roomId);
      if (room == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oda bulunamadı. Lütfen ID\'yi kontrol edin.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Kullanıcı bu odadan banlı mı kontrol et
      if (room.isBanned(currentUserId)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu odadan yasaklandınız. Giriş yapamazsınız.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Eğer oda şifreliyse ve henüz şifre alanı gösterilmediyse
      if (room.isEncrypted && !_showPasswordField) {
        setState(() {
          _showPasswordField = true;
          _isLoading = false;
        });
        return;
      }

      // Eğer oda şifreliyse, şifreyi doğrula
      if (room.isEncrypted) {
        final isPasswordCorrect = await roomService.verifyRoomPassword(
          roomId,
          _passwordController.text,
        );

        if (!isPasswordCorrect) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yanlış şifre!'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Şifreyi provider'a kaydet
        // Şifreyi provider'a kaydet
        ref.read(roomPasswordProvider(roomId).notifier).state =
            _passwordController.text;
      }

      // Katılınan odayı kaydet
      final joinedRoomsService = ref.read(joinedRoomsServiceProvider);
      await joinedRoomsService.addJoinedRoom(
        JoinedRoom(
          roomId: room.roomId,
          roomName: room.name,
          isEncrypted: room.isEncrypted,
          password: room.isEncrypted ? _passwordController.text : null,
          joinedAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      // Chat ekranına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            roomId: room.roomId,
            roomName: room.name,
            isEncrypted: room.isEncrypted,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Odaya katılılamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odaya Katıl'),
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
                Icons.meeting_room_outlined,
                size: 80,
                color: Colors.deepPurple.shade300,
              ),
              const SizedBox(height: 40),

              // Oda ID
              TextFormField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: 'Oda ID',
                  hintText: 'Oda ID\'sini buraya yapıştırın',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Oda oluşturan kişiden aldığınız ID',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Oda ID gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Şifre alanı (eğer oda şifreliyse göster)
              if (_showPasswordField) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Oda Şifresi',
                    hintText: 'Odanın şifresini girin',
                    prefixIcon: const Icon(Icons.vpn_key),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Bu oda şifreli, şifreyi giriniz',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_showPasswordField &&
                        (value == null || value.isEmpty)) {
                      return 'Şifre gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Bilgi kartı
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bilgi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Oda ID\'sini oda sahibinden alın\n'
                        '• Eğer oda şifreliyse, şifreyi de almanız gerekir\n'
                        '• Kimlik bilgileriniz hiçbir zaman kaydedilmez',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Katıl butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _joinRoom,
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
                    : Text(
                        _showPasswordField ? 'Odaya Katıl' : 'Devam Et',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
