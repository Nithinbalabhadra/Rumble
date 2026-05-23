import 'package:shared_preferences/shared_preferences.dart';

/// Player statistics and ranking
class PlayerStats {
  final String uid;
  int wins = 0;
  int losses = 0;
  int totalScore = 0;
  int rating = 1200; // Starting ELO rating
  int longestWinStreak = 0;
  int currentWinStreak = 0;
  DateTime firstPlayDate = DateTime.now();
  DateTime lastPlayDate = DateTime.now();

  PlayerStats({required this.uid});

  int get totalMatches => wins + losses;
  double get winRate => totalMatches == 0 ? 0 : (wins / totalMatches) * 100;
  int get averageScore => totalMatches == 0 ? 0 : (totalScore ~/ totalMatches);

  /// Update stats after match
  void updateAfterMatch({
    required bool won,
    required int scoreEarned,
    required int ratingChange,
  }) {
    if (won) {
      wins++;
      currentWinStreak++;
      if (currentWinStreak > longestWinStreak) {
        longestWinStreak = currentWinStreak;
      }
    } else {
      losses++;
      currentWinStreak = 0;
    }
    totalScore += scoreEarned;
    rating += ratingChange;
    lastPlayDate = DateTime.now();
  }

  /// Get player rank based on rating
  String getRank() {
    if (rating >= 2000) return 'Legendary 👑';
    if (rating >= 1700) return 'Master 🏆';
    if (rating >= 1500) return 'Expert 💎';
    if (rating >= 1300) return 'Intermediate 🔶';
    if (rating >= 1200) return 'Beginner 🌟';
    return 'Novice 🎯';
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'wins': wins,
        'losses': losses,
        'totalScore': totalScore,
        'rating': rating,
        'longestWinStreak': longestWinStreak,
        'currentWinStreak': currentWinStreak,
        'firstPlayDate': firstPlayDate.toIso8601String(),
        'lastPlayDate': lastPlayDate.toIso8601String(),
      };

  /// Deserialize from JSON
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(uid: json['uid'] as String)
      ..wins = json['wins'] as int? ?? 0
      ..losses = json['losses'] as int? ?? 0
      ..totalScore = json['totalScore'] as int? ?? 0
      ..rating = json['rating'] as int? ?? 1200
      ..longestWinStreak = json['longestWinStreak'] as int? ?? 0
      ..currentWinStreak = json['currentWinStreak'] as int? ?? 0
      ..firstPlayDate = DateTime.parse(json['firstPlayDate'] as String? ?? DateTime.now().toIso8601String())
      ..lastPlayDate = DateTime.parse(json['lastPlayDate'] as String? ?? DateTime.now().toIso8601String());
  }
}

/// Stats service for managing player statistics
class StatsService {
  static const String _statsPrefix = 'player_stats_';
  static final Map<String, PlayerStats> _statsCache = {};

  /// Get or create player stats
  Future<PlayerStats> getPlayerStats(String uid) async {
    if (_statsCache.containsKey(uid)) {
      return _statsCache[uid]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('$_statsPrefix$uid');

    PlayerStats stats;
    if (statsJson != null) {
      stats = PlayerStats.fromJson(_parseJson(statsJson));
    } else {
      stats = PlayerStats(uid: uid);
      await savePlayerStats(stats);
    }

    _statsCache[uid] = stats;
    return stats;
  }

  /// Save player stats
  Future<void> savePlayerStats(PlayerStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_statsPrefix${stats.uid}',
      _encodeJson(stats.toJson()),
    );
    _statsCache[stats.uid] = stats;
  }

  /// Get top players (leaderboard)
  Future<List<PlayerStats>> getTopPlayers({int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final statsList = <PlayerStats>[];

    for (final key in allKeys) {
      if (key.startsWith(_statsPrefix)) {
        final statsJson = prefs.getString(key);
        if (statsJson != null) {
          statsList.add(PlayerStats.fromJson(_parseJson(statsJson)));
        }
      }
    }

    // Sort by rating (descending)
    statsList.sort((a, b) => b.rating.compareTo(a.rating));
    return statsList.take(limit).toList();
  }

  /// Clear all stats (for testing)
  Future<void> clearAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_statsPrefix)) {
        await prefs.remove(key);
      }
    }
    _statsCache.clear();
  }

  // JSON encoding/decoding helpers
  Map<String, dynamic> _parseJson(String json) {
    try {
      return _simpleJsonParse(json);
    } catch (e) {
      return {};
    }
  }

  String _encodeJson(Map<String, dynamic> json) {
    return _simpleJsonEncode(json);
  }

  // Simple JSON parser (to avoid json package dependency)
  Map<String, dynamic> _simpleJsonParse(String jsonStr) {
    final map = <String, dynamic>{};
    // Remove braces
    final content = jsonStr.replaceAll('{', '').replaceAll('}', '');
    final pairs = content.split(',');
    
    for (final pair in pairs) {
      final kv = pair.split(':');
      if (kv.length == 2) {
        final key = kv[0].replaceAll('"', '').trim();
        var value = kv[1].replaceAll('"', '').trim();
        
        // Try to parse as number
        if (value.contains('.')) {
          map[key] = double.tryParse(value) ?? value;
        } else {
          map[key] = int.tryParse(value) ?? value;
        }
      }
    }
    return map;
  }

  String _simpleJsonEncode(Map<String, dynamic> map) {
    final pairs = <String>[];
    map.forEach((key, value) {
      if (value is String) {
        pairs.add('"$key":"$value"');
      } else {
        pairs.add('"$key":$value');
      }
    });
    return '{${pairs.join(',')}}';
  }
}
