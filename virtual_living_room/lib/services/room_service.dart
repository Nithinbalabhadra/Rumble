import 'dart:async';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';

abstract class RoomRepository {
  Future<String> createRoom(String hostId);
  Future<bool> joinRoom(String roomId, String uid);
  Future<String?> joinRandomRoom(String uid);
  Stream<Map<String, dynamic>?> watchRoom(String roomId);
  Future<void> updateCardPosition({
    required String roomId,
    required String cardId,
    required double x,
    required double y,
    required String uid,
  });
  Future<void> saveMatchResult({
    required String uid,
    required bool won,
    required int scoreDelta,
  });
  Future<void> reportAbuse({
    required String roomId,
    required String reporterId,
    required String offenderId,
    String reason,
  });
}

class LocalRoomRepository implements RoomRepository {
  static final Map<String, Map<String, dynamic>> _rooms = {};
  static final Map<String, Map<String, dynamic>> _stats = {};
  final StreamController<Map<String, dynamic>?> _roomController =
      StreamController<Map<String, dynamic>?>.broadcast();

  @override
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

  @override
  Future<bool> joinRoom(String roomId, String uid) async {
    final room = _rooms[roomId.toUpperCase()];
    if (room == null) return false;
    (room['players'] as Map<String, dynamic>)[uid] = true;
    _roomController.add(room);
    return true;
  }

  @override
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

  @override
  Stream<Map<String, dynamic>?> watchRoom(String roomId) async* {
    yield _rooms[roomId.toUpperCase()];
    yield* _roomController.stream;
  }

  @override
  Future<void> updateCardPosition({required String roomId, required String cardId, required double x, required double y, required String uid}) async {
    final room = _rooms[roomId.toUpperCase()];
    if (room == null) return;
    final cards = room['cards'] as Map<String, dynamic>;
    cards[cardId] = {'x': x, 'y': y, 'updatedBy': uid};
    _roomController.add(room);
  }

  @override
  Future<void> saveMatchResult({required String uid, required bool won, required int scoreDelta}) async {
    final stat = _stats[uid] ?? {'wins': 0, 'score': 0};
    stat['wins'] = (stat['wins'] as int) + (won ? 1 : 0);
    stat['score'] = (stat['score'] as int) + scoreDelta;
    _stats[uid] = stat;
  }

  @override
  Future<void> reportAbuse({required String roomId, required String reporterId, required String offenderId, String reason = 'unspecified'}) async {}
}

class RemoteRoomRepository extends LocalRoomRepository {
  // Placeholder for future backend integration. Currently delegates to local mode.
}

class RoomService {
  RoomService._(this._repo);

  final RoomRepository _repo;

  static final RoomService instance = RoomService._(
    AppConfig.dataMode == DataMode.remote
        ? RemoteRoomRepository()
        : LocalRoomRepository(),
  );

  Future<String> createRoom(String hostId) => _repo.createRoom(hostId);
  Future<bool> joinRoom(String roomId, String uid) => _repo.joinRoom(roomId, uid);
  Future<String?> joinRandomRoom(String uid) => _repo.joinRandomRoom(uid);
  Stream<Map<String, dynamic>?> watchRoom(String roomId) => _repo.watchRoom(roomId);
  Future<void> updateCardPosition({required String roomId, required String cardId, required double x, required double y, required String uid}) =>
      _repo.updateCardPosition(roomId: roomId, cardId: cardId, x: x, y: y, uid: uid);
  Future<void> saveMatchResult({required String uid, required bool won, required int scoreDelta}) =>
      _repo.saveMatchResult(uid: uid, won: won, scoreDelta: scoreDelta);
  Future<void> reportAbuse({required String roomId, required String reporterId, required String offenderId, String reason = 'unspecified'}) =>
      _repo.reportAbuse(roomId: roomId, reporterId: reporterId, offenderId: offenderId, reason: reason);
}
