import 'package:flutter/material.dart';
import '../services/bot_service.dart';
import '../models/bot_player.dart';

class MatchResultScreen extends StatefulWidget {
  final String roomId;
  final bool playerWon;
  final int playerScore;
  final int opponentScore;
  final String opponentName;

  const MatchResultScreen({
    super.key,
    required this.roomId,
    required this.playerWon,
    required this.playerScore,
    required this.opponentScore,
    required this.opponentName,
  });

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.playerWon
                ? [Colors.green[900]!, Colors.green[700]!]
                : [Colors.red[900]!, Colors.red[700]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0, 0.5, curve: Curves.elasticOut),
                    ),
                  ),
                  child: Text(
                    widget.playerWon ? '🎉 YOU WIN! 🎉' : '💔 You Lost',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                _buildScoreCard('You', widget.playerScore, Colors.blue),
                const SizedBox(height: 20),
                const Text('vs', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 20),
                _buildScoreCard(widget.opponentName, widget.opponentScore, Colors.orange),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Lobby'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Colors.white,
                    foregroundColor: widget.playerWon ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String name, int score, Color color) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
        ),
      ),
      child: Card(
        elevation: 8,
        color: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                score.toString(),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Points',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
