import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../widgets/animated_button.dart';
import '../widgets/money_display.dart';
import 'lessons_screen.dart';
import 'quiz_groups_screen.dart';
import 'shop_screen.dart';
import 'mini_game_screen.dart';

/// Main entry screen — shows earned money and navigation to all four sections.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E), Color(0xFF1A1A6E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🌟 Iqtisodchi Bolajon',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ).animate()
                              .fadeIn(duration: 450.ms)
                              .slideX(begin: -0.2, end: 0),
                          Text(
                            'Moliyani o\'rgan, kelajakni qur!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate(delay: 180.ms).fadeIn(duration: 380.ms),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showResetDialog(context),
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white54, size: 22),
                      tooltip: 'O\'yinni qayta boshlash',
                    ),
                  ],
                ),
              ),

              // Money display
              Center(
                child: const MoneyDisplay(large: true)
                    .animate(delay: 280.ms)
                    .fadeIn(duration: 450.ms)
                    .scale(
                      begin: const Offset(0.75, 0.75),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                      duration: 650.ms,
                    ),
              ),

              const SizedBox(height: 10),

              // Progress chips
              const _ProgressRow()
                  .animate(delay: 460.ms)
                  .fadeIn(duration: 380.ms),

              const SizedBox(height: 20),

              // ── Nav grid ─────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: size.width > 400 ? 1.1 : 0.98,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      AnimatedButton(
                        label: 'Darslar',
                        emoji: '📚',
                        colors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        onTap: () => _push(context, const LessonsScreen()),
                      ).animate(delay: 580.ms)
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.25, end: 0),

                      AnimatedButton(
                        label: 'Test',
                        emoji: '🧠',
                        colors: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                        onTap: () => _push(context, const QuizGroupsScreen()),
                      ).animate(delay: 660.ms)
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.25, end: 0),

                      AnimatedButton(
                        label: 'Do\'kon',
                        emoji: '🛒',
                        colors: const [Color(0xFFFFC837), Color(0xFFFF8008)],
                        onTap: () => _push(context, const ShopScreen()),
                      ).animate(delay: 740.ms)
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.25, end: 0),

                      AnimatedButton(
                        label: 'O\'yin',
                        emoji: '🎲',
                        colors: const [Color(0xFFDA22FF), Color(0xFF9733EE)],
                        onTap: () => _push(context, const MiniGameScreen()),
                      ).animate(delay: 820.ms)
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.25, end: 0),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  '1–4-sinf o\'quvchilari uchun',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('O\'yinni qayta boshlash',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Barcha progress o\'chib ketadi. Davom etasizmi?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.read<GameStateService>().resetGame();
              Navigator.pop(ctx);
            },
            child: const Text('Ha, boshlash'),
          ),
        ],
      ),
    );
  }
}

// ── Progress chips ─────────────────────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  const _ProgressRow();

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameStateService>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Chip(
          emoji: '📚',
          value: '${gs.completedLessonIds.length}/${gs.lessons.length}',
          label: 'Dars',
        ),
        const SizedBox(width: 10),
        _Chip(
          emoji: '🧠',
          value:
              '${gs.answeredQuestionIds.length}/${gs.questions.length}',
          label: 'Test',
        ),
        const SizedBox(width: 10),
        _Chip(
          emoji: '🛒',
          value: '${gs.purchasedIds.length}',
          label: 'Xarid',
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _Chip({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
