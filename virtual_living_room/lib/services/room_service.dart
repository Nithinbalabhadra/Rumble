import 'dart:async';
import 'package:uuid/uuid.dart';

class RoomService {
  static final Map<String, Map<String, dynamic>> _rooms = {};
  static final Map<String, Map<String, dynamic>> _stats = {};

  final StreamController<Map<String, dynamic>?> _roomController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Future<String> createRoom(String hostId) async {
    final id = const Uuid().v4().substring(0, 6).toUpperCase();
    _rooms[id] = {
      'hostId': hostId,
      'status': 'active',
      'players': {hostId: true},
      'cards': {
        'AS': {'x': 40.0, 'y': 400.0, 'updatedBy': hostId},
        'KH': {'x': 120.0, 'y': 400.0, 'updatedBy': hostId},
        '7D': {'x': 200.0, 'y': 400.0, 'updatedBy': hostId},
      }
    };
    _roomController.add(_rooms[id]);
    return id;
  }

  Future<bool> joinRoom(String roomId, String uid) async {
    final normalized = roomId.toUpperCase();
    final room = _rooms[normalized];
    if (room == null) return false;
    (room['players'] as Map<String, dynamic>)[uid] = true;
    _roomController.add(room);
    return true;
  }

  Future<String?> joinRandomRoom(String uid) async {
    for (final entry in _rooms.entries) {
      final players = (entry.value['players'] as Map<String, dynamic>);
      if (entry.value['status'] == 'active' && players.length < 4) {
        await joinRoom(entry.key, uid);
        return entry.key;
      }
    }
    return null;
  }

  Stream<Map<String, dynamic>?> watchRoom(String roomId) async* {
    yield _rooms[roomId.toUpperCase()];
    yield* _roomController.stream;
  }

  Future<void> updateCardPosition({
    required String roomId,
    required String cardId,
    required double x,
    required double y,
    required String uid,
  }) async {
    final room = _rooms[roomId.toUpperCase()];
    if (room == null) return;
    final cards = room['cards'] as Map<String, dynamic>;
    cards[cardId] = {'x': x, 'y': y, 'updatedBy': uid};
    _roomController.add(room);
  }

  Future<void> saveMatchResult({
    required String uid,
    required bool won,
    required int scoreDelta,
  }) async {
    final stat = _stats[uid] ?? {'wins': 0, 'score': 0};
    stat['wins'] = (stat['wins'] as int) + (won ? 1 : 0);
    stat['score'] = (stat['score'] as int) + scoreDelta;
    _stats[uid] = stat;
  }

  Future<void> reportAbuse({
    required String roomId,
    required String reporterId,
    required String offenderId,
    String reason = 'unspecified',
  }) async {}
}
