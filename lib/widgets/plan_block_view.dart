import 'package:flutter/material.dart';
import '../models/lesson_plan.dart';

/// Renders one [PlanBlock] so the lesson plan reads on screen the way it reads
/// in the original Word document — same headings, same tables, same order.
class PlanBlockView extends StatelessWidget {
  final PlanBlock block;
  final Color accent;

  const PlanBlockView({super.key, required this.block, required this.accent});

  @override
  Widget build(BuildContext context) {
    return switch (block.kind) {
      BlockKind.heading => _heading(),
      BlockKind.subheading => _subheading(),
      BlockKind.minorHeading => _minorHeading(),
      BlockKind.keyValue => _keyValue(),
      BlockKind.bullet => _bullet(),
      BlockKind.numbered => _numbered(),
      BlockKind.table => _table(),
      BlockKind.paragraph => _paragraph(),
    };
  }

  // ── Numbered section heading ────────────────────────────────────────────────
  Widget _heading() => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${block.number ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  _stripNumber(block.text),
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  // ── Roman sub-heading ("III. Yangi mavzu bayoni — 7 daqiqa") ────────────────
  Widget _subheading() => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 18, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        child: Text(
          block.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: accent.withValues(alpha: 0.95),
          ),
        ),
      );

  // ── Bold run-in title inside a section ("1-o'yin: …", "Yodda tuting") ──────
  Widget _minorHeading() => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 15,
              margin: const EdgeInsets.only(top: 3, right: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: Text(
                block.text,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C2C3E),
                ),
              ),
            ),
          ],
        ),
      );

  // ── "Mavzu: ...", "Ta'limiy: ..." ──────────────────────────────────────────
  Widget _keyValue() => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9E9F5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              block.label ?? '',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: accent.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              block.text,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: Color(0xFF2C2C3E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _bullet() => Padding(
        padding: const EdgeInsets.only(bottom: 7, left: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 10),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            ),
            Expanded(
              child: Text(
                block.text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF3A3A4E),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _numbered() => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 2, right: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${block.number ?? ''}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
            Expanded(
              child: Text(
                block.text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF3A3A4E),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _paragraph() => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          block.text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.55,
            color: Color(0xFF3A3A4E),
          ),
        ),
      );

  // ── Tables ─────────────────────────────────────────────────────────────────
  //
  // Lesson-plan tables are wide (4 columns), so they scroll horizontally inside
  // their own box rather than squeezing the text into unreadable columns.
  Widget _table() {
    final widths = _columnWidths(block.header.length);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E4F2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: widths.reduce((a, b) => a + b)),
          child: Column(
            children: [
              // Header row
              Container(
                color: accent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var c = 0; c < block.header.length; c++)
                      SizedBox(
                        width: widths[c],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(
                            block.header[c],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Data rows
              for (var r = 0; r < block.rows.length; r++)
                Container(
                  decoration: BoxDecoration(
                    color: r.isEven ? Colors.white : const Color(0xFFF7F7FD),
                    border: const Border(
                      top: BorderSide(color: Color(0xFFECECF6)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var c = 0; c < block.rows[r].length; c++)
                        SizedBox(
                          width: widths[c],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 9),
                            child: Text(
                              block.rows[r][c],
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: const Color(0xFF3A3A4E),
                                fontWeight:
                                    c == 0 ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// The two lesson-plan table shapes have known column roles: a short label,
  /// a narrow time/score column, then wide prose.
  static List<double> _columnWidths(int count) => switch (count) {
        4 => [124, 66, 210, 210],   // Bosqich | Vaqt | O'qituvchi | O'quvchi
        3 => [170, 56, 220],        // Mezon | Ball | Ko'rsatkich
        2 => [130, 220],
        _ => List.filled(count, 180),
      };

  /// Headings arrive as "4. Darsning texnologik xaritasi"; the number is shown
  /// in its own badge, so drop it from the label.
  static String _stripNumber(String text) =>
      text.replaceFirst(RegExp(r'^\d+\.\s*'), '');
}
