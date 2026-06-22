import 'package:flutter/material.dart';

/// Represents a denomination of Uzbek so'm used in the money mini-game
class MoneyNote {
  final int value;       // Value in UZS (e.g. 1000, 5000)
  final String label;   // Display label (e.g. "1 000")
  final Color color;    // Unique banknote color
  final String emoji;   // Icon for the note

  const MoneyNote({
    required this.value,
    required this.label,
    required this.color,
    required this.emoji,
  });
}

/// All available denominations for the mini-game
const List<MoneyNote> kMoneyNotes = [
  MoneyNote(value: 1000,  label: "1 000",  color: Color(0xFF81C784), emoji: "💵"),
  MoneyNote(value: 2000,  label: "2 000",  color: Color(0xFF64B5F6), emoji: "💵"),
  MoneyNote(value: 5000,  label: "5 000",  color: Color(0xFFFFB74D), emoji: "💴"),
  MoneyNote(value: 10000, label: "10 000", color: Color(0xFFBA68C8), emoji: "💴"),
  MoneyNote(value: 20000, label: "20 000", color: Color(0xFFFF8A65), emoji: "💶"),
  MoneyNote(value: 50000, label: "50 000", color: Color(0xFF4DB6AC), emoji: "💶"),
];
