import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/lesson_plans_data.dart';
import '../services/game_state_service.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import 'lesson_plans_screen.dart';

/// "Darslar" — pick a grade, then a lesson plan (dars ishlanmasi) inside it.
class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  static const _grades = {
    1: _GradeStyle('🍎', [Color(0xFFFF8A65), Color(0xFFD84315)], 'Birinchi qadamlar'),
    2: _GradeStyle('🚀', [Color(0xFF29B6F6), Color(0xFF0277BD)], 'Kashfiyot davri'),
    3: _GradeStyle('🌟', [Color(0xFFAB47BC), Color(0xFF6A1B9A)], 'Mustaqil fikr'),
    4: _GradeStyle('🏆', [Color(0xFF26A69A), Color(0xFF00695C)], 'Katta maqsadlar'),
  };

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameStateService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const CircleBackButton(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📚 Darslar',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Sinfingizni tanlang',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
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
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                    itemCount: kGrades.length,
                    itemBuilder: (context, i) {
                      final grade = kGrades[i];
                      final style = _grades[grade]!;
                      final plans = gs.plansForGrade(grade);
                      final read = plans
                          .where((p) => gs.readPlanIds.contains(p.id))
                          .length;
                      return _GradeCard(
                        grade: grade,
                        style: style,
                        total: plans.length,
                        read: read,
                        index: i,
                        onTap: plans.isEmpty
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LessonPlansScreen(grade: grade),
                                  ),
                                ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small translucent pill used on the grade cards.
class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _GradeStyle {
  final String emoji;
  final List<Color> colors;
  final String tagline;
  const _GradeStyle(this.emoji, this.colors, this.tagline);
}

class _GradeCard extends StatelessWidget {
  final int grade;
  final _GradeStyle style;
  final int total;
  final int read;
  final int index;
  final VoidCallback? onTap;

  const _GradeCard({
    required this.grade,
    required this.style,
    required this.total,
    required this.read,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = total > 0 && read == total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: style.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: style.colors.last.withValues(alpha: 0.32),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(style.emoji,
                      style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$grade-sinf',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        style.tagline,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 9),
                      // Wrap, not Row: both chips together are wider than a
                      // 360 dp phone once the progress chip appears.
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Chip(text: '📄 $total ta dars ishlanma'),
                          if (read > 0)
                            _Chip(
                              text: done
                                  ? '✅ Tugallandi'
                                  : '👀 $read/$total',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white70, size: 28),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (90 * index).ms).fadeIn(duration: 340.ms).slideY(
          begin: 0.18,
          end: 0,
          curve: Curves.easeOut,
        );
  }
}
