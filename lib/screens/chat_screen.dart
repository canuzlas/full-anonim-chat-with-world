import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../models/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomName;
  final bool isEncrypted;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.isEncrypted,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadPasswordFromStorage();
  }

  // Kaydedilmiş şifreyi yükle
  Future<void> _loadPasswordFromStorage() async {
    if (!widget.isEncrypted) return;

    final joinedRoomsService = ref.read(joinedRoomsServiceProvider);
    final savedPassword = await joinedRoomsService.getRoomPassword(
      widget.roomId,
    );

    if (savedPassword != null && mounted) {
      ref.read(roomPasswordProvider(widget.roomId).notifier).state =
          savedPassword;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final messageService = ref.read(messageServiceProvider);
      final authService = ref.read(authServiceProvider);
      final roomService = ref.read(roomServiceProvider);
      final password = ref.read(roomPasswordProvider(widget.roomId));

      final userId = authService.currentUserId;
      if (userId == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      // Ban kontrolü - Mesaj göndermeden önce kontrol et
      final room = await roomService.getRoomById(widget.roomId);
      if (room != null && room.isBanned(userId)) {
        throw Exception('Bu odadan yasaklandınız');
      }

      await messageService.sendMessage(
        roomId: widget.roomId,
        senderId: userId,
        text: text,
        isEncrypted: widget.isEncrypted,
        encryptionPassword: password,
      );

      _messageController.clear();

      // Mesaj gönderildikten sonra en alta scroll
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mesaj gönderilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showRoomInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oda Bilgileri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Oda Adı', widget.roomName),
            const SizedBox(height: 12),
            _buildInfoRow('Oda ID', widget.roomId),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Güvenlik',
              widget.isEncrypted ? '🔒 Şifreli' : '🔓 Şifresiz',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.roomId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Oda ID kopyalandı')),
              );
            },
            child: const Text('ID\'yi Kopyala'),
          ),
          TextButton(
            onPressed: () {
              final password = ref.read(roomPasswordProvider(widget.roomId));
              final shareText = widget.isEncrypted && password != null
                  ? 'Anonim Chat odama katıl!\n\nOda: ${widget.roomName}\nOda ID: ${widget.roomId}\nŞifre: $password'
                  : 'Anonim Chat odama katıl!\n\nOda: ${widget.roomName}\nOda ID: ${widget.roomId}';
              Share.share(shareText);
              Navigator.pop(context);
            },
            child: const Text('Paylaş'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Admin menüsü
  void _showAdminMenu(BuildContext context, String userId) async {
    final adminService = ref.read(adminServiceProvider);
    final isAdmin = await adminService.isAdmin(widget.roomId, userId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('Moderator Ata'),
              subtitle: const Text('Kullanıcıya moderator yetkisi ver'),
              onTap: () {
                Navigator.pop(context);
                if (isAdmin) {
                  _showAddModeratorDialog();
                } else {
                  _showError('Bu işlem için admin olmalısınız');
                }
              },
            ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.orange),
                title: const Text('Moderator Kaldır'),
                subtitle: const Text('Moderator yetkisini geri al'),
                onTap: () {
                  Navigator.pop(context);
                  _showRemoveModeratorDialog();
                },
              ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Yasaklılar'),
                subtitle: const Text('Atılan kullanıcıları yönet'),
                onTap: () {
                  Navigator.pop(context);
                  _showBannedUsersDialog();
                },
              ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Odayı Sil'),
                subtitle: const Text('Tüm mesajlar silinir'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteRoom();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Moderator ekleme dialogu
  void _showAddModeratorDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Moderator Ata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kullanıcı adını girin (örn: User#1234):'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'User#1234',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final username = controller.text.trim();
              if (username.isEmpty) return;

              Navigator.pop(context);

              try {
                final userService = ref.read(userServiceProvider);
                final adminService = ref.read(adminServiceProvider);
                final currentUserId = ref.read(currentUserIdProvider);
                if (currentUserId == null) return;

                // Username'den userId'yi bul
                final targetUser = await userService.getUserByUsername(username);
                
                if (targetUser == null) {
                  if (!mounted) return;
                  _showError('Kullanıcı bulunamadı: $username');
                  return;
                }

                await adminService.addModerator(
                  roomId: widget.roomId,
                  adminUserId: currentUserId,
                  targetUserId: targetUser.userId,
                );

                if (!mounted) return;
                _showSuccess('Moderator eklendi: $username');
              } catch (e) {
                if (!mounted) return;
                _showError('Hata: $e');
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  // Oda silme onayı
  void _confirmDeleteRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odayı Sil?'),
        content: const Text(
          'Bu oda ve tüm mesajlar kalıcı olarak silinecek. Bu işlem geri alınamaz!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              try {
                final adminService = ref.read(adminServiceProvider);
                final currentUserId = ref.read(currentUserIdProvider);
                if (currentUserId == null) return;

                await adminService.deleteRoom(
                  roomId: widget.roomId,
                  adminUserId: currentUserId,
                );

                if (!mounted) return;
                
                // Odayı shared preferences'tan sil
                final joinedRoomsService = ref.read(joinedRoomsServiceProvider);
                await joinedRoomsService.removeJoinedRoom(widget.roomId);
                
                // Anasayfaya yönlendir
                Navigator.of(context).popUntil((route) => route.isFirst);
                _showSuccess('Oda silindi');
              } catch (e) {
                if (!mounted) return;
                _showError('Hata: $e');
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Moderator kaldırma dialogu
  void _showRemoveModeratorDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Moderator Kaldır'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Moderator yetkisini kaldırmak istediğiniz kullanıcı adını girin:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'User#1234',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final username = controller.text.trim();
              if (username.isEmpty) return;

              Navigator.pop(context);

              try {
                final userService = ref.read(userServiceProvider);
                final adminService = ref.read(adminServiceProvider);
                final currentUserId = ref.read(currentUserIdProvider);
                if (currentUserId == null) return;

                final targetUser = await userService.getUserByUsername(username);
                
                if (targetUser == null) {
                  if (!mounted) return;
                  _showError('Kullanıcı bulunamadı: $username');
                  return;
                }

                await adminService.removeModerator(
                  roomId: widget.roomId,
                  adminUserId: currentUserId,
                  targetUserId: targetUser.userId,
                );

                if (!mounted) return;
                _showSuccess('Moderator kaldırıldı: $username');
              } catch (e) {
                if (!mounted) return;
                _showError('Hata: $e');
              }
            },
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );
  }

  // Yasaklılar listesi dialogu
  void _showBannedUsersDialog() async {
    final adminService = ref.read(adminServiceProvider);
    final userService = ref.read(userServiceProvider);
    
    try {
      final bannedUserIds = await adminService.getBannedUsers(widget.roomId);
      
      if (!mounted) return;
      
      if (bannedUserIds.isEmpty) {
        _showError('Yasaklı kullanıcı yok');
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Yasaklı Kullanıcılar'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bannedUserIds.length,
              itemBuilder: (context, index) {
                final userId = bannedUserIds[index];
                return FutureBuilder(
                  future: userService.getOrCreateUser(userId),
                  builder: (context, snapshot) {
                    final username = snapshot.data?.username ?? 'User#0000';
                    return ListTile(
                      leading: const Icon(Icons.block, color: Colors.red),
                      title: Text(username),
                      subtitle: Text('ID: ${userId.substring(0, 8)}...'),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Yasağı Kaldır',
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            final currentUserId = ref.read(currentUserIdProvider);
                            if (currentUserId == null) return;

                            await adminService.unbanUser(
                              roomId: widget.roomId,
                              adminUserId: currentUserId,
                              targetUserId: userId,
                            );

                            if (!mounted) return;
                            _showSuccess('Yasak kaldırıldı: $username');
                          } catch (e) {
                            if (!mounted) return;
                            _showError('Hata: $e');
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Hata: $e');
    }
  }

  // Mesaj üzerine long-press menüsü
  void _showMessageMenu(BuildContext context, Message message, String currentUserId) async {
    final adminService = ref.read(adminServiceProvider);
    final blockService = ref.read(blockServiceProvider);
    
    final isAdminOrMod = await adminService.isAdminOrModerator(
      widget.roomId,
      currentUserId,
    );
    final isMyMessage = message.senderId == currentUserId;
    
    // Mesajın sahibi admin mi kontrol et
    final isMessageOwnerAdmin = await adminService.isAdmin(
      widget.roomId,
      message.senderId,
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kendi mesajımı sil
            if (isMyMessage)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Mesajı Sil'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMyMessage(message.messageId);
                },
              ),
            
            // Admin/Mod: Mesaj sil (Moderatör admin mesajını silemez)
            if (isAdminOrMod && !isMyMessage && !isMessageOwnerAdmin)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Mesajı Sil (Moderasyon)'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessageAsMod(message.messageId, message.senderId);
                },
              ),
            
            // Admin/Mod: Kullanıcıyı at (Admin kullanıcı atılamaz)
            if (isAdminOrMod && !isMyMessage && !isMessageOwnerAdmin)
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.orange),
                title: const Text('Kullanıcıyı At'),
                onTap: () {
                  Navigator.pop(context);
                  _kickUser(message.senderId);
                },
              ),
            
            // Kullanıcıyı engelle
            if (!isMyMessage)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.grey),
                title: const Text('Kullanıcıyı Engelle'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await blockService.blockUser(
                      blockerUserId: currentUserId,
                      blockedUserId: message.senderId,
                    );
                    if (mounted) _showSuccess('Kullanıcı engellendi');
                  } catch (e) {
                    if (mounted) _showError('Hata: $e');
                  }
                },
              ),
            
            // Mesajı şikayet et
            if (!isMyMessage)
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.red),
                title: const Text('Mesajı Şikayet Et'),
                onTap: () {
                  Navigator.pop(context);
                  _showError('Şikayet özelliği yakında eklenecek');
                },
              ),
          ],
        ),
      ),
    );
  }

  // Kendi mesajımı sil
  Future<void> _deleteMyMessage(String messageId) async {
    try {
      final messageService = ref.read(messageServiceProvider);
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) return;

      await messageService.deleteMessage(
        roomId: widget.roomId,
        messageId: messageId,
        userId: currentUserId,
      );

      if (mounted) _showSuccess('Mesaj silindi');
    } catch (e) {
      if (mounted) _showError('Hata: $e');
    }
  }

  // Moderator olarak mesaj sil
  Future<void> _deleteMessageAsMod(String messageId, String messageOwnerId) async {
    try {
      final adminService = ref.read(adminServiceProvider);
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) return;

      // Moderatörler admin mesajını silemez
      final isMessageOwnerAdmin = await adminService.isAdmin(
        widget.roomId,
        messageOwnerId,
      );
      
      if (isMessageOwnerAdmin) {
        final isCurrentUserAdmin = await adminService.isAdmin(
          widget.roomId,
          currentUserId,
        );
        
        if (!isCurrentUserAdmin) {
          if (mounted) _showError('Admin mesajları silinemez');
          return;
        }
      }

      await adminService.deleteMessage(
        roomId: widget.roomId,
        messageId: messageId,
        modUserId: currentUserId,
      );

      if (mounted) _showSuccess('Mesaj silindi');
    } catch (e) {
      if (mounted) _showError('Hata: $e');
    }
  }

  // Kullanıcıyı odadan at
  Future<void> _kickUser(String targetUserId) async {
    try {
      final adminService = ref.read(adminServiceProvider);
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) return;

      await adminService.kickUser(
        roomId: widget.roomId,
        modUserId: currentUserId,
        targetUserId: targetUserId,
        reason: 'Odadan atıldı',
      );

      if (mounted) _showSuccess('Kullanıcı odadan atıldı');
    } catch (e) {
      if (mounted) _showError('Hata: $e');
    }
  }

  // Başarı mesajı
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Hata mesajı
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Odadan çıkış onayı
  void _confirmLeaveRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odadan Çık?'),
        content: const Text(
          'Bu odadan çıkmak istediğinize emin misiniz? Odayı tekrar bulmak için oda ID\'sine ihtiyacınız olacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(context); // Dialog'u kapat

              try {
                // Odayı shared preferences'tan sil
                final joinedRoomsService = ref.read(joinedRoomsServiceProvider);
                await joinedRoomsService.removeJoinedRoom(widget.roomId);

                if (!mounted) return;
                
                // Anasayfaya yönlendir
                Navigator.of(context).popUntil((route) => route.isFirst);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Odadan çıkıldı'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                _showError('Hata: $e');
              }
            },
            child: const Text('Çık'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final messagesAsync = ref.watch(messagesProvider(widget.roomId));
    final password = ref.watch(roomPasswordProvider(widget.roomId));
    
    // Ban kontrolü - Kullanıcı kicklenmişse odadan çık
    if (currentUserId != null) {
      ref.listen(isBannedProvider((roomId: widget.roomId, userId: currentUserId)), (previous, next) {
        if (next.hasValue && next.value == true && mounted) {
          // Odayı shared preferences'tan sil
          ref.read(joinedRoomsServiceProvider).removeJoinedRoom(widget.roomId);
          // Anasayfaya yönlendir
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Odadan atıldınız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      
      // Oda silme kontrolü - Oda silinirse anasayfaya yönlendir
      ref.listen(roomStreamProvider(widget.roomId), (previous, next) {
        if (next.hasValue && next.value == null && mounted) {
          // Oda silindi
          ref.read(joinedRoomsServiceProvider).removeJoinedRoom(widget.roomId);
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oda silindi'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
    
    // Admin/Moderator kontrolü
    final isAdminOrMod = currentUserId != null
        ? ref.watch(isAdminOrModeratorProvider((roomId: widget.roomId, userId: currentUserId)))
        : const AsyncValue.data(false);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.roomName),
            Text(
              widget.isEncrypted ? '🔒 Şifreli Oda' : '🔓 Açık Oda',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Admin menüsü
          if (isAdminOrMod.value == true)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Yönetim',
              onPressed: () => _showAdminMenu(context, currentUserId!),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showRoomInfo,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'leave') {
                _confirmLeaveRoom();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Odadan Çık'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: currentUserId != null
          ? ref.watch(isBannedProvider((roomId: widget.roomId, userId: currentUserId))).when(
              data: (isBanned) {
                if (isBanned) {
                  // Banlı kullanıcı için özel UI
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          size: 80,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Bu Odadan Yasaklandınız',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Moderatörler tarafından bu odadan atıldınız. Mesaj gönderemez ve mesajları göremezsiniz.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            ref.read(joinedRoomsServiceProvider).removeJoinedRoom(widget.roomId);
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text('Anasayfaya Dön'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Banlı değilse normal mesajlaşma ekranı
                return messagesAsync.when(
                  data: (messages) {
                    // Mesajları çöz
                    final decryptedMessages = widget.isEncrypted && password != null
                        ? ref
                              .read(messageServiceProvider)
                              .decryptMessages(messages, password)
                        : messages;

                    // Engellenen kullanıcıları filtrele
                    final blockedUsersAsync = ref.watch(blockedUsersProvider(currentUserId));

                    final filteredMessages = blockedUsersAsync.when(
                      data: (blockedUsers) {
                        return decryptedMessages.map((msg) {
                          if (blockedUsers.contains(msg.senderId)) {
                            // Engellenen kullanıcının mesajını gizle
                            return msg.copyWith(text: '[Engellenen kullanıcının mesajı]');
                          }
                          return msg;
                        }).toList();
                      },
                      loading: () => decryptedMessages,
                      error: (_, __) => decryptedMessages,
                    );

                    return Column(
                      children: [
                        Expanded(
                          child: _buildMessageList(filteredMessages, currentUserId),
                        ),
                        _buildMessageInput(),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Mesajlar yüklenemedi: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => messagesAsync.when(
                data: (messages) {
                  // Mesajları çöz
                  final decryptedMessages = widget.isEncrypted && password != null
                      ? ref
                            .read(messageServiceProvider)
                            .decryptMessages(messages, password)
                      : messages;

                  // Engellenen kullanıcıları filtrele
                  final blockedUsersAsync = ref.watch(blockedUsersProvider(currentUserId));

                  final filteredMessages = blockedUsersAsync.when(
                    data: (blockedUsers) {
                      return decryptedMessages.map((msg) {
                        if (blockedUsers.contains(msg.senderId)) {
                          // Engellenen kullanıcının mesajını gizle
                          return msg.copyWith(text: '[Engellenen kullanıcının mesajı]');
                        }
                        return msg;
                      }).toList();
                    },
                    loading: () => decryptedMessages,
                    error: (_, __) => decryptedMessages,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: _buildMessageList(filteredMessages, currentUserId),
                      ),
                      _buildMessageInput(),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Mesajlar yüklenemedi: $error')),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              color: Colors.deepPurple,
              iconSize: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages, String? currentUserId) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz mesaj yok',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk mesajı siz gönderin!',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final showDate =
            index == 0 ||
            !_isSameDay(message.sentAt, messages[index - 1].sentAt);

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.sentAt),
            _buildMessageBubble(message, isMe),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    String dateText;
    if (_isSameDay(date, today)) {
      dateText = 'Bugün';
    } else if (_isSameDay(date, yesterday)) {
      dateText = 'Dün';
    } else {
      dateText = DateFormat('dd MMMM yyyy', 'tr_TR').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade400)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final currentUserId = ref.read(currentUserIdProvider);
    final usernameAsync = ref.watch(usernameProvider(message.senderId));
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: currentUserId != null
            ? () => _showMessageMenu(context, message, currentUserId)
            : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? Colors.deepPurple : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Username (başkalarının mesajları için veya kendimizde "Sen")
              usernameAsync.when(
                data: (username) => isMe
                    ? const Text(
                        'Sen',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          if (username != null) {
                            Clipboard.setData(ClipboardData(text: username));
                            _showSuccess('Kullanıcı adı kopyalandı: $username');
                          }
                        },
                        child: Text(
                          username ?? 'User#0000',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 4),
              Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.sentAt),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
