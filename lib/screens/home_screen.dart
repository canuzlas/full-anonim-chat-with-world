import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../services/joined_rooms_service.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ensureAuthenticated();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _ensureAuthenticated() async {
    final authService = ref.read(authServiceProvider);
    await authService.ensureSignedIn();
  }

  Future<void> _joinGlobalRoom() async {
    const globalRoomId = 'global-chat-room';
    final roomService = ref.read(roomServiceProvider);
    final authService = ref.read(authServiceProvider);
    final joinedRoomsService = ref.read(joinedRoomsServiceProvider);

    try {
      final userId = authService.currentUserId;
      if (userId == null) return;

      // Global odayı kontrol et, yoksa oluştur
      var room = await roomService.getRoomById(globalRoomId);
      
      if (room == null) {
        room = await roomService.createGlobalRoom(
          createdBy: userId,
        );
      }

      // Kullanıcı bu odadan banlı mı kontrol et
      if (room.isBanned(userId)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Global odadan yasaklandınız. Giriş yapamazsınız.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Katılınan odayı kaydet
      await joinedRoomsService.addJoinedRoom(
        JoinedRoom(
          roomId: room.roomId,
          roomName: room.name,
          isEncrypted: false,
          joinedAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            roomId: room!.roomId,
            roomName: room.name,
            isEncrypted: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Global odaya katılınamadı: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonim Chat'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Ana Sayfa'),
            Tab(icon: Icon(Icons.history), text: 'Odalarım'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.block),
            tooltip: 'Engellenenler',
            onPressed: () => _showBlockedUsersDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildHomePage(),
              _buildMyRoomsPage(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Hata: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _joinGlobalRoom,
        icon: const Icon(Icons.public),
        label: const Text('Global Chat'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.lock_outline,
            size: 100,
            color: Colors.deepPurple.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'Güvenli & Anonim',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Uçtan uca şifrelenmiş özel sohbet odaları',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 40),

          // Yeni oda oluştur butonu
          _buildActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateRoomScreen(),
                ),
              );
            },
            icon: Icons.add_circle_outline,
            label: 'Yeni Oda Oluştur',
            isPrimary: true,
          ),
          const SizedBox(height: 16),

          // Odaya katıl butonu
          _buildActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JoinRoomScreen(),
                ),
              );
            },
            icon: Icons.meeting_room_outlined,
            label: 'Odaya Katıl',
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return isPrimary
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 24),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(label, style: const TextStyle(fontSize: 16)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 24),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(label, style: const TextStyle(fontSize: 16)),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
  }

  Widget _buildMyRoomsPage() {
    final currentUserId = ref.watch(currentUserIdProvider);
    
    return FutureBuilder<List<JoinedRoom>>(
      future: ref.read(joinedRoomsServiceProvider).getJoinedRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final joinedRooms = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: CustomScrollView(
            slivers: [
              // Katıldığım Odalar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Katıldığım Odalar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              joinedRooms.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz hiçbir odaya katılmadınız',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final room = joinedRooms[index];
                          return _buildRoomCard(room);
                        },
                        childCount: joinedRooms.length,
                      ),
                    ),

              // Oluşturduğum Odalar
              if (currentUserId != null) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Text(
                      'Oluşturduğum Odalar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                _buildUserRoomsSliver(currentUserId),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoomCard(JoinedRoom room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor:
              room.isEncrypted ? Colors.green.shade100 : Colors.blue.shade100,
          child: Icon(
            room.isEncrypted ? Icons.lock : Icons.lock_open,
            color: room.isEncrypted ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          room.roomName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatDate(room.joinedAt),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final currentUserId = ref.read(currentUserIdProvider);
          if (currentUserId == null) return;

          // Odanın güncel durumunu kontrol et
          final roomService = ref.read(roomServiceProvider);
          final currentRoom = await roomService.getRoomById(room.roomId);

          if (currentRoom == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Oda artık mevcut değil'),
                backgroundColor: Colors.orange,
              ),
            );
            // Odayı listeden kaldır
            ref.read(joinedRoomsServiceProvider).removeJoinedRoom(room.roomId);
            setState(() {});
            return;
          }

          // Ban kontrolü
          if (currentRoom.isBanned(currentUserId)) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bu odadan yasaklandınız. Giriş yapamazsınız.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
            return;
          }

          // Şifreyi provider'a yükle
          if (room.isEncrypted && room.password != null) {
            ref.read(roomPasswordProvider(room.roomId).notifier).state =
                room.password;
          }

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                roomId: room.roomId,
                roomName: room.roomName,
                isEncrypted: room.isEncrypted,
              ),
            ),
          );
        },
        onLongPress: () => _showRoomOptions(room),
      ),
    );
  }

  Widget _buildUserRoomsSliver(String userId) {
    final userRooms = ref.watch(userRoomsProvider(userId));

    return userRooms.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Henüz oda oluşturmadınız',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final room = rooms[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    room.isEncrypted ? Icons.lock : Icons.lock_open,
                    color: room.isEncrypted ? Colors.green : Colors.grey,
                  ),
                  title: Text(room.name),
                  subtitle: Text('Oluşturuldu: ${_formatDate(room.createdAt)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          roomId: room.roomId,
                          roomName: room.name,
                          isEncrypted: room.isEncrypted,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            childCount: rooms.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Text('Odalar yüklenemedi: $error'),
      ),
    );
  }

  void _showRoomOptions(JoinedRoom room) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Listeden Kaldır'),
              onTap: () async {
                await ref
                    .read(joinedRoomsServiceProvider)
                    .removeJoinedRoom(room.roomId);
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showBlockedUsersDialog(BuildContext context) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    final blockService = ref.read(blockServiceProvider);
    final userService = ref.read(userServiceProvider);

    // Engellenen kullanıcıları al
    final blockedUsersStream = blockService.getBlockedUsers(currentUserId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Engellenen Kullanıcılar'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder(
            stream: blockedUsersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text('Hata oluştu');
              }

              final blocks = snapshot.data ?? [];

              if (blocks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Engellenen kullanıcı yok',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: blocks.length,
                itemBuilder: (context, index) {
                  final block = blocks[index];
                  return FutureBuilder(
                    future: userService.getOrCreateUser(block.blockedUserId),
                    builder: (context, userSnapshot) {
                      final username = userSnapshot.data?.username ?? 'User#0000';
                      return ListTile(
                        leading: const Icon(Icons.block, color: Colors.red),
                        title: Text(username),
                        subtitle: Text('ID: ${block.blockedUserId.substring(0, 8)}...'),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: 'Engeli Kaldır',
                          onPressed: () async {
                            try {
                              await blockService.unblockUser(
                                blockerUserId: currentUserId,
                                blockedUserId: block.blockedUserId,
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$username engeli kaldırıldı'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Hata: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
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
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anonim Chat Hakkında'),
        content: const Text(
          'Bu uygulama tamamen anonim ve güvenli sohbet odaları oluşturmanıza olanak tanır.\n\n'
          '✅ Hesap oluşturma gerekmez\n'
          '✅ Uçtan uca şifreleme\n'
          '✅ Özel oda linkleri\n'
          '✅ Kimlik bilgisi saklanmaz\n'
          '🌍 Global chat room',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
