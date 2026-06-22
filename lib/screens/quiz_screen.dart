import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/quiz_question.dart';
import '../services/game_state_service.dart';
import '../services/sound_service.dart';
import '../utils/format.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import '../widgets/quiz_option_button.dart';
import '../widgets/celebration_overlay.dart';

const int _kTimerSeconds = 45;

/// Multiple-choice quiz with 45-second countdown per question.
/// Accepts a pre-filtered question list (e.g. from a quiz group).
/// Reward decreases as time runs out; 0 points if timer expires.
class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _revealed = false;
  bool _showOverlay = false;
  bool _overlaySuccess = false;
  String _overlayMessage = '';
  String? _overlaySubMessage;

  int _correctCount = 0;
  int _sessionEarned = 0;

  // Timer state
  int _timeLeft = _kTimerSeconds;
  Timer? _timer;
  bool _timedOut = false;

  late List<QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  QuizQuestion get _current => _questions[_currentIndex];

  // Reward scales linearly: full at 30s, min 500 at 1s, 0 if timed out.
  int get _currentReward {
    if (_timedOut) return 0;
    final base = _current.reward;
    final fraction = _timeLeft / _kTimerSeconds;
    return (base * fraction).round().clamp(500, base);
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _kTimerSeconds;
    _timedOut = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_revealed) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 5 && _timeLeft > 0) SoundService().tick();
      if (_timeLeft <= 0) {
        t.cancel();
        _onTimedOut();
      }
    });
  }

  void _onTimedOut() {
    if (_revealed) return;
    SoundService().wrong();
    setState(() {
      _timedOut = true;
      _selectedIndex = null;
      _revealed = true;
      _overlaySuccess = false;
      _overlayMessage = 'Vaqt tugadi! ⏰';
      _overlaySubMessage = 'Keyingi safar tezroq bo\'l!';
      _showOverlay = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF1A936F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────────
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
                              '🧠 Test',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Savol ${_currentIndex + 1} / ${_questions.length}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const MoneyDisplay(),
                    ],
                  ),
                ),

                // Question progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _questions.length,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Timer bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TimerBar(
                    timeLeft: _timeLeft,
                    total: _kTimerSeconds,
                    revealed: _revealed,
                    currentReward: _currentReward,
                    baseReward: _current.reward,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Main card ──────────────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4FBF9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Reward badge (updates as timer ticks)
                            Align(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  key: ValueKey(_currentReward),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _rewardColor(_currentReward, _current.reward),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '🏆 +${formatMoney(_revealed ? (_timedOut ? 0 : _currentReward) : _currentReward)} mukofot',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 60.ms, duration: 280.ms),

                            const SizedBox(height: 18),

                            // Question text
                            Text(
                              _current.question,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                height: 1.5,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 350.ms)
                                .slideY(begin: -0.12, end: 0),

                            const SizedBox(height: 20),

                            // Options
                            ...List.generate(_current.options.length, (i) {
                              OptionState state = OptionState.idle;
                              if (_revealed) {
                                if (i == _current.correctIndex) {
                                  state = OptionState.correct;
                                } else if (i == _selectedIndex) {
                                  state = OptionState.wrong;
                                }
                              }
                              return QuizOptionButton(
                                key: ValueKey('$_currentIndex-$i'),
                                text: _current.options[i],
                                state: state,
                                index: i,
                                onTap: _revealed ? null : () => _onOptionTap(i),
                              );
                            }),

                            const SizedBox(height: 18),

                            // Explanation
                            if (_revealed) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFFA5D6A7)),
                                ),
                                child: Text(
                                  '💡 ${_current.explanation}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2E7D32),
                                    height: 1.55,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ).animate().fadeIn(duration: 350.ms),

                              const SizedBox(height: 14),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A936F),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    elevation: 4,
                                  ),
                                  onPressed: _onNext,
                                  child: Text(
                                    _currentIndex < _questions.length - 1
                                        ? 'Keyingi savol ➡️'
                                        : '🏁 Yakunlash',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 160.ms, duration: 260.ms),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlay
          if (_showOverlay)
            CelebrationOverlay(
              success: _overlaySuccess,
              message: _overlayMessage,
              subMessage: _overlaySubMessage,
              onDismiss: () => setState(() => _showOverlay = false),
            ),
        ],
      ),
    );
  }

  Color _rewardColor(int reward, int base) {
    final frac = reward / base;
    if (frac >= 0.75) return const Color(0xFFFFB300);
    if (frac >= 0.5)  return const Color(0xFFFF8F00);
    return const Color(0xFFE65100);
  }

  Future<void> _onOptionTap(int index) async {
    if (_revealed) return;
    _timer?.cancel();
    final earnedNow = _currentReward;
    setState(() {
      _selectedIndex = index;
      _revealed = true;
    });

    final correct = index == _current.correctIndex;
    final gs = context.read<GameStateService>();

    if (correct) {
      SoundService().correct();
      _correctCount++;
      _sessionEarned += earnedNow;
      await gs.addMoney(earnedNow);
      await gs.markQuestionAnswered(_current.id);
      setState(() {
        _overlaySuccess = true;
        _overlayMessage = 'To\'g\'ri! 🎉';
        _overlaySubMessage = '+${formatMoney(earnedNow)} qo\'shildi!';
        _showOverlay = true;
      });
    } else {
      SoundService().wrong();
      setState(() {
        _overlaySuccess = false;
        _overlayMessage = 'Noto\'g\'ri 😅';
        _overlaySubMessage = 'Qaytadan urinib ko\'r!';
        _showOverlay = true;
      });
    }
  }

  void _onNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _revealed = false;
        _showOverlay = false;
      });
      _startTimer();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final total = _questions.length;
    final pct = _correctCount / total;
    final String emoji;
    final String title;
    final Color titleColor;

    if (pct >= 0.8) {
      emoji = '🏆';
      title = 'Ajoyib natija!';
      titleColor = const Color(0xFF2E7D32);
    } else if (pct >= 0.5) {
      emoji = '😊';
      title = 'Yaxshi ish!';
      titleColor = const Color(0xFF1565C0);
    } else {
      emoji = '💪';
      title = 'Davom et!';
      titleColor = const Color(0xFFE65100);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ResultDialog(
        emoji: emoji,
        title: title,
        titleColor: titleColor,
        correctCount: _correctCount,
        total: total,
        earned: _sessionEarned,
        onRetry: () {
          Navigator.of(ctx).pop();
          setState(() {
            _currentIndex = 0;
            _selectedIndex = null;
            _revealed = false;
            _correctCount = 0;
            _sessionEarned = 0;
            _showOverlay = false;
          });
          _startTimer();
        },
        onExit: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ── Timer bar ─────────────────────────────────────────────────────────────────

class _TimerBar extends StatelessWidget {
  final int timeLeft;
  final int total;
  final bool revealed;
  final int currentReward;
  final int baseReward;

  const _TimerBar({
    required this.timeLeft,
    required this.total,
    required this.revealed,
    required this.currentReward,
    required this.baseReward,
  });

  @override
  Widget build(BuildContext context) {
    final frac = timeLeft / total;
    final Color barColor;
    if (frac > 0.6)       barColor = const Color(0xFF4CAF50);
    else if (frac > 0.35) barColor = const Color(0xFFFFB300);
    else                   barColor = const Color(0xFFE53935);

    return Row(
      children: [
        Icon(
          Icons.timer_rounded,
          color: revealed ? Colors.white38 : Colors.white,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: revealed ? frac : frac,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: AlwaysStoppedAnimation<Color>(
                revealed ? Colors.white38 : barColor,
              ),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$timeLeft',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: revealed ? Colors.white38 : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Result dialog ─────────────────────────────────────────────────────────────

class _ResultDialog extends StatelessWidget {
  final String emoji;
  final String title;
  final Color titleColor;
  final int correctCount;
  final int total;
  final int earned;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _ResultDialog({
    required this.emoji,
    required this.title,
    required this.titleColor,
    required this.correctCount,
    required this.total,
    required this.earned,
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final pct = correctCount / total;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 68))
                .animate()
                .scale(
                  begin: const Offset(0.2, 0.2),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                  duration: 600.ms,
                ),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: titleColor,
              ),
            ).animate(delay: 150.ms).fadeIn(duration: 280.ms),

            const SizedBox(height: 20),

            _StatRow(
              icon: '✅',
              label: 'To\'g\'ri javoblar',
              value: '$correctCount / $total',
              valueColor: const Color(0xFF2E7D32),
            ).animate(delay: 230.ms).fadeIn().slideX(begin: -0.15),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 12,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(titleColor),
              ),
            ).animate(delay: 280.ms).fadeIn(duration: 380.ms),

            if (earned > 0) ...[
              const SizedBox(height: 10),
              _StatRow(
                icon: '💰',
                label: 'Yutgan pul',
                value: '+${formatMoney(earned)}',
                valueColor: const Color(0xFFFF8F00),
              ).animate(delay: 330.ms).fadeIn().slideX(begin: 0.15),
            ],

            const SizedBox(height: 26),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A936F),
                      side: const BorderSide(color: Color(0xFF1A936F), width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: onRetry,
                    child: const Text(
                      '🔄 Qayta',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A936F),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: onExit,
                    child: const Text(
                      '🏠 Chiqish',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ).animate(delay: 420.ms).fadeIn().slideY(begin: 0.15),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color valueColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
