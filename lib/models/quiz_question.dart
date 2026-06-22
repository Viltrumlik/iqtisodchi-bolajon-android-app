/// A multiple-choice quiz question about financial concepts.
/// Each question has exactly 3 answer choices.
class QuizQuestion {
  final String id;
  final String question;      // Question text in Uzbek
  final List<String> options; // Exactly 3 answer choices
  final int correctIndex;     // Index of the correct option (0–2)
  final int reward;           // UZS rewarded for a correct answer
  final String explanation;   // Why this answer is correct (shown after)
  final int groupId;          // Quiz group: 1, 2, or 3

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.reward,
    required this.explanation,
    this.groupId = 1,
  });

  String get correctAnswer => options[correctIndex];
}
