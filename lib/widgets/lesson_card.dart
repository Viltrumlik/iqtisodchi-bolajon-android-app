import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/lesson.dart';
import 'lesson_illustration.dart';

/// Card shown in the lessons list for each financial topic.
class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = lesson.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lesson.color, lesson.color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: lesson.color.withValues(alpha: completed ? 0.25 : 0.4),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              // Lesson illustration
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: LessonIllustration(lessonId: lesson.id, size: 50),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      lesson.explanation.length > 65
                          ? '${lesson.explanation.substring(0, 65)}…'
                          : lesson.explanation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Status badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: completed
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: completed
                      ? Icon(Icons.check_rounded,
                          color: lesson.color, size: 22)
                      : const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
      )
          .animate(delay: (index * 70).ms)
          .fadeIn(duration: 380.ms)
          .slideX(
            begin: 0.25,
            end: 0,
            duration: 380.ms,
            curve: Curves.easeOut,
          ),
    );
  }
}
