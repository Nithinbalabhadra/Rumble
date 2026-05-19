import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import 'room_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _roomIdController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading) const CircularProgressIndicator(),
            if (!_loading) ...[
              ElevatedButton(
                child: const Text('Create Room'),
                onPressed: uid == null
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        final roomId = await RoomService().createRoom(uid);
                        if (!mounted) return;
                        setState(() => _loading = false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoomScreen(roomId: roomId),
                          ),
                        );
                      },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child: const Text('Join Random Room'),
                onPressed: uid == null
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        final roomId = await RoomService().joinRandomRoom(uid);
                        if (!mounted) return;
                        setState(() => _loading = false);
                        if (roomId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No room available.')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoomScreen(roomId: roomId),
                          ),
                        );
                      },
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _roomIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Enter Room ID'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                child: const Text('Join Room'),
                onPressed: uid == null
                    ? null
                    : () async {
                        final roomId = _roomIdController.text.trim().toUpperCase();
                        if (roomId.isEmpty) return;
                        setState(() => _loading = true);
                        final ok = await RoomService().joinRoom(roomId, uid);
                        if (!mounted) return;
                        setState(() => _loading = false);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Room not found.')),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoomScreen(roomId: roomId),
                          ),
                        );
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
