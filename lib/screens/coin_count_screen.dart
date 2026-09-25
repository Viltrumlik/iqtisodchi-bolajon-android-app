import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../utils/format.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import '../widgets/celebration_overlay.dart';

/// Coin-counting game for early learners.
/// Shows a random number of coins; the child taps the matching number.
class CoinCountScreen extends StatefulWidget {
  const CoinCountScreen({super.key});

  @override
  State<CoinCountScreen> createState() => _CoinCountScreenState();
}

class _CoinCountScreenState extends State<CoinCountScreen>
    with TickerProviderStateMixin {
  static const int _reward = 2000;
  static const int _minCoins = 2;
  static const int _maxCoins = 10;

  late int _count; // correct number of coins
  late List<int> _options; // 4 answer choices

  bool _showOverlay = false;
  bool _overlaySuccess = false;
  String _overlayMessage = '';
  String? _overlaySubMessage;
  bool _locked = false;

  int _roundsPlayed = 0;
  int _roundsCorrect = 0;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -12, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _newRound(initial: true);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _newRound({bool initial = false}) {
    _count = _minCoins + _rng.nextInt(_maxCoins - _minCoins + 1);

    // Build 4 unique options around the correct count.
    final opts = <int>{_count};
    while (opts.length < 4) {
      final delta = _rng.nextInt(5) - 2; // -2..+2
      final v = _count + delta;
      if (v >= 1 && v <= _maxCoins + 2 && v != _count) opts.add(v);
    }
    _options = opts.toList()..shuffle(_rng);

    _locked = false;
    if (!initial) setState(() {});
  }

  Future<void> _onAnswer(int value) async {
    if (_locked || _showOverlay) return;
    _locked = true;
    _roundsPlayed++;
    final correct = value == _count;

    if (correct) {
      _roundsCorrect++;
      await context.read<GameStateService>().addMoney(_reward);
    } else {
      _shakeCtrl.forward(from: 0);
    }
    if (!mounted) return;
    setState(() {
      _overlaySuccess = correct;
      _overlayMessage = correct ? '🎉 To\'g\'ri!' : 'Yana sanab ko\'r 😅';
      _overlaySubMessage = correct
          ? '$_count ta tanga bor edi!\n+${formatMoney(_reward)} mukofot!'
          : 'Tangalarni birma-bir sana.';
      _showOverlay = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const CircleBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🪙 Tanga sanash',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            if (_roundsPlayed > 0)
                              Text(
                                '✅ $_roundsCorrect / $_roundsPlayed to\'g\'ri',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const MoneyDisplay(),
                    ],
                  ),
                ),

                // White content area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0FBFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),

                        // Question
                        const Text(
                          '🪙 Nechta tanga bor?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0277BD),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Coins
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _shakeAnim,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(_shakeAnim.value, 0),
                              child: child,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (var i = 0; i < _count; i++)
                                      const Text('🪙',
                                              style: TextStyle(fontSize: 46))
                                          .animate(delay: (i * 60).ms)
                                          .fadeIn(duration: 220.ms)
                                          .scale(
                                            begin: const Offset(0.5, 0.5),
                                            end: const Offset(1, 1),
                                            curve: Curves.elasticOut,
                                            duration: 320.ms,
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Answer number buttons
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final opt in _options)
                                _NumberButton(
                                  value: opt,
                                  onTap: () => _onAnswer(opt),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_showOverlay)
            CelebrationOverlay(
              success: _overlaySuccess,
              message: _overlayMessage,
              subMessage: _overlaySubMessage,
              onDismiss: () {
                final wasSuccess = _overlaySuccess;
                setState(() {
                  _showOverlay = false;
                  _locked = false;
                });
                if (wasSuccess) _newRound();
              },
            ),
        ],
      ),
    );
  }
}

// ── Number answer button ────────────────────────────────────────────────────

class _NumberButton extends StatelessWidget {
  final int value;
  final VoidCallback onTap;

  const _NumberButton({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 66,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2193B0), Color(0xFF0277BD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2193B0).withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
