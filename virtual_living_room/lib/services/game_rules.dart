/// Game rules and scoring system
class GameRules {
  // Match configuration
  static const int maxPlayersPerRoom = 4;
  static const int minPlayersToStart = 2;
  static const int matchDurationSeconds = 300; // 5 minutes
  static const int turnTimeoutSeconds = 30;

  // Scoring system
  static const int pointsPerCardPlaced = 10;
  static const int pointsPerTurn = 5;
  static const int bonusPointsForWin = 50;
  static const int bonusPointsForCombo = 20; // 3+ cards in sequence

  /// Calculate score for a single move
  static int calculateMoveScore({
    required int cardsPlaced,
    required bool isCombo,
  }) {
    int score = cardsPlaced * pointsPerCardPlaced + pointsPerTurn;
    if (isCombo) score += bonusPointsForCombo;
    return score;
  }

  /// Determine match winner
  static String determineWinner({
    required int player1Score,
    required int player2Score,
  }) {
    if (player1Score > player2Score) return 'player1';
    if (player2Score > player1Score) return 'player2';
    return 'draw';
  }

  /// Calculate rank points (Elo-style)
  static int calculateRankPoints({
    required int playerRating,
    required int opponentRating,
    required bool won,
    required int scoreDifference,
  }) {
    const k = 32; // K-factor for Elo calculation
    final expectedScore = 1 / (1 + pow(10, (opponentRating - playerRating) / 400));
    final actual = won ? 1.0 : 0.0;
    final ratingChange = (k * (actual - expectedScore)).toInt();
    return ratingChange;
  }

  /// Validate if a move is legal
  static bool isLegalMove({
    required String cardId,
    required Map<String, double> newPosition,
    required Map<String, double> screenSize,
  }) {
    // Card must be within screen bounds
    final withinX = newPosition['x']! >= 0 && newPosition['x']! <= (screenSize['width'] ?? 400);
    final withinY = newPosition['y']! >= 0 && newPosition['y']! <= (screenSize['height'] ?? 600);
    return withinX && withinY;
  }

  /// Check if player achieved combo (3+ consecutive moves)
  static bool isCombo({
    required List<String> lastMoves,
  }) {
    return lastMoves.length >= 3;
  }

  /// Get reward multiplier based on match duration
  static double getTimeMultiplier({
    required int secondsElapsed,
  }) {
    if (secondsElapsed < 60) return 1.5; // Quick win bonus
    if (secondsElapsed < 180) return 1.0; // Normal
    return 0.8; // Prolonged match (lower multiplier)
  }
}

import 'dart:math';
