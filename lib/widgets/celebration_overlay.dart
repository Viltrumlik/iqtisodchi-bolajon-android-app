import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/sound_service.dart';

/// Full-screen overlay with money rain (success) or failure card.
class CelebrationOverlay extends StatefulWidget {
  final bool success;
  final String message;
  final String? subMessage;
  final VoidCallback onDismiss;

  const CelebrationOverlay({
    super.key,
    required this.success,
    required this.message,
    this.subMessage,
    required this.onDismiss,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  final Random _rng = Random();
  late final List<_MoneyBill> _bills;
  late final AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _bills = widget.success
        ? List.generate(40, (_) => _MoneyBill(_rng))
        : [];

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();

    if (widget.success) {
      SoundService().celebrate();
    } else {
      SoundService().wrong();
    }

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bg = widget.success
        ? Colors.black.withValues(alpha: 0.52)
        : Colors.black.withValues(alpha: 0.72);

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: bg,
        child: Stack(
          children: [
            // Money rain (success only)
            if (widget.success)
              ..._bills.map((b) => _MoneyBillWidget(bill: b, size: size)),

            // Center card
            Center(
              child: _ResultCard(
                success: widget.success,
                message: widget.message,
                subMessage: widget.subMessage,
                progressCtrl: _progressCtrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Money bill model ──────────────────────────────────────────────────────────

class _MoneyBill {
  final double x;      // 0..1 horizontal start position
  final double speed;  // fall speed multiplier
  final double size;   // font size
  final double rotation; // start rotation
  final String symbol;
  final double delay;  // start delay fraction

  _MoneyBill(Random rng)
      : x = rng.nextDouble(),
        speed = 0.4 + rng.nextDouble() * 0.6,
        size = 20 + rng.nextDouble() * 24,
        rotation = (rng.nextDouble() - 0.5) * 0.8,
        symbol = _kSymbols[rng.nextInt(_kSymbols.length)],
        delay = rng.nextDouble() * 0.5;

  static const _kSymbols = ['💵', '💴', '💶', '💰', '🪙', '⭐', '💸', '🤑'];
}

// ── Money bill widget ─────────────────────────────────────────────────────────

class _MoneyBillWidget extends StatelessWidget {
  final _MoneyBill bill;
  final Size size;

  const _MoneyBillWidget({required this.bill, required this.size});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(
      milliseconds: (2000 / bill.speed).round(),
    );
    return Positioned(
      left: bill.x * size.width,
      top: -60,
      child: Transform.rotate(
        angle: bill.rotation,
        child: Text(bill.symbol, style: TextStyle(fontSize: bill.size)),
      ),
    )
        .animate(delay: Duration(milliseconds: (bill.delay * 800).round()))
        .animate(onPlay: (c) => c.repeat())
        .moveY(
          begin: 0,
          end: size.height + 80,
          duration: duration,
          curve: Curves.linear,
        )
        .rotate(begin: 0, end: bill.rotation > 0 ? 0.5 : -0.5, duration: duration);
  }
}

// ── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final bool success;
  final String message;
  final String? subMessage;
  final AnimationController progressCtrl;

  const _ResultCard({
    required this.success,
    required this.message,
    this.subMessage,
    required this.progressCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = success ? Colors.green : Colors.red;
    final accentColor =
        success ? const Color(0xFF1B5E20) : const Color(0xFFC62828);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36),
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.55),
            blurRadius: 44,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Big emoji with bounce + float loop
          Text(
            success ? '🤑' : '😅',
            style: const TextStyle(fontSize: 80),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                curve: Curves.elasticOut,
                duration: 700.ms,
              )
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -10, duration: 850.ms, curve: Curves.easeInOut),

          const SizedBox(height: 10),

          // Money stack animation (success only)
          if (success)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    _kMoneyEmojis[i % _kMoneyEmojis.length],
                    style: const TextStyle(fontSize: 22),
                  )
                      .animate(delay: (150 + i * 90).ms)
                      .fadeIn(duration: 220.ms)
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: 380.ms,
                      )
                      .moveY(begin: -20, end: 0, duration: 380.ms),
                ),
              ),
            ),

          if (success) const SizedBox(height: 10),

          // Main message
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: accentColor,
              height: 1.2,
            ),
          ).animate(delay: 180.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),

          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF555555),
                height: 1.45,
              ),
            ).animate(delay: 280.ms).fadeIn(duration: 300.ms),
          ],

          const SizedBox(height: 18),

          // Countdown progress bar
          AnimatedBuilder(
            animation: progressCtrl,
            builder: (_, __) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 1.0 - progressCtrl.value,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      success ? const Color(0xFF43A047) : const Color(0xFFE53935),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Davom etish uchun bosing',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms)
        .scale(
          begin: const Offset(0.55, 0.55),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 600.ms,
        );
  }

  static const _kMoneyEmojis = ['💵', '🪙', '💰', '💶', '⭐'];
}
