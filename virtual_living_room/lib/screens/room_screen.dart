import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/room_service.dart';
import '../widgets/draggable_card.dart';

class RoomScreen extends StatelessWidget {
  final String roomId;
  const RoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final roomService = RoomService();

    return Scaffold(
      appBar: AppBar(title: Text('Room $roomId')),
      body: Stack(
        children: [
          StreamBuilder<Map<String, dynamic>?>(
            stream: roomService.watchRoom(roomId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('Room unavailable'));
              }
              return const SizedBox.shrink();
            },
          ),
          DraggableCard(
            cardId: 'AS',
            label: 'A♠',
            onDragEnd: uid == null
                ? null
                : (pos) => roomService.updateCardPosition(
                      roomId: roomId,
                      cardId: 'AS',
                      x: pos.dx,
                      y: pos.dy,
                      uid: uid,
                    ),
          ),
          DraggableCard(
            cardId: 'KH',
            label: 'K♥',
            initialPosition: const Offset(120, 400),
            onDragEnd: uid == null
                ? null
                : (pos) => roomService.updateCardPosition(
                      roomId: roomId,
                      cardId: 'KH',
                      x: pos.dx,
                      y: pos.dy,
                      uid: uid,
                    ),
          ),
          DraggableCard(
            cardId: '7D',
            label: '7♦',
            initialPosition: const Offset(200, 400),
            onDragEnd: uid == null
                ? null
                : (pos) => roomService.updateCardPosition(
                      roomId: roomId,
                      cardId: '7D',
                      x: pos.dx,
                      y: pos.dy,
                      uid: uid,
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.flag),
        onPressed: uid == null
            ? null
            : () async {
                await roomService.reportAbuse(
                  roomId: roomId,
                  reporterId: uid,
                  offenderId: uid,
                  reason: 'manual_report',
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report sent.')),
                );
              },
      ),
    );
  }
}
