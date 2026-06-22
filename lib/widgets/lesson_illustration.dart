import 'dart:math';
import 'package:flutter/material.dart';

/// Returns a rich illustrated widget for each lesson ID.
/// Used in lesson cards and the detail screen instead of a plain emoji.
class LessonIllustration extends StatelessWidget {
  final String lessonId;
  final double size;

  const LessonIllustration({
    super.key,
    required this.lessonId,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _painterFor(lessonId),
      ),
    );
  }

  CustomPainter _painterFor(String id) {
    switch (id) {
      case 'lesson_tejash':       return const _PiggyBankPainter();
      case 'lesson_ehtiyoj':      return const _NeedsPainter();
      case 'lesson_hohish':       return const _WantsPainter();
      case 'lesson_budjet':       return const _BudgetPainter();
      case 'lesson_daromad':      return const _IncomePainter();
      case 'lesson_xarajat':      return const _ExpensePainter();
      case 'lesson_investitsiya': return const _InvestPainter();
      case 'lesson_qarz':         return const _DebtPainter();
      // New lessons
      case 'lesson_pul':          return const _MoneyPainter();
      case 'lesson_narx':         return const _PriceTagPainter();
      case 'lesson_bozor':        return const _MarketPainter();
      case 'lesson_mahsulot':     return const _ProductBoxPainter();
      case 'lesson_savdo':        return const _TradePainter();
      case 'lesson_xarid':        return const _ShoppingCartPainter();
      case 'lesson_sotish':       return const _SellingPainter();
      case 'lesson_foyda':        return const _ProfitPainter();
      case 'lesson_jamgarma':     return const _SavingsPotPainter();
      case 'lesson_tadbirkor':    return const _EntrepreneurPainter();
      case 'lesson_tejamkorlik':        return const _FrugalPainter();
      case 'lesson_isrof':             return const _WastePainter();
      // Batch-2 new lessons
      case 'lesson_iqtisod':           return const _BudgetPainter();
      case 'lesson_iqtisodiyot':       return const _MarketPainter();
      case 'lesson_iqtisodiy_tarbiya': return const _InvestPainter();
      case 'lesson_vaqt':              return const _CoinPainter();
      case 'lesson_ayirboshlash':      return const _TradePainter();
      case 'lesson_haridor':           return const _ShoppingCartPainter();
      case 'lesson_sotuvchi':          return const _SellingPainter();
      case 'lesson_tarbiya':           return const _NeedsPainter();
      case 'lesson_sarf':              return const _ExpensePainter();
      case 'lesson_oila_budjeti':      return const _BudgetPainter();
      case 'lesson_mehnatsevarlik':    return const _EntrepreneurPainter();
      case 'lesson_halollik':          return const _TradePainter();
      case 'lesson_biznes':            return const _ProfitPainter();
      case 'lesson_ishbilarmonlik':    return const _InvestPainter();
      case 'lesson_almashish':         return const _TradePainter();
      default:                         return const _CoinPainter();
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Paint _fill(Color c) => Paint()..color = c;
Paint _stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _drawCoin(Canvas c, Offset center, double r, Color body, Color rim) {
  c.drawCircle(center, r, _fill(body));
  c.drawCircle(center, r, _stroke(rim, r * 0.14));
}

void _drawStar(Canvas c, Offset center, double r, Color color) {
  final path = Path();
  for (int i = 0; i < 5; i++) {
    final a = -pi / 2 + 2 * pi * i / 5;
    final b = a + pi / 5;
    final p = Offset(center.dx + r * cos(a), center.dy + r * sin(a));
    final q = Offset(center.dx + r * 0.4 * cos(b), center.dy + r * 0.4 * sin(b));
    if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
    path.lineTo(q.dx, q.dy);
  }
  path.close();
  c.drawPath(path, _fill(color));
}

// ── Piggy Bank (Tejash - Saving) ──────────────────────────────────────────────

class _PiggyBankPainter extends CustomPainter {
  const _PiggyBankPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.48, h * 0.58), width: w * 0.72, height: h * 0.52),
      _fill(const Color(0xFFFFB6C1)),
    );
    // Head
    canvas.drawCircle(Offset(w * 0.76, h * 0.44), w * 0.2, _fill(const Color(0xFFFFB6C1)));
    // Snout
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.88, h * 0.5), width: w * 0.16, height: h * 0.11),
      _fill(const Color(0xFFF48FB1)),
    );
    // Nostril dots
    canvas.drawCircle(Offset(w * 0.845, h * 0.49), w * 0.018, _fill(const Color(0xFFE91E63)));
    canvas.drawCircle(Offset(w * 0.915, h * 0.49), w * 0.018, _fill(const Color(0xFFE91E63)));
    // Eye
    canvas.drawCircle(Offset(w * 0.78, h * 0.37), w * 0.03, _fill(const Color(0xFF333333)));
    canvas.drawCircle(Offset(w * 0.785, h * 0.365), w * 0.01, _fill(Colors.white));
    // Ear
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.68, h * 0.28), width: w * 0.11, height: h * 0.1),
      _fill(const Color(0xFFF48FB1)),
    );
    // Coin slot on back
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.38, h * 0.35), width: w * 0.16, height: h * 0.035),
        const Radius.circular(3),
      ),
      _fill(const Color(0xFF8D6E63)),
    );
    // Gold coin above slot
    _drawCoin(canvas, Offset(w * 0.38, h * 0.22), w * 0.09, const Color(0xFFFFD700), const Color(0xFFDAA520));
    // Dollar sign on coin
    final tp = TextPainter(
      text: const TextSpan(text: '\$', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF7B5800))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.355, h * 0.185));
    // Legs (4)
    final legPaint = _fill(const Color(0xFFF06292));
    for (int i = 0; i < 4; i++) {
      final lx = w * (0.22 + i * 0.14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lx - w * 0.05, h * 0.76, w * 0.09, h * 0.2),
          const Radius.circular(5),
        ),
        legPaint,
      );
    }
    // Tail
    final tail = Path()
      ..moveTo(w * 0.12, h * 0.6)
      ..cubicTo(w * 0.0, h * 0.53, w * -0.02, h * 0.67, w * 0.08, h * 0.72);
    canvas.drawPath(tail, _stroke(const Color(0xFFF48FB1), w * 0.04));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Basic Needs (Ehtiyoj) ─────────────────────────────────────────────────────

class _NeedsPainter extends CustomPainter {
  const _NeedsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // House body
    canvas.drawRect(
      Rect.fromLTWH(w * 0.18, h * 0.44, w * 0.64, h * 0.5),
      _fill(const Color(0xFFFF8A65)),
    );
    // Roof
    final roof = Path()
      ..moveTo(w * 0.1, h * 0.46)
      ..lineTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.9, h * 0.46)
      ..close();
    canvas.drawPath(roof, _fill(const Color(0xFFE53935)));
    // Door
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.68, w * 0.24, h * 0.26),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFF5D4037)),
    );
    // Window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.52, w * 0.18, h * 0.15),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFF81D4FA)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.52, w * 0.18, h * 0.15),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFF81D4FA)),
    );
    // Sun
    canvas.drawCircle(Offset(w * 0.82, h * 0.14), w * 0.1, _fill(const Color(0xFFFFEB3B)));
    for (int i = 0; i < 8; i++) {
      final a = pi * 2 * i / 8;
      final p1 = Offset(w * 0.82 + cos(a) * w * 0.13, h * 0.14 + sin(a) * w * 0.13);
      final p2 = Offset(w * 0.82 + cos(a) * w * 0.19, h * 0.14 + sin(a) * w * 0.19);
      canvas.drawLine(p1, p2, _stroke(const Color(0xFFFFEB3B), w * 0.025));
    }
    // Bread loaf (bottom left)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.02, h * 0.68, w * 0.14, h * 0.22),
        const Radius.circular(6),
      ),
      _fill(const Color(0xFFD7A05A)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.02, h * 0.63, w * 0.14, h * 0.1),
      _fill(const Color(0xFFBC8A3E)),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Wants / Game Controller (Hohish) ─────────────────────────────────────────

class _WantsPainter extends CustomPainter {
  const _WantsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Controller body
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.3, w * 0.84, h * 0.45),
        Radius.circular(w * 0.18),
      ));
    canvas.drawPath(body, _fill(const Color(0xFF455A64)));
    canvas.drawPath(body, _stroke(const Color(0xFF263238), w * 0.025));

    // Grips (left and right rounded extensions)
    canvas.drawOval(
      Rect.fromLTWH(w * 0.04, h * 0.52, w * 0.28, h * 0.35),
      _fill(const Color(0xFF455A64)),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.68, h * 0.52, w * 0.28, h * 0.35),
      _fill(const Color(0xFF455A64)),
    );

    // D-pad (left)
    final dpad = _fill(const Color(0xFF37474F));
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.3, h * 0.53), width: w * 0.18, height: w * 0.07), dpad);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.3, h * 0.53), width: w * 0.07, height: w * 0.18), dpad);

    // Face buttons (right) - ABXY style
    final btnColors = [const Color(0xFFE53935), const Color(0xFF1E88E5), const Color(0xFFFFB300), const Color(0xFF43A047)];
    final btnOffsets = [
      Offset(w * 0.72, h * 0.44), Offset(w * 0.81, h * 0.53),
      Offset(w * 0.72, h * 0.62), Offset(w * 0.63, h * 0.53),
    ];
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(btnOffsets[i], w * 0.066, _fill(btnColors[i]));
      canvas.drawCircle(btnOffsets[i], w * 0.066, _stroke(Colors.black26, w * 0.015));
    }

    // Center button
    canvas.drawCircle(Offset(w * 0.5, h * 0.53), w * 0.05, _fill(const Color(0xFF78909C)));

    // Left joystick circle
    canvas.drawCircle(Offset(w * 0.3, h * 0.68), w * 0.07, _fill(const Color(0xFF37474F)));
    canvas.drawCircle(Offset(w * 0.3, h * 0.68), w * 0.07, _stroke(const Color(0xFF78909C), w * 0.02));

    // Right joystick circle
    canvas.drawCircle(Offset(w * 0.6, h * 0.68), w * 0.07, _fill(const Color(0xFF37474F)));
    canvas.drawCircle(Offset(w * 0.6, h * 0.68), w * 0.07, _stroke(const Color(0xFF78909C), w * 0.02));

    // Small stars above controller
    _drawStar(canvas, Offset(w * 0.15, h * 0.15), w * 0.07, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.85, h * 0.18), w * 0.05, const Color(0xFFFF80AB));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Budget / Planner (Budjet) ─────────────────────────────────────────────────

class _BudgetPainter extends CustomPainter {
  const _BudgetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Notebook background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.08, w * 0.8, h * 0.86),
        Radius.circular(w * 0.07),
      ),
      _fill(Colors.white),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.08, w * 0.8, h * 0.86),
        Radius.circular(w * 0.07),
      ),
      _stroke(const Color(0xFFE0E0E0), w * 0.025),
    );

    // Header bar
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.1, h * 0.08, w * 0.8, h * 0.18),
        topLeft: Radius.circular(w * 0.07),
        topRight: Radius.circular(w * 0.07),
      ),
      _fill(const Color(0xFF7E57C2)),
    );

    // Title dots on header
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(w * (0.28 + i * 0.18), h * 0.17), w * 0.03, _fill(Colors.white70));
    }

    // Horizontal lines
    for (int i = 0; i < 4; i++) {
      final y = h * (0.34 + i * 0.13);
      canvas.drawLine(Offset(w * 0.2, y), Offset(w * 0.8, y), _stroke(const Color(0xFFEEEEEE), w * 0.02));
    }

    // Income bar (green)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.45, w * 0.25, h * 0.3),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFF66BB6A)),
    );
    // Expense bar (red, shorter)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.55, h * 0.55, w * 0.25, h * 0.2),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFFEF5350)),
    );

    // Coin icon bottom right
    _drawCoin(canvas, Offset(w * 0.8, h * 0.88), w * 0.06, const Color(0xFFFFD700), const Color(0xFFDAA520));

    // Pencil top right
    final pencilBody = Path()
      ..moveTo(w * 0.82, h * 0.1)
      ..lineTo(w * 0.88, h * 0.1)
      ..lineTo(w * 0.88, h * 0.22)
      ..lineTo(w * 0.82, h * 0.22)
      ..close();
    canvas.drawPath(pencilBody, _fill(const Color(0xFFFFCA28)));
    canvas.drawPath(
      Path()..moveTo(w * 0.82, h * 0.22)..lineTo(w * 0.85, h * 0.27)..lineTo(w * 0.88, h * 0.22)..close(),
      _fill(const Color(0xFFFF8F00)),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Income / Wallet (Daromad) ─────────────────────────────────────────────────

class _IncomePainter extends CustomPainter {
  const _IncomePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Wallet body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.72, h * 0.54),
        Radius.circular(w * 0.1),
      ),
      _fill(const Color(0xFF6D4C41)),
    );
    // Wallet flap (lighter)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.72, h * 0.22),
        Radius.circular(w * 0.1),
      ),
      _fill(const Color(0xFF8D6E63)),
    );

    // Card slot inside
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.58, w * 0.4, h * 0.16),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFF4E342E)),
    );

    // Bills sticking out from top
    final billColors = [const Color(0xFF43A047), const Color(0xFF1B5E20), const Color(0xFF2E7D32)];
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.3 + i * 0.08), h * 0.1, w * 0.18, h * 0.26),
          const Radius.circular(4),
        ),
        _fill(billColors[i]),
      );
    }

    // Coin pocket (right side)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.7, h * 0.36, w * 0.2, h * 0.4),
        Radius.circular(w * 0.1),
      ),
      _fill(const Color(0xFF795548)),
    );
    _drawCoin(canvas, Offset(w * 0.8, h * 0.56), w * 0.07, const Color(0xFFFFD700), const Color(0xFFDAA520));

    // Up arrow (income symbol)
    final arrow = Path()
      ..moveTo(w * 0.18, h * 0.58)
      ..lineTo(w * 0.1, h * 0.7)
      ..lineTo(w * 0.14, h * 0.7)
      ..lineTo(w * 0.14, h * 0.82)
      ..lineTo(w * 0.22, h * 0.82)
      ..lineTo(w * 0.22, h * 0.7)
      ..lineTo(w * 0.26, h * 0.7)
      ..close();
    canvas.drawPath(arrow, _fill(const Color(0xFF66BB6A)));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Expense / Shopping Bag (Xarajat) ─────────────────────────────────────────

class _ExpensePainter extends CustomPainter {
  const _ExpensePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Bag body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.3, w * 0.76, h * 0.64),
        Radius.circular(w * 0.1),
      ),
      _fill(const Color(0xFFEF5350)),
    );

    // Bag top rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.3, w * 0.76, h * 0.1),
        Radius.circular(w * 0.05),
      ),
      _fill(const Color(0xFFB71C1C)),
    );

    // Handles (two arcs)
    for (final cx in [w * 0.33, w * 0.67]) {
      final rect = Rect.fromCenter(center: Offset(cx, h * 0.26), width: w * 0.22, height: h * 0.28);
      canvas.drawArc(rect, pi, pi, false, _stroke(const Color(0xFFB71C1C), w * 0.055));
    }

    // Items inside bag
    final itemColors = [const Color(0xFFFFEB3B), const Color(0xFF4CAF50), const Color(0xFF2196F3)];
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.22 + i * 0.22), h * 0.5, w * 0.18, h * 0.18),
          const Radius.circular(5),
        ),
        _fill(itemColors[i]),
      );
    }

    // Price tag
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.76, h * 0.72), width: w * 0.2, height: h * 0.14),
      _fill(Colors.white),
    );
    canvas.drawLine(Offset(w * 0.76, h * 0.66), Offset(w * 0.76, h * 0.63), _stroke(const Color(0xFFB71C1C), w * 0.025));

    // Stars decoration
    _drawStar(canvas, Offset(w * 0.15, h * 0.72), w * 0.06, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.88, h * 0.42), w * 0.05, const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Investment / Growing Chart (Investitsiya) ─────────────────────────────────

class _InvestPainter extends CustomPainter {
  const _InvestPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Chart axes
    canvas.drawLine(Offset(w * 0.15, h * 0.8), Offset(w * 0.15, h * 0.15), _stroke(const Color(0xFF37474F), w * 0.03));
    canvas.drawLine(Offset(w * 0.15, h * 0.8), Offset(w * 0.9, h * 0.8), _stroke(const Color(0xFF37474F), w * 0.03));

    // Growing bars
    final barData = [0.2, 0.38, 0.55, 0.75];
    final barColors = [
      const Color(0xFF81C784),
      const Color(0xFF4CAF50),
      const Color(0xFF388E3C),
      const Color(0xFF1B5E20),
    ];
    for (int i = 0; i < barData.length; i++) {
      final bh = barData[i] * h * 0.6;
      final bx = w * (0.22 + i * 0.17);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, h * 0.8 - bh, w * 0.13, bh),
          const Radius.circular(5),
        ),
        _fill(barColors[i]),
      );
    }

    // Trend line
    final line = Path()
      ..moveTo(w * 0.235, h * 0.68)
      ..lineTo(w * 0.405, h * 0.5)
      ..lineTo(w * 0.575, h * 0.32)
      ..lineTo(w * 0.745, h * 0.14);
    canvas.drawPath(line, _stroke(const Color(0xFFFFB300), w * 0.03));

    // Arrow at top of trend
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.745, h * 0.14)
        ..lineTo(w * 0.72, h * 0.2)
        ..moveTo(w * 0.745, h * 0.14)
        ..lineTo(w * 0.79, h * 0.18),
      _stroke(const Color(0xFFFFB300), w * 0.03),
    );

    // Star at top
    _drawStar(canvas, Offset(w * 0.82, h * 0.1), w * 0.08, const Color(0xFFFFEB3B));

    // Coin pile at bottom
    _drawCoin(canvas, Offset(w * 0.12, h * 0.88), w * 0.06, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.08, h * 0.82), w * 0.05, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.17, h * 0.82), w * 0.05, const Color(0xFFFFD700), const Color(0xFFDAA520));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Debt / Handshake (Qarz) ───────────────────────────────────────────────────

class _DebtPainter extends CustomPainter {
  const _DebtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.45, w * 0.35, h * 0.18),
        const Radius.circular(10),
      ),
      _fill(const Color(0xFFFFCCBC)),
    );
    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.61, h * 0.45, w * 0.35, h * 0.18),
        const Radius.circular(10),
      ),
      _fill(const Color(0xFFFFCCBC)),
    );

    // Left hand fist
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.31, h * 0.38, w * 0.18, h * 0.22),
        const Radius.circular(8),
      ),
      _fill(const Color(0xFFFFB89A)),
    );
    // Fingers left
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.32 + i * 0.038), h * 0.33, w * 0.03, h * 0.09),
          const Radius.circular(5),
        ),
        _fill(const Color(0xFFFFB89A)),
      );
    }

    // Right hand fist
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.51, h * 0.38, w * 0.18, h * 0.22),
        const Radius.circular(8),
      ),
      _fill(const Color(0xFFFFB89A)),
    );
    // Fingers right
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.52 + i * 0.038), h * 0.33, w * 0.03, h * 0.09),
          const Radius.circular(5),
        ),
        _fill(const Color(0xFFFFB89A)),
      );
    }

    // Hands overlapping (shake area)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.42, w * 0.24, h * 0.14),
        const Radius.circular(6),
      ),
      _fill(const Color(0xFFFFAB91)),
    );

    // Coin between hands (above)
    _drawCoin(canvas, Offset(w * 0.5, h * 0.28), w * 0.1, const Color(0xFFFFD700), const Color(0xFFDAA520));
    // Question mark on coin
    final tp = TextPainter(
      text: const TextSpan(text: '?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF7B5800))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.465, h * 0.24));

    // Small heart above
    canvas.drawCircle(Offset(w * 0.5, h * 0.12), w * 0.05, _fill(const Color(0xFFEF5350)));

    // Down arrow (debt going down/returning)
    canvas.drawLine(Offset(w * 0.5, h * 0.7), Offset(w * 0.5, h * 0.85), _stroke(const Color(0xFF37474F), w * 0.025));
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.43, h * 0.79)
        ..lineTo(w * 0.5, h * 0.87)
        ..lineTo(w * 0.57, h * 0.79),
      _stroke(const Color(0xFF37474F), w * 0.025),
    );

    // Stars
    _drawStar(canvas, Offset(w * 0.12, h * 0.22), w * 0.06, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.88, h * 0.22), w * 0.06, const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Fallback Coin (default) ───────────────────────────────────────────────────

class _CoinPainter extends CustomPainter {
  const _CoinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    _drawCoin(canvas, Offset(w / 2, h / 2), w * 0.4, const Color(0xFFFFD700), const Color(0xFFDAA520));
    final tp = TextPainter(
      text: const TextSpan(text: '\$', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF7B5800))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h / 2 - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Money Bills (Pul) ─────────────────────────────────────────────────────────

class _MoneyPainter extends CustomPainter {
  const _MoneyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Three stacked bills
    final billColors = [const Color(0xFF388E3C), const Color(0xFF43A047), const Color(0xFF66BB6A)];
    final offsets = [0.08, 0.04, 0.0];
    for (int i = 0; i < 3; i++) {
      final dx = offsets[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.08 + dx), h * (0.22 + i * 0.06), w * 0.76, h * 0.38),
          const Radius.circular(6),
        ),
        _fill(billColors[i]),
      );
      // Bill border
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.08 + dx), h * (0.22 + i * 0.06), w * 0.76, h * 0.38),
          const Radius.circular(6),
        ),
        _stroke(Colors.white24, w * 0.015),
      );
    }
    // Coin on top bill
    _drawCoin(canvas, Offset(w * 0.5, h * 0.35), w * 0.13, const Color(0xFFFFD700), const Color(0xFFDAA520));
    // $ sign
    final tp = TextPainter(
      text: const TextSpan(text: '\$', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF7B5800))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.5 - tp.width / 2, h * 0.315));

    // Scattered coins
    _drawCoin(canvas, Offset(w * 0.18, h * 0.76), w * 0.09, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.5, h * 0.82), w * 0.08, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.8, h * 0.76), w * 0.09, const Color(0xFFFFD700), const Color(0xFFDAA520));

    // Stars
    _drawStar(canvas, Offset(w * 0.12, h * 0.12), w * 0.06, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.88, h * 0.15), w * 0.05, const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Price Tag (Narx) ──────────────────────────────────────────────────────────

class _PriceTagPainter extends CustomPainter {
  const _PriceTagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Tag body (rounded rectangle)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.18, w * 0.72, h * 0.6),
        const Radius.circular(10),
      ),
      _fill(const Color(0xFFFFCC02)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.18, w * 0.72, h * 0.6),
        const Radius.circular(10),
      ),
      _stroke(const Color(0xFFFF8F00), w * 0.025),
    );
    // Tag triangle (right side)
    final tri = Path()
      ..moveTo(w * 0.82, h * 0.38)
      ..lineTo(w * 0.95, h * 0.48)
      ..lineTo(w * 0.82, h * 0.58)
      ..close();
    canvas.drawPath(tri, _fill(const Color(0xFFFFCC02)));
    canvas.drawPath(tri, _stroke(const Color(0xFFFF8F00), w * 0.025));

    // Hole on left
    canvas.drawCircle(Offset(w * 0.18, h * 0.48), w * 0.05, _fill(Colors.white));
    canvas.drawCircle(Offset(w * 0.18, h * 0.48), w * 0.05, _stroke(const Color(0xFFFF8F00), w * 0.02));

    // Price text lines
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.3, w * 0.44, h * 0.1),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFFFF8F00)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.46, w * 0.34, h * 0.08),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFFFF8F00).withAlpha(150)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.59, w * 0.24, h * 0.08),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFFFF8F00).withAlpha(100)),
    );

    // Coin bottom-right
    _drawCoin(canvas, Offset(w * 0.8, h * 0.84), w * 0.08, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawStar(canvas, Offset(w * 0.88, h * 0.12), w * 0.06, const Color(0xFFFF5722));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Market Stall (Bozor) ──────────────────────────────────────────────────────

class _MarketPainter extends CustomPainter {
  const _MarketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Awning
    final awning = Path()
      ..moveTo(w * 0.06, h * 0.3)
      ..lineTo(w * 0.94, h * 0.3)
      ..lineTo(w * 0.88, h * 0.48)
      ..lineTo(w * 0.12, h * 0.48)
      ..close();
    canvas.drawPath(awning, _fill(const Color(0xFFE53935)));
    // Awning stripes
    for (int i = 0; i < 6; i++) {
      final x = w * (0.18 + i * 0.13);
      canvas.drawPath(
        Path()
          ..moveTo(x, h * 0.3)
          ..lineTo(x - w * 0.04, h * 0.48)
          ..lineTo(x - w * 0.01, h * 0.48)
          ..lineTo(x + w * 0.03, h * 0.3),
        _fill(Colors.white38),
      );
    }

    // Counter
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.48, w * 0.84, h * 0.15),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFF5D4037)),
    );

    // Products on counter
    final prodColors = [const Color(0xFFFF5252), const Color(0xFFFFEB3B), const Color(0xFF66BB6A)];
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(w * (0.25 + i * 0.25), h * 0.46),
        w * 0.09,
        _fill(prodColors[i]),
      );
    }

    // Poles
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.48, w * 0.04, h * 0.44), _fill(const Color(0xFF795548)));
    canvas.drawRect(Rect.fromLTWH(w * 0.86, h * 0.48, w * 0.04, h * 0.44), _fill(const Color(0xFF795548)));

    // Sign
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.08, w * 0.44, h * 0.16),
        const Radius.circular(6),
      ),
      _fill(const Color(0xFFFFEB3B)),
    );
    _drawStar(canvas, Offset(w * 0.5, h * 0.16), w * 0.06, const Color(0xFFFF8F00));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Product Box (Mahsulot) ────────────────────────────────────────────────────

class _ProductBoxPainter extends CustomPainter {
  const _ProductBoxPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Box body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.3, w * 0.76, h * 0.62),
        const Radius.circular(8),
      ),
      _fill(const Color(0xFFD7A05A)),
    );
    // Box top flaps
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.2, w * 0.35, h * 0.14),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFFBC8A3E)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.53, h * 0.2, w * 0.35, h * 0.14),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFFBC8A3E)),
    );

    // Tape strip
    canvas.drawRect(
      Rect.fromLTWH(w * 0.38, h * 0.18, w * 0.24, h * 0.38),
      _fill(const Color(0xFFFFF9C4)),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.38, h * 0.18, w * 0.24, h * 0.38),
      _stroke(const Color(0xFFFDD835), w * 0.015),
    );

    // Box face details
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.5, w * 0.56, h * 0.3),
        const Radius.circular(6),
      ),
      _fill(const Color(0xFFBC8A3E)),
    );

    // Product icons inside
    _drawStar(canvas, Offset(w * 0.36, h * 0.65), w * 0.08, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.64, h * 0.65), w * 0.08, const Color(0xFFFFEB3B));
    canvas.drawCircle(Offset(w * 0.5, h * 0.65), w * 0.065, _fill(const Color(0xFFFF5252)));

    _drawStar(canvas, Offset(w * 0.14, h * 0.14), w * 0.07, const Color(0xFF8BC34A));
    _drawStar(canvas, Offset(w * 0.86, h * 0.14), w * 0.06, const Color(0xFF8BC34A));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Trade / Savdo ─────────────────────────────────────────────────────────────

class _TradePainter extends CustomPainter {
  const _TradePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Left person (buyer)
    canvas.drawCircle(Offset(w * 0.22, h * 0.22), w * 0.12, _fill(const Color(0xFFFFCC80)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.36, w * 0.24, h * 0.32),
        const Radius.circular(8),
      ),
      _fill(const Color(0xFF1565C0)),
    );

    // Right person (seller)
    canvas.drawCircle(Offset(w * 0.78, h * 0.22), w * 0.12, _fill(const Color(0xFFFFB74D)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.66, h * 0.36, w * 0.24, h * 0.32),
        const Radius.circular(8),
      ),
      _fill(const Color(0xFFE53935)),
    );

    // Two-way arrow in center
    final arrowPaint = _fill(const Color(0xFF37474F));
    // Right arrow
    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.42, w * 0.24, h * 0.06), arrowPaint);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.66, h * 0.39)
        ..lineTo(w * 0.74, h * 0.45)
        ..lineTo(w * 0.66, h * 0.51)
        ..close(),
      arrowPaint,
    );
    // Left arrow
    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.54, w * 0.24, h * 0.06), arrowPaint);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.34, h * 0.51)
        ..lineTo(w * 0.26, h * 0.57)
        ..lineTo(w * 0.34, h * 0.63)
        ..close(),
      arrowPaint,
    );

    // Coin above left arrow
    _drawCoin(canvas, Offset(w * 0.38, h * 0.34), w * 0.08, const Color(0xFFFFD700), const Color(0xFFDAA520));
    // Box above right arrow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.58, h * 0.26, w * 0.14, h * 0.12),
        const Radius.circular(3),
      ),
      _fill(const Color(0xFF8BC34A)),
    );

    // Ground line
    canvas.drawLine(Offset(w * 0.05, h * 0.74), Offset(w * 0.95, h * 0.74), _stroke(Colors.black12, w * 0.02));
    // Stars
    _drawStar(canvas, Offset(w * 0.5, h * 0.88), w * 0.07, const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Shopping Cart (Xarid) ─────────────────────────────────────────────────────

class _ShoppingCartPainter extends CustomPainter {
  const _ShoppingCartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Cart body (wire frame look)
    final cartPaint = _stroke(const Color(0xFF455A64), w * 0.035);
    // Bottom
    canvas.drawLine(Offset(w * 0.22, h * 0.7), Offset(w * 0.85, h * 0.7), cartPaint);
    // Left side
    canvas.drawLine(Offset(w * 0.22, h * 0.7), Offset(w * 0.14, h * 0.36), cartPaint);
    // Top
    canvas.drawLine(Offset(w * 0.14, h * 0.36), Offset(w * 0.88, h * 0.36), cartPaint);
    // Right angled
    canvas.drawLine(Offset(w * 0.85, h * 0.7), Offset(w * 0.88, h * 0.36), cartPaint);

    // Handle
    canvas.drawLine(Offset(w * 0.88, h * 0.36), Offset(w * 0.96, h * 0.22), cartPaint);
    canvas.drawLine(Offset(w * 0.04, h * 0.22), Offset(w * 0.14, h * 0.36), cartPaint);
    canvas.drawLine(Offset(w * 0.04, h * 0.22), Offset(w * 0.96, h * 0.22), cartPaint);

    // Wheels
    canvas.drawCircle(Offset(w * 0.32, h * 0.82), w * 0.06, _fill(const Color(0xFF78909C)));
    canvas.drawCircle(Offset(w * 0.32, h * 0.82), w * 0.06, _stroke(const Color(0xFF37474F), w * 0.02));
    canvas.drawCircle(Offset(w * 0.72, h * 0.82), w * 0.06, _fill(const Color(0xFF78909C)));
    canvas.drawCircle(Offset(w * 0.72, h * 0.82), w * 0.06, _stroke(const Color(0xFF37474F), w * 0.02));

    // Items in cart
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.44, w * 0.16, h * 0.2), const Radius.circular(4)),
      _fill(const Color(0xFF66BB6A)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.48, h * 0.44, w * 0.16, h * 0.2), const Radius.circular(4)),
      _fill(const Color(0xFFEF5350)),
    );
    canvas.drawCircle(Offset(w * 0.73, h * 0.54), w * 0.08, _fill(const Color(0xFFFFEB3B)));

    _drawStar(canvas, Offset(w * 0.14, h * 0.12), w * 0.06, const Color(0xFFFF8F00));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Selling / Store Counter (Sotish) ──────────────────────────────────────────

class _SellingPainter extends CustomPainter {
  const _SellingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Store sign
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.06, w * 0.84, h * 0.2),
        const Radius.circular(8),
      ),
      _fill(const Color(0xFF00ACC1)),
    );
    // Sign stars
    for (int i = 0; i < 3; i++) {
      _drawStar(canvas, Offset(w * (0.28 + i * 0.22), h * 0.16), w * 0.06, const Color(0xFFFFEB3B));
    }

    // Counter body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.54, w * 0.88, h * 0.16),
        const Radius.circular(6),
      ),
      _fill(const Color(0xFF5D4037)),
    );

    // Products on display
    final colors = [const Color(0xFFEF5350), const Color(0xFFFFEB3B), const Color(0xFF66BB6A), const Color(0xFF1E88E5)];
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.1 + i * 0.21), h * 0.36, w * 0.17, h * 0.2),
          const Radius.circular(5),
        ),
        _fill(colors[i]),
      );
      // Price tag
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * (0.185 + i * 0.21), h * 0.3), width: w * 0.14, height: h * 0.08),
        _fill(const Color(0xFFFFCC02)),
      );
    }

    // Seller hands
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.35, h * 0.7, w * 0.3, h * 0.12), const Radius.circular(8)),
      _fill(const Color(0xFFFFCC80)),
    );

    // Coin exchange
    _drawCoin(canvas, Offset(w * 0.82, h * 0.74), w * 0.08, const Color(0xFFFFD700), const Color(0xFFDAA520));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Profit Chart (Foyda) ──────────────────────────────────────────────────────

class _ProfitPainter extends CustomPainter {
  const _ProfitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Background circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), w * 0.38, _fill(const Color(0xFFE8F5E9)));

    // Up arrow (profit)
    final arrowBody = Path()
      ..moveTo(w * 0.44, h * 0.7)
      ..lineTo(w * 0.44, h * 0.36)
      ..lineTo(w * 0.56, h * 0.36)
      ..lineTo(w * 0.56, h * 0.7)
      ..close();
    canvas.drawPath(arrowBody, _fill(const Color(0xFF43A047)));
    final arrowHead = Path()
      ..moveTo(w * 0.32, h * 0.38)
      ..lineTo(w * 0.5, h * 0.14)
      ..lineTo(w * 0.68, h * 0.38)
      ..close();
    canvas.drawPath(arrowHead, _fill(const Color(0xFF2E7D32)));

    // Coins on sides
    _drawCoin(canvas, Offset(w * 0.2, h * 0.55), w * 0.09, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.8, h * 0.55), w * 0.09, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.2, h * 0.72), w * 0.07, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.8, h * 0.72), w * 0.07, const Color(0xFFFFD700), const Color(0xFFDAA520));

    // Stars at top
    _drawStar(canvas, Offset(w * 0.5, h * 0.88), w * 0.08, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.14, h * 0.14), w * 0.06, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.86, h * 0.14), w * 0.06, const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Savings Pot (Jamg'arma) ───────────────────────────────────────────────────

class _SavingsPotPainter extends CustomPainter {
  const _SavingsPotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Jar body
    canvas.drawOval(
      Rect.fromLTWH(w * 0.15, h * 0.28, w * 0.7, h * 0.6),
      _fill(const Color(0xFF81D4FA)),
    );
    // Jar rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.22, w * 0.64, h * 0.12),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFF4FC3F7)),
    );
    // Jar highlight
    canvas.drawOval(
      Rect.fromLTWH(w * 0.22, h * 0.36, w * 0.18, h * 0.22),
      _fill(Colors.white38),
    );

    // Coin stack inside jar
    for (int i = 0; i < 3; i++) {
      _drawCoin(canvas, Offset(w * 0.5, h * (0.72 - i * 0.12)), w * 0.14, const Color(0xFFFFD700), const Color(0xFFDAA520));
    }

    // Coins raining in
    _drawCoin(canvas, Offset(w * 0.38, h * 0.1), w * 0.07, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.62, h * 0.06), w * 0.06, const Color(0xFFFFD700), const Color(0xFFDAA520));
    _drawCoin(canvas, Offset(w * 0.76, h * 0.12), w * 0.05, const Color(0xFFFFD700), const Color(0xFFDAA520));

    _drawStar(canvas, Offset(w * 0.15, h * 0.1), w * 0.06, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.86, h * 0.88), w * 0.05, const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Entrepreneur (Tadbirkor) ──────────────────────────────────────────────────

class _EntrepreneurPainter extends CustomPainter {
  const _EntrepreneurPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Rocket body
    final rocket = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..cubicTo(w * 0.34, h * 0.2, w * 0.26, h * 0.38, w * 0.28, h * 0.6)
      ..lineTo(w * 0.72, h * 0.6)
      ..cubicTo(w * 0.74, h * 0.38, w * 0.66, h * 0.2, w * 0.5, h * 0.06);
    canvas.drawPath(rocket, _fill(const Color(0xFF5C6BC0)));

    // Window
    canvas.drawCircle(Offset(w * 0.5, h * 0.35), w * 0.1, _fill(const Color(0xFF81D4FA)));
    canvas.drawCircle(Offset(w * 0.5, h * 0.35), w * 0.1, _stroke(Colors.white38, w * 0.02));

    // Fins
    final finL = Path()
      ..moveTo(w * 0.28, h * 0.5)
      ..lineTo(w * 0.1, h * 0.68)
      ..lineTo(w * 0.28, h * 0.64)
      ..close();
    canvas.drawPath(finL, _fill(const Color(0xFF3949AB)));
    final finR = Path()
      ..moveTo(w * 0.72, h * 0.5)
      ..lineTo(w * 0.9, h * 0.68)
      ..lineTo(w * 0.72, h * 0.64)
      ..close();
    canvas.drawPath(finR, _fill(const Color(0xFF3949AB)));

    // Flame
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.72), width: w * 0.22, height: h * 0.18),
      _fill(const Color(0xFFFF8F00)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.76), width: w * 0.14, height: h * 0.12),
      _fill(const Color(0xFFFFEB3B)),
    );

    // Stars
    _drawStar(canvas, Offset(w * 0.14, h * 0.18), w * 0.06, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.86, h * 0.22), w * 0.07, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.2, h * 0.84), w * 0.05, const Color(0xFFFFEB3B));
    _drawStar(canvas, Offset(w * 0.82, h * 0.86), w * 0.05, const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Frugal / Recycle (Tejamkorlik) ───────────────────────────────────────────

class _FrugalPainter extends CustomPainter {
  const _FrugalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Green circle background
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.38, _fill(const Color(0xFFE8F5E9)));

    // Recycle arrows (three curved arrows forming triangle)
    final arrowPaint = _stroke(const Color(0xFF2E7D32), w * 0.06);
    arrowPaint.strokeCap = StrokeCap.round;

    // Draw three arcs
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.46), width: w * 0.52, height: h * 0.52),
      -pi / 6, pi * 2 / 3, false, arrowPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.46), width: w * 0.52, height: h * 0.52),
      -pi / 6 + pi * 2 / 3, pi * 2 / 3, false, arrowPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.46), width: w * 0.52, height: h * 0.52),
      -pi / 6 + pi * 4 / 3, pi * 2 / 3, false, arrowPaint,
    );

    // Checkmark in center
    final check = Path()
      ..moveTo(w * 0.37, h * 0.46)
      ..lineTo(w * 0.46, h * 0.56)
      ..lineTo(w * 0.63, h * 0.37);
    canvas.drawPath(check, _stroke(const Color(0xFF43A047), w * 0.05));

    // Leaf decorations
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.18, h * 0.22), width: w * 0.14, height: h * 0.1),
      _fill(const Color(0xFF66BB6A)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.82, h * 0.22), width: w * 0.14, height: h * 0.1),
      _fill(const Color(0xFF66BB6A)),
    );
    canvas.drawLine(Offset(w * 0.18, h * 0.22), Offset(w * 0.18, h * 0.3), _stroke(const Color(0xFF388E3C), w * 0.02));
    canvas.drawLine(Offset(w * 0.82, h * 0.22), Offset(w * 0.82, h * 0.3), _stroke(const Color(0xFF388E3C), w * 0.02));

    _drawStar(canvas, Offset(w * 0.5, h * 0.88), w * 0.07, const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Waste / No Sign (Isrof) ───────────────────────────────────────────────────

class _WastePainter extends CustomPainter {
  const _WastePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Trash bin body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.34, w * 0.56, h * 0.58),
        const Radius.circular(8),
      ),
      _fill(const Color(0xFF78909C)),
    );
    // Bin lines
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(w * (0.35 + i * 0.12), h * 0.44),
        Offset(w * (0.35 + i * 0.12), h * 0.84),
        _stroke(const Color(0xFF546E7A), w * 0.025),
      );
    }

    // Lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.26, w * 0.68, h * 0.1),
        const Radius.circular(6),
      ),
      _fill(const Color(0xFF90A4AE)),
    );
    // Lid handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.4, h * 0.18, w * 0.2, h * 0.1),
        const Radius.circular(5),
      ),
      _fill(const Color(0xFF90A4AE)),
    );

    // Money/coins going into bin (red X over them)
    _drawCoin(canvas, Offset(w * 0.5, h * 0.12), w * 0.1, const Color(0xFFFFD700), const Color(0xFFDAA520));

    // Red X over coin
    canvas.drawLine(
      Offset(w * 0.4, h * 0.06), Offset(w * 0.6, h * 0.18),
      _stroke(const Color(0xFFE53935), w * 0.06),
    );
    canvas.drawLine(
      Offset(w * 0.6, h * 0.06), Offset(w * 0.4, h * 0.18),
      _stroke(const Color(0xFFE53935), w * 0.06),
    );

    // Warning stars (red)
    _drawStar(canvas, Offset(w * 0.14, h * 0.5), w * 0.06, const Color(0xFFEF5350));
    _drawStar(canvas, Offset(w * 0.86, h * 0.5), w * 0.06, const Color(0xFFEF5350));
  }

  @override
  bool shouldRepaint(_) => false;
}
