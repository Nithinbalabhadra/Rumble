import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import '../widgets/draggable_card.dart';

class RoomScreen extends StatefulWidget {
  final String roomId;
  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  static const _kDefaultCardPositions = {
    'AS': {'x': 40.0, 'y': 400.0},
    'KH': {'x': 120.0, 'y': 400.0},
  };

  late Map<String, Map<String, double>> _positions;

  @override
  void initState() {
    super.initState();
    _positions = {
      for (final e in _kDefaultCardPositions.entries)
        e.key: {'x': e.value['x']!, 'y': e.value['y']!},
    };
    _loadSavedPositions();
  }

  String get _storageKey => 'room_${widget.roomId}_card_positions';

  Future<void> _loadSavedPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    setState(() {
      _positions = decoded.map((key, value) {
        final card = value as Map<String, dynamic>;
        return MapEntry(key, {
          'x': (card['x'] as num).toDouble(),
          'y': (card['y'] as num).toDouble(),
        });
      });
    });
  }

  Future<void> _savePositions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_positions));
  }

  Future<void> _onCardDragEnd({
    required String cardId,
    required Offset pos,
    required RoomService roomService,
    required String? uid,
  }) async {
    setState(() {
      _positions[cardId] = {'x': pos.dx, 'y': pos.dy};
    });
    await _savePositions();

    if (uid != null) {
      await roomService.updateCardPosition(
        roomId: widget.roomId,
        cardId: cardId,
        x: pos.dx,
        y: pos.dy,
        uid: uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid;
    final roomService = RoomService.instance;

    return Scaffold(
      appBar: AppBar(title: Text('Room ${widget.roomId}')),
      body: Stack(
        children: [
          DraggableCard(
            cardId: 'AS',
            label: 'A♠',
            initialPosition: Offset(_positions['AS']?['x'] ?? 40, _positions['AS']?['y'] ?? 400),
            onDragEnd: (pos) => _onCardDragEnd(cardId: 'AS', pos: pos, roomService: roomService, uid: uid),
          ),
          DraggableCard(
            cardId: 'KH',
            label: 'K♥',
            initialPosition: Offset(_positions['KH']?['x'] ?? 120, _positions['KH']?['y'] ?? 400),
            onDragEnd: (pos) => _onCardDragEnd(cardId: 'KH', pos: pos, roomService: roomService, uid: uid),
          ),
        ],
      ),
    );
  }
}
