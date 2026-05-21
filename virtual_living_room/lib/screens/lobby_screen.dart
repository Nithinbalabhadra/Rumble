import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import '../widgets/trial_paywall_widget.dart';
import 'room_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _loading = false;
  final _auth = AuthService();
  final _roomService = RoomService.instance;

  Future<void> _handleCreateRoom(String uid) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!user.isPremiumHost) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const TrialPaywallWidget(
          upiId: 'yourname@upi',
          whatsappSupport: '+91-9000000000',
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final roomId = await _roomService.createRoom(uid);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomScreen(roomId: roomId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Lobby (Dual Mode Ready)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_loading) const CircularProgressIndicator(),
          if (!_loading) ...[
            ElevatedButton(
              onPressed: uid == null ? null : () => _handleCreateRoom(uid),
              child: const Text('Create Room (Premium Host)'),
            ),
            ElevatedButton(
              onPressed: uid == null
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      final roomId = await _roomService.joinRandomRoom(uid);
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
                        MaterialPageRoute(builder: (_) => RoomScreen(roomId: roomId)),
                      );
                    },
              child: const Text('Join Random Room (Free)'),
            ),
          ]
        ]),
      ),
    );
  }
}
