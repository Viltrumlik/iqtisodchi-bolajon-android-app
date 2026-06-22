import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import 'quiz_screen.dart';

/// Shows 3 quiz groups. Tap a group to start solving only its 10 questions.
class QuizGroupsScreen extends StatelessWidget {
  const QuizGroupsScreen({super.key});

  static const _groups = [
    _GroupInfo(
      groupId: 1,
      title: 'Oson',
      subtitle: 'Asosiy tushunchalar',
      emoji: '🌱',
      colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
      description: 'Pul, Tejash, Ehtiyoj, Hohish, Budjet va boshqalar',
    ),
    _GroupInfo(
      groupId: 2,
      title: 'O\'rtacha',
      subtitle: 'Tejamkorlik va savdo',
      emoji: '⚡',
      colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
      description: 'Tejamkorlik, Jamg\'arma, Isrof, Sotuvchi va boshqalar',
    ),
    _GroupInfo(
      groupId: 3,
      title: 'Qiyin',
      subtitle: 'Iqtisod va hayot',
      emoji: '🏆',
      colors: [Color(0xFFE53935), Color(0xFF880E4F)],
      description: 'Iqtisod, Biznes, Mahsulot, Mehnat va boshqalar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameStateService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF1A936F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const CircleBackButton(),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🧠 Test',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Guruhni tanlang',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
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

              // Overall progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: _OverallProgress(
                  answered: gs.answeredQuestionIds.length,
                  total: gs.questions.length,
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 8),

              // Group cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: _groups.length,
                  itemBuilder: (context, i) {
                    final g = _groups[i];
                    final groupQs = gs.questions
                        .where((q) => q.groupId == g.groupId)
                        .toList();
                    final answered = groupQs
                        .where((q) => gs.answeredQuestionIds.contains(q.id))
                        .length;
                    return _GroupCard(
                      info: g,
                      answered: answered,
                      total: groupQs.length,
                      index: i,
                      onTap: () => _openGroup(context, g, gs),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGroup(BuildContext context, _GroupInfo g, GameStateService gs) {
    final groupQs = gs.questions
        .where((q) => q.groupId == g.groupId)
        .toList();

    // Put unanswered first
    final unanswered = groupQs.where((q) => !gs.answeredQuestionIds.contains(q.id)).toList();
    final answered   = groupQs.where((q) =>  gs.answeredQuestionIds.contains(q.id)).toList();
    final ordered = [...unanswered, ...answered];

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, animation, __) => QuizScreen(questions: ordered),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }
}

// ── Overall progress bar ──────────────────────────────────────────────────────

class _OverallProgress extends StatelessWidget {
  final int answered;
  final int total;
  const _OverallProgress({required this.answered, required this.total});

  @override
  Widget build(BuildContext context) {
    final frac = total == 0 ? 0.0 : answered / total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('📊', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Umumiy progress',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('$answered / $total',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: frac,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Group card ────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final _GroupInfo info;
  final int answered;
  final int total;
  final int index;
  final VoidCallback onTap;

  const _GroupCard({
    required this.info,
    required this.answered,
    required this.total,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final frac = total == 0 ? 0.0 : answered / total;
    final done = answered == total && total > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: info.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: info.colors[0].withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Emoji circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(info.emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              info.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            if (done) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('✅ Bajarildi',
                                    style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          info.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Description
              Text(
                info.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.72),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: frac,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$answered / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 120).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

class _GroupInfo {
  final int groupId;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;
  final String description;

  const _GroupInfo({
    required this.groupId,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
    required this.description,
  });
}
