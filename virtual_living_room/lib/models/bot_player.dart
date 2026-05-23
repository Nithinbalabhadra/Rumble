enum BotDifficulty { easy, medium, hard }

class BotPlayer {
  final String id;
  final String displayName;
  final BotDifficulty difficulty;
  final String profileImagePath;
  int wins = 0;
  int score = 0;
  bool isActive = true;

  BotPlayer({
    required this.id,
    required this.displayName,
    required this.difficulty,
    this.profileImagePath = 'assets/bot_avatar.png',
  });

  /// Generate a realistic bot name
  static String generateBotName(BotDifficulty difficulty) {
    const easyNames = [
      'Bot Junior',
      'Rookie AI',
      'Learner Bot',
      'Practice Bot',
      'Casual Player'
    ];
    const mediumNames = [
      'Balanced Bot',
      'Mid Tier AI',
      'Experienced Bot',
      'Pro Player',
      'Strategy Bot'
    ];
    const hardNames = [
      'Master AI',
      'Elite Bot',
      'Champion AI',
      'Legendary Player',
      'Expert AI'
    ];

    final names = switch (difficulty) {
      BotDifficulty.easy => easyNames,
      BotDifficulty.medium => mediumNames,
      BotDifficulty.hard => hardNames,
    };

    return names[DateTime.now().millisecond % names.length];
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'difficulty': difficulty.name,
        'profileImagePath': profileImagePath,
        'wins': wins,
        'score': score,
        'isActive': isActive,
      };

  /// Create from JSON
  factory BotPlayer.fromJson(Map<String, dynamic> json) {
    return BotPlayer(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      difficulty: BotDifficulty.values
          .firstWhere((e) => e.name == json['difficulty']),
      profileImagePath: json['profileImagePath'] as String? ?? 'assets/bot_avatar.png',
    )
      ..wins = json['wins'] as int? ?? 0
      ..score = json['score'] as int? ?? 0
      ..isActive = json['isActive'] as bool? ?? true;
  }
}
