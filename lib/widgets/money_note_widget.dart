import 'package:flutter/material.dart';
import '../models/money_note.dart';

/// Draggable banknote card used in the money counting mini-game.
class MoneyNoteWidget extends StatelessWidget {
  final MoneyNote note;
  final bool small; // compact version for the drop zone

  const MoneyNoteWidget({
    super.key,
    required this.note,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = small ? 70.0 : 90.0;
    final height = small ? 45.0 : 58.0;
    final fontSize = small ? 10.0 : 13.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [note.color, note.color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(small ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: note.color.withValues(alpha: 0.5),
            blurRadius: small ? 4 : 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(note.emoji, style: TextStyle(fontSize: small ? 14 : 20)),
          Text(
            note.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draggable version wrapping [MoneyNoteWidget].
class DraggableMoneyNote extends StatelessWidget {
  final MoneyNote note;
  final VoidCallback? onDragStarted;

  const DraggableMoneyNote({
    super.key,
    required this.note,
    this.onDragStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<MoneyNote>(
      data: note,
      onDragStarted: onDragStarted,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.15,
          child: MoneyNoteWidget(note: note),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: MoneyNoteWidget(note: note),
      ),
      child: MoneyNoteWidget(note: note),
    );
  }
}
