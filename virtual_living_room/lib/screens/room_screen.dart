import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import '../widgets/draggable_card.dart';

class RoomScreen extends StatelessWidget {
  final String roomId;
  const RoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid;
    final roomService = RoomService();

    return Scaffold(
      appBar: AppBar(title: Text('Room $roomId')),
      body: Stack(
        children: [
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
        ],
      ),
    );
  }
}
