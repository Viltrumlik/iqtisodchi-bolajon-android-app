// Word-building game data for early readers (grade 1).
// Each challenge shows a picture (via LessonIllustration) and the child
// drags the scrambled letters into the right order to spell the word.

/// A single word-building challenge.
class WordChallenge {
  /// The correct word, e.g. "Bozor".
  final String word;

  /// Matches a `lessonId` in [LessonIllustration] so the right picture is drawn.
  final String lessonId;

  /// Small helper emoji (used as a tiny accent next to the picture).
  final String emoji;

  const WordChallenge({
    required this.word,
    required this.lessonId,
    required this.emoji,
  });

  /// The word split into Uzbek letter tiles (digraphs kept together).
  List<String> get letters => splitUzbekLetters(word);
}

/// Splits an Uzbek (Latin) word into letter units, keeping the multi-character
/// letters `o'`, `g'`, `sh`, `ch`, `ng` as a single tile — pedagogically correct
/// for children who have just learned the alphabet.
///
/// Example: "Tejash" → [T, e, j, a, sh], "Jamg'arma" → [J, a, m, g', a, r, m, a].
List<String> splitUzbekLetters(String word) {
  const digraphs = ["o'", "g'", "sh", "ch", "ng"];
  final letters = <String>[];
  var i = 0;
  while (i < word.length) {
    if (i + 1 < word.length) {
      // Normalise apostrophe variants so o'/g' are detected reliably.
      final pair = word
          .substring(i, i + 2)
          .toLowerCase()
          .replaceAll('ʻ', "'")
          .replaceAll('ʼ', "'")
          .replaceAll('`', "'");
      if (digraphs.contains(pair)) {
        letters.add(word.substring(i, i + 2));
        i += 2;
        continue;
      }
    }
    letters.add(word.substring(i, i + 1));
    i += 1;
  }
  return letters;
}

/// Group 1 — Oson (3–4 letters).
const _easy = [
  WordChallenge(word: 'Pul', lessonId: 'lesson_pul', emoji: '💵'),
  WordChallenge(word: 'Narx', lessonId: 'lesson_narx', emoji: '🏷️'),
  WordChallenge(word: 'Qarz', lessonId: 'lesson_qarz', emoji: '🤲'),
  WordChallenge(word: 'Sarf', lessonId: 'lesson_sarf', emoji: '💸'),
];

/// Group 2 — O'rtacha (5–6 letters).
const _medium = [
  WordChallenge(word: 'Bozor', lessonId: 'lesson_bozor', emoji: '🏬'),
  WordChallenge(word: 'Savdo', lessonId: 'lesson_savdo', emoji: '🤝'),
  WordChallenge(word: 'Xarid', lessonId: 'lesson_xarid', emoji: '🛍️'),
  WordChallenge(word: 'Foyda', lessonId: 'lesson_foyda', emoji: '💹'),
  WordChallenge(word: 'Tejash', lessonId: 'lesson_tejash', emoji: '🐷'),
  WordChallenge(word: 'Budjet', lessonId: 'lesson_budjet', emoji: '📋'),
  WordChallenge(word: 'Hohish', lessonId: 'lesson_hohish', emoji: '🎮'),
];

/// Group 3 — Qiyin (7+ letters).
const _hard = [
  WordChallenge(word: 'Daromad', lessonId: 'lesson_daromad', emoji: '💰'),
  WordChallenge(word: 'Ehtiyoj', lessonId: 'lesson_ehtiyoj', emoji: '🍞'),
  WordChallenge(word: 'Mahsulot', lessonId: 'lesson_mahsulot', emoji: '📦'),
  WordChallenge(word: 'Tadbirkor', lessonId: 'lesson_tadbirkor', emoji: '🚀'),
  WordChallenge(word: 'Jamg\'arma', lessonId: 'lesson_jamgarma', emoji: '🏦'),
  WordChallenge(
      word: 'Investitsiya', lessonId: 'lesson_investitsiya', emoji: '📈'),
  WordChallenge(
      word: 'Tejamkorlik', lessonId: 'lesson_tejamkorlik', emoji: '♻️'),
];

/// Returns the word list for the given difficulty group (1, 2 or 3).
List<WordChallenge> wordsForGroup(int groupId) {
  switch (groupId) {
    case 1:
      return _easy;
    case 2:
      return _medium;
    case 3:
      return _hard;
    default:
      return _easy;
  }
}
