import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../services/game_state_service.dart';
import '../widgets/lesson_illustration.dart';

/// Full-screen card for reading a single lesson and marking it complete.
class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final int lessonIndex;
  final int totalLessons;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.lessonIndex,
    required this.totalLessons,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool _showCompletion = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lesson.color, lesson.color.withValues(alpha: 0.55)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top nav ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      _CircleBtn(
                        onTap: () => Navigator.pop(context),
                        icon: Icons.arrow_back_ios_rounded,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.lessonIndex + 1} / ${widget.totalLessons}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (lesson.isCompleted)
                        _CircleBtn(
                          icon: Icons.check_rounded,
                          tint: Colors.green,
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),

                const Spacer(),

                // Big lesson illustration
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: LessonIllustration(lessonId: lesson.id, size: 108),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                      duration: 650.ms,
                    ),

                const SizedBox(height: 16),

                // Title
                Text(
                  lesson.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                  ),
                )
                    .animate(delay: 180.ms)
                    .fadeIn(duration: 380.ms)
                    .slideY(begin: 0.2, end: 0),

                const Spacer(),

                // Explanation card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.13),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    lesson.explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.65,
                      color: Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                    .animate(delay: 350.ms)
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 28),

                // Complete button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: lesson.color,
                        elevation: 6,
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _onComplete,
                      child: Text(
                        lesson.isCompleted ? '✅ Bajarilgan' : '✅ Tugatdim!',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(delay: 550.ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.25, end: 0),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Completion flash
          if (_showCompletion)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.white.withValues(alpha: 0.55))
                    .animate()
                    .fadeIn(duration: 120.ms)
                    .then()
                    .fadeOut(duration: 380.ms),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onComplete() async {
    if (!widget.lesson.isCompleted) {
      await context.read<GameStateService>().completeLesson(widget.lesson.id);
      setState(() => _showCompletion = true);
      await Future.delayed(const Duration(milliseconds: 550));
      if (mounted) Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }
}

class _CircleBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color? tint;

  const _CircleBtn({this.onTap, required this.icon, this.tint});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tint != null
              ? tint!.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: tint ?? Colors.white, size: 18),
      ),
    );
  }
}
