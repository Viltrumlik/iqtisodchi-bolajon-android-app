import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../utils/format.dart';

/// Animated money counter shown in the AppBar and Home screen.
/// Uses AnimatedSwitcher + ValueKey so the scale-pop fires reliably
/// on every change without manual state tracking.
class MoneyDisplay extends StatelessWidget {
  final bool large;
  const MoneyDisplay({super.key, this.large = false});

  @override
  Widget build(BuildContext context) {
    final money = context.watch<GameStateService>().money;
    final fontSize = large ? 30.0 : 17.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 22, vertical: 11)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween<double>(begin: 1.18, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        ),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey(money),
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // The balance grows as the child plays, so the amount scales down
        // rather than overflowing the pill.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💰', style: TextStyle(fontSize: fontSize * 0.85)),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatMoney(money),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.deepOrange, blurRadius: 4)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
