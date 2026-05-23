import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/bot_player.dart';
import 'bot_ai.dart';

/// Manages bot player creation, behavior, and lifecycle
class BotService {
  static final BotService _instance = BotService._internal();
  final Map<String, BotPlayer> _activeBots = {};
  final Map<String, BotAI> _botAIs = {};

  factory BotService() {
    return _instance;
  }

  BotService._internal();

  /// Create and add a bot to a room
  BotPlayer createBot({
    required BotDifficulty difficulty,
    String? customName,
  }) {
    final botId = const Uuid().v4().substring(0, 8);
    final botName = customName ?? BotPlayer.generateBotName(difficulty);

    final bot = BotPlayer(
      id: botId,
      displayName: botName,
      difficulty: difficulty,
    );

    _activeBots[botId] = bot;
    _botAIs[botId] = BotAI(bot);

    return bot;
  }

  /// Get all active bots
  List<BotPlayer> getActiveBots() => _activeBots.values.toList();

  /// Get a specific bot by ID
  BotPlayer? getBot(String botId) => _activeBots[botId];

  /// Get bot's AI engine
  BotAI? getBotAI(String botId) => _botAIs[botId];

  /// Remove bot from active roster
  void removeBot(String botId) {
    _activeBots.remove(botId);
    _botAIs.remove(botId);
  }

  /// Populate a room with bots if needed
  /// Returns list of bots added
  List<BotPlayer> populateRoomWithBots({
    required String roomId,
    required int currentPlayerCount,
    required int targetPlayerCount,
    required BotDifficulty preferredDifficulty,
  }) {
    final botsToAdd = targetPlayerCount - currentPlayerCount;
    final addedBots = <BotPlayer>[];

    for (int i = 0; i < botsToAdd; i++) {
      final bot = createBot(difficulty: preferredDifficulty);
      addedBots.add(bot);
    }

    return addedBots;
  }

  /// Simulate bot move in a room (with thinking delay)
  Future<Map<String, double>> simulateBotMove({
    required String botId,
    required Map<String, Map<String, double>> currentPositions,
    required Map<String, double> screenSize,
  }) async {
    final botAI = getBotAI(botId);
    if (botAI == null) return {};

    // Simulate thinking time
    await Future.delayed(
      Duration(milliseconds: botAI.getThinkingDelay()),
    );

    return botAI.decideMovePosition(
      currentCardPositions: currentPositions,
      screenSize: screenSize,
    );
  }

  /// Get realistic bot match outcome
  bool getBotMatchOutcome({
    required String botId,
    required int playerScore,
    required int botScore,
  }) {
    final botAI = getBotAI(botId);
    if (botAI == null) return false;

    return botAI.decideMatchOutcome(
      playerScore: playerScore,
      botScore: botScore,
    );
  }

  /// Update bot stats after match
  void updateBotStats({
    required String botId,
    required bool won,
    required int scoreDelta,
  }) {
    final bot = getBot(botId);
    if (bot != null) {
      if (won) bot.wins++;
      bot.score += scoreDelta;
    }
  }

  /// Clear all bots (useful for testing or cleanup)
  void clearAllBots() {
    _activeBots.clear();
    _botAIs.clear();
  }

  /// Get list of available bots for matchmaking
  List<BotPlayer> getAvailableBotsForMatchmaking({
    required BotDifficulty difficulty,
  }) {
    return _activeBots.values
        .where((bot) => bot.difficulty == difficulty && bot.isActive)
        .toList();
  }
}
