import 'package:flutter/material.dart';

/// Large, bouncy, child-friendly button with gradient background.
/// Uses two independent AnimationControllers so the idle float survives
/// press-rebuild cycles without resetting.
class AnimatedButton extends StatefulWidget {
  final String label;
  final String emoji;
  final List<Color> colors;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final double fontSize;

  const AnimatedButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.colors,
    required this.onTap,
    this.width,
    this.height = 90,
    this.fontSize = 20,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  // Press-down scale
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  // Idle float
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pressScale, _floatY]),
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatY.value),
        child: Transform.scale(scale: _pressScale.value, child: child),
      ),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.colors.last.withValues(alpha: 0.55),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.emoji,
                style: TextStyle(fontSize: widget.fontSize * 1.7),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
