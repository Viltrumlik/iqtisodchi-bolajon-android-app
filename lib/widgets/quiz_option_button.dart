import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum OptionState { idle, correct, wrong }

/// Single answer-option button for the quiz screen.
/// Entrance: staggered fadeIn + slideX.
/// On correct: elastic scale-up. On wrong: shake.
class QuizOptionButton extends StatelessWidget {
  final String text;
  final OptionState state;
  final VoidCallback? onTap;
  final int index;

  const QuizOptionButton({
    super.key,
    required this.text,
    required this.state,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final IconData? trailingIcon;

    switch (state) {
      case OptionState.correct:
        bgColor = const Color(0xFF43A047);
        borderColor = const Color(0xFF2E7D32);
        textColor = Colors.white;
        trailingIcon = Icons.check_circle_rounded;
      case OptionState.wrong:
        bgColor = const Color(0xFFE53935);
        borderColor = const Color(0xFFC62828);
        textColor = Colors.white;
        trailingIcon = Icons.cancel_rounded;
      case OptionState.idle:
        bgColor = Colors.white;
        borderColor = const Color(0xFFE0E0E0);
        textColor = const Color(0xFF333333);
        trailingIcon = null;
    }

    final button = GestureDetector(
      onTap: state == OptionState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Option letter badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: state == OptionState.idle
                    ? const Color(0xFFF0F0F0)
                    : Colors.white.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: state == OptionState.idle
                        ? const Color(0xFF555555)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.35,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, color: Colors.white, size: 22),
            ],
          ],
        ),
      ),
    );

    // State-change animations
    if (state == OptionState.correct) {
      return button
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
            duration: 300.ms,
            curve: Curves.elasticOut,
          )
          .fadeIn(duration: 200.ms);
    }
    if (state == OptionState.wrong) {
      return button.animate().shake(hz: 4, duration: 400.ms);
    }

    // Idle: staggered entrance
    return button
        .animate(delay: (index * 55).ms)
        .fadeIn(duration: 280.ms)
        .slideX(begin: -0.15, end: 0, curve: Curves.easeOut);
  }
}
