import 'dart:math';
import '../models/bot_player.dart';

/// AI decision-making engine for bot players
class BotAI {
  final BotPlayer bot;
  final Random _random = Random();

  BotAI(this.bot);

  /// Decide bot's next card move based on difficulty
  /// Returns card position offset
  Map<String, double> decideMovePosition({
    required Map<String, Map<String, double>> currentCardPositions,
    required Map<String, double> screenSize,
  }) {
    return switch (bot.difficulty) {
      BotDifficulty.easy => _easyMove(currentCardPositions, screenSize),
      BotDifficulty.medium => _mediumMove(currentCardPositions, screenSize),
      BotDifficulty.hard => _hardMove(currentCardPositions, screenSize),
    };
  }

  /// Easy difficulty: Random moves anywhere on screen
  Map<String, double> _easyMove(
    Map<String, Map<String, double>> positions,
    Map<String, double> screenSize,
  ) {
    return {
      'x': _random.nextDouble() * (screenSize['width'] ?? 400),
      'y': _random.nextDouble() * (screenSize['height'] ?? 600),
    };
  }

  /// Medium difficulty: Strategic positioning near center
  Map<String, double> _mediumMove(
    Map<String, Map<String, double>> positions,
    Map<String, double> screenSize,
  ) {
    final width = screenSize['width'] ?? 400;
    final height = screenSize['height'] ?? 600;
    final centerX = width / 2;
    final centerY = height / 2;

    // Move towards center with slight randomness
    return {
      'x': centerX + (_random.nextDouble() - 0.5) * 100,
      'y': centerY + (_random.nextDouble() - 0.5) * 100,
    };
  }

  /// Hard difficulty: Optimal play - clusters cards efficiently
  Map<String, double> _hardMove(
    Map<String, Map<String, double>> positions,
    Map<String, double> screenSize,
  ) {
    final width = screenSize['width'] ?? 400;
    final height = screenSize['height'] ?? 600;

    // Find best clustering position (minimize distance to other cards)
    double bestScore = double.infinity;
    late Map<String, double> bestPosition;

    // Sample 10 strategic positions
    for (int i = 0; i < 10; i++) {
      final testX = _random.nextDouble() * width;
      final testY = _random.nextDouble() * height;

      double distanceScore = 0;
      positions.forEach((_, pos) {
        final dx = pos['x']! - testX;
        final dy = pos['y']! - testY;
        distanceScore += sqrt(dx * dx + dy * dy);
      });

      if (distanceScore < bestScore) {
        bestScore = distanceScore;
        bestPosition = {'x': testX, 'y': testY};
      }
    }

    return bestPosition;
  }

  /// Decide match result based on difficulty and skill
  /// Returns true if bot wins
  bool decideMatchOutcome({
    required int playerScore,
    required int botScore,
  }) {
    return switch (bot.difficulty) {
      BotDifficulty.easy =>
        // 70% chance player wins
        _random.nextDouble() > 0.7,
      BotDifficulty.medium =>
        // 50% balanced match
        _random.nextDouble() > 0.5,
      BotDifficulty.hard =>
        // 30% chance player wins (harder)
        _random.nextDouble() > 0.3,
    };
  }

  /// Simulate realistic bot thinking delay (ms)
  int getThinkingDelay() {
    return switch (bot.difficulty) {
      BotDifficulty.easy => 500 + _random.nextInt(1000), // 0.5-1.5s
      BotDifficulty.medium => 1000 + _random.nextInt(1000), // 1-2s
      BotDifficulty.hard => 1500 + _random.nextInt(1000), // 1.5-2.5s
    };
  }

  /// Get bot personality message
  String getPersonalityMessage() {
    final messages = {
      BotDifficulty.easy: [
        'Good luck! 🎮',
        'Let\'s play! 🚀',
        'Ready? 💪',
        'Your turn! ✨',
      ],
      BotDifficulty.medium: [
        'Bring it on! 🔥',
        'Challenge accepted! 💯',
        'Let\'s see what you\'ve got! 🎯',
        'This will be interesting! 🧠',
      ],
      BotDifficulty.hard: [
        'Prepare to lose! 👑',
        'You\'re outmatched! ⚡',
        'Time to show you how it\'s done! 🏆',
        'Your defeat is inevitable! 🎪',
      ],
    };

    final botMessages = messages[bot.difficulty] ?? [];
    return botMessages.isEmpty
        ? 'Let\'s play!'
        : botMessages[_random.nextInt(botMessages.length)];
  }
}
