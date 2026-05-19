import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class RoomService {
  RoomService()
      : _db = FirebaseDatabase.instanceFor(
          databaseURL:
              'https://rumble-de032-default-rtdb.asia-southeast1.firebasedatabase.app/',
        );

  final FirebaseDatabase _db;

  DatabaseReference get _roomsRef => _db.ref('rooms');
  DatabaseReference get _statsRef => _db.ref('stats');
  DatabaseReference get _premiumRef => _db.ref('premium');
  DatabaseReference get _reportsRef => _db.ref('reports');

  Future<String> createRoom(String hostId) async {
    final id = const Uuid().v4().substring(0, 6).toUpperCase();
    await _roomsRef.child(id).set({
      'hostId': hostId,
      'status': 'active',
      'createdAt': ServerValue.timestamp,
      'players': {hostId: true},
      'cards': {
        'AS': {'x': 40.0, 'y': 400.0, 'updatedBy': hostId},
        'KH': {'x': 120.0, 'y': 400.0, 'updatedBy': hostId},
        '7D': {'x': 200.0, 'y': 400.0, 'updatedBy': hostId},
      }
    });
    return id;
  }

  Future<bool> joinRoom(String roomId, String uid) async {
    final normalized = roomId.toUpperCase();
    final roomSnap = await _roomsRef.child(normalized).get();
    if (!roomSnap.exists) return false;

    await _roomsRef.child('$normalized/players/$uid').set(true);
    await _roomsRef
        .child('$normalized/playerMeta/$uid')
        .update({'joinedAt': ServerValue.timestamp, 'role': 'guest'});
    return true;
  }

  Future<String?> joinRandomRoom(String uid) async {
    final rooms = await _roomsRef.get();
    if (!rooms.exists || rooms.value is! Map) return null;

    final map = Map<String, dynamic>.from(rooms.value as Map);
    for (final entry in map.entries) {
      final roomId = entry.key;
      final value = entry.value;
      if (value is! Map) continue;
      final status = value['status'];
      final players = value['players'];
      final playerCount = players is Map ? players.length : 0;
      if (status == 'active' && playerCount < 4) {
        await joinRoom(roomId, uid);
        return roomId;
      }
    }
    return null;
  }

  Stream<Map<String, dynamic>?> watchRoom(String roomId) {
    return _roomsRef.child(roomId.toUpperCase()).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null || value is! Map) return null;
      return Map<String, dynamic>.from(value);
    });
  }

  Future<void> updateCardPosition({
    required String roomId,
    required String cardId,
    required double x,
    required double y,
    required String uid,
  }) async {
    await _roomsRef.child('${roomId.toUpperCase()}/cards/$cardId').update({
      'x': x,
      'y': y,
      'updatedBy': uid,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> saveMatchResult({
    required String uid,
    required bool won,
    required int scoreDelta,
  }) async {
    final ref = _statsRef.child(uid);
    final current = await ref.get();
    final data = (current.value as Map?)?.cast<String, dynamic>() ?? {};
    final wins = (data['wins'] as num?)?.toInt() ?? 0;
    final score = (data['score'] as num?)?.toInt() ?? 0;
    await ref.update({
      'wins': won ? wins + 1 : wins,
      'score': score + scoreDelta,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Stream<Map<String, dynamic>?> watchPremium(String uid) {
    return _premiumRef.child(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null || value is! Map) return null;
      return Map<String, dynamic>.from(value);
    });
  }

  Future<void> reportAbuse({
    required String roomId,
    required String reporterId,
    required String offenderId,
    String reason = 'unspecified',
  }) async {
    await _reportsRef.push().set({
      'roomId': roomId.toUpperCase(),
      'reporterId': reporterId,
      'offenderId': offenderId,
      'reason': reason,
      'createdAt': ServerValue.timestamp,
    });
  }
}
