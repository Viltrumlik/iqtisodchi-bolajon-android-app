import 'package:flutter/material.dart';

/// Represents a single financial literacy lesson card
class Lesson {
  final String id;
  final String title;       // Uzbek term (e.g. "Tejash")
  final String explanation; // Simple child-friendly explanation in Uzbek
  final String emoji;       // Visual icon for the card
  final Color color;        // Card background color
  bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.explanation,
    required this.emoji,
    required this.color,
    this.isCompleted = false,
  });

  Lesson copyWith({bool? isCompleted}) {
    return Lesson(
      id: id,
      title: title,
      explanation: explanation,
      emoji: emoji,
      color: color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
