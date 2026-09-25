import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/word_game_data.dart';
import '../services/game_state_service.dart';
import '../utils/format.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/lesson_illustration.dart';

/// Letter/word-building game for early readers.
/// A picture is shown; the child drags the scrambled letter tiles into the
/// slots in the correct order to spell the word. Correct → reward + celebration.
class WordGameScreen extends StatefulWidget {
  final int groupId;
  const WordGameScreen({super.key, required this.groupId});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen>
    with TickerProviderStateMixin {
  // Friendly tile colors, cycled by position.
  static const _tilePalette = [
    Color(0xFF7B1FA2),
    Color(0xFF1E88E5),
    Color(0xFF00897B),
    Color(0xFFF4511E),
    Color(0xFFEC407A),
    Color(0xFF6D4C41),
  ];

  late final List<WordChallenge> _pool;
  late WordChallenge _challenge;
  late List<String> _target; // correct ordered letters

  final List<String> _tiles = []; // scrambled letters (tile index = position)
  final List<int?> _slots = []; // slot index → tile index, or null

  bool _showOverlay = false;
  bool _overlaySuccess = false;
  String _overlayMessage = '';
  String? _overlaySubMessage;
  bool _checking = false;

  int _roundsPlayed = 0;
  int _roundsCorrect = 0;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  final Random _rng = Random();

  int get _reward => switch (widget.groupId) {
        1 => 2000,
        2 => 3000,
        _ => 5000,
      };

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -12, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _pool = wordsForGroup(widget.groupId);
    _challenge = _pool[_rng.nextInt(_pool.length)];
    _setupChallenge(initial: true);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Setup ──────────────────────────────────────────────────────────────────

  void _setupChallenge({bool initial = false}) {
    // Pick a new word, avoiding an immediate repeat when possible.
    if (!initial && _pool.length > 1) {
      final prev = _challenge;
      do {
        _challenge = _pool[_rng.nextInt(_pool.length)];
      } while (_challenge.word == prev.word);
    }

    _target = _challenge.letters;

    _tiles
      ..clear()
      ..addAll(_target);
    // Shuffle until the scramble differs from the answer.
    do {
      _tiles.shuffle(_rng);
    } while (_tiles.length > 1 && _listEquals(_tiles, _target));

    _slots
      ..clear()
      ..addAll(List<int?>.filled(_target.length, null));
    _checking = false;

    // No setState during initState — the first build will reflect these fields.
    if (!initial) setState(() {});
  }

  // ── Computed ─────────────────────────────────────────────────────────────

  bool get _isComplete => !_slots.contains(null);

  List<int> get _bankTileIndices =>
      [for (var i = 0; i < _tiles.length; i++) if (!_slots.contains(i)) i];

  double get _tileSize => _target.length <= 6
      ? 54
      : _target.length <= 9
          ? 48
          : 42;

  // ── Actions ────────────────────────────────────────────────────────────────

  void _placeInSlot(int slotIndex, int tileIndex) {
    setState(() {
      // If this tile was already in another slot, free that slot.
      final prev = _slots.indexOf(tileIndex);
      if (prev != -1) _slots[prev] = null;
      // Any tile previously in the target slot returns to the bank
      // automatically (it is simply no longer referenced).
      _slots[slotIndex] = tileIndex;
    });
    if (_isComplete) _autoCheck();
  }

  void _removeFromSlot(int slotIndex) {
    if (_slots[slotIndex] == null || _showOverlay) return;
    setState(() => _slots[slotIndex] = null);
  }

  void _clearSlots() {
    if (_showOverlay) return;
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = null;
      }
    });
  }

  void _autoCheck() {
    if (_checking || _showOverlay) return;
    _checking = true;
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _evaluate();
    });
  }

  void _manualCheck() {
    if (_checking || _showOverlay) return;
    if (!_isComplete) {
      _shakeCtrl.forward(from: 0);
      return;
    }
    _checking = true;
    _evaluate();
  }

  Future<void> _evaluate() async {
    // A tile may have been pulled out during the auto-check delay.
    if (!_isComplete) {
      _checking = false;
      return;
    }
    final assembled = [for (final i in _slots) _tiles[i!]];
    final correct = _listEquals(assembled, _target);
    _roundsPlayed++;

    if (correct) {
      _roundsCorrect++;
      _pulseCtrl.forward(from: 0);
      await context.read<GameStateService>().addMoney(_reward);
    } else {
      _shakeCtrl.forward(from: 0);
    }
    if (!mounted) return;
    setState(() {
      _overlaySuccess = correct;
      _overlayMessage = correct ? '🎉 Ajoyib!' : 'Yana urinib ko\'r 😅';
      _overlaySubMessage = correct
          ? '"${_challenge.word}" so\'zini tuzding!\n+${formatMoney(_reward)} mukofot!'
          : 'Harflarni to\'g\'ri tartibda joyla.';
      _showOverlay = true;
    });
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const CircleBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🔤 Harflardan so\'z',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            if (_roundsPlayed > 0)
                              Text(
                                '✅ $_roundsCorrect / $_roundsPlayed to\'g\'ri',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const MoneyDisplay(),
                    ],
                  ),
                ),

                // Picture clue card
                _ClueCard(challenge: _challenge, letterCount: _target.length)
                    .animate(key: ValueKey(_challenge.word))
                    .fadeIn(duration: 380.ms)
                    .slideY(begin: -0.12, end: 0),

                const SizedBox(height: 8),

                // White content area
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFFCF4),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Answer slots
                        AnimatedBuilder(
                          animation: Listenable.merge(
                              [_shakeAnim, _pulseAnim]),
                          builder: (_, child) => Transform.translate(
                            offset: Offset(_shakeAnim.value, 0),
                            child: Transform.scale(
                              scale: _isComplete ? _pulseAnim.value : 1.0,
                              child: child,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (var s = 0; s < _slots.length; s++)
                                  _SlotBox(
                                    size: _tileSize,
                                    letter: _slots[s] == null
                                        ? null
                                        : _tiles[_slots[s]!],
                                    color: _tilePalette[s % _tilePalette.length],
                                    onAccept: (tileIndex) =>
                                        _placeInSlot(s, tileIndex),
                                    onTap: () => _removeFromSlot(s),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Action buttons
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ActionBtn(
                                  label: '🗑️ Tozalash',
                                  color: const Color(0xFFE53935),
                                  onTap: _clearSlots,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ActionBtn(
                                  label: '🔀 Yangi so\'z',
                                  color: const Color(0xFF00897B),
                                  onTap: () => _setupChallenge(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _ActionBtn(
                                  label: '✅ Tekshirish',
                                  color: const Color(0xFF2E7D32),
                                  onTap: _manualCheck,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Bank label
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text('🔡', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Harflarni sudrab kataklarga joyla',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1B5E20),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Scrambled letter bank
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final idx in _bankTileIndices)
                                  _DraggableTile(
                                    tileIndex: idx,
                                    letter: _tiles[idx],
                                    size: _tileSize,
                                    color: _tilePalette[
                                        idx % _tilePalette.length],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Result overlay
          if (_showOverlay)
            CelebrationOverlay(
              success: _overlaySuccess,
              message: _overlayMessage,
              subMessage: _overlaySubMessage,
              onDismiss: () {
                final wasSuccess = _overlaySuccess;
                setState(() {
                  _showOverlay = false;
                  _checking = false;
                });
                if (wasSuccess) _setupChallenge();
              },
            ),
        ],
      ),
    );
  }
}

// ── Picture clue card ───────────────────────────────────────────────────────

class _ClueCard extends StatelessWidget {
  final WordChallenge challenge;
  final int letterCount;
  const _ClueCard({required this.challenge, required this.letterCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11998E).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LessonIllustration(lessonId: challenge.lessonId, size: 92),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(challenge.emoji,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    const Text(
                      'Bu so\'z:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Show the actual word so the youngest readers can copy it.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    challenge.word,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF11998E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '📦 $letterCount ta harf',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00695C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Answer slot (drop target) ───────────────────────────────────────────────

class _SlotBox extends StatefulWidget {
  final double size;
  final String? letter;
  final Color color;
  final ValueChanged<int> onAccept;
  final VoidCallback onTap;

  const _SlotBox({
    required this.size,
    required this.letter,
    required this.color,
    required this.onAccept,
    required this.onTap,
  });

  @override
  State<_SlotBox> createState() => _SlotBoxState();
}

class _SlotBoxState extends State<_SlotBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.letter != null;

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) {
        setState(() => _hovering = true);
        return true;
      },
      onLeave: (_) => setState(() => _hovering = false),
      onAcceptWithDetails: (details) {
        setState(() => _hovering = false);
        widget.onAccept(details.data);
      },
      builder: (_, __, ___) {
        return GestureDetector(
          onTap: filled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: filled ? widget.color : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hovering
                    ? const Color(0xFF2E7D32)
                    : filled
                        ? widget.color
                        : const Color(0xFFB2DFDB),
                width: 2.5,
              ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              widget.letter ?? '',
              style: TextStyle(
                fontSize: widget.size * 0.46,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Draggable letter tile ───────────────────────────────────────────────────

class _DraggableTile extends StatelessWidget {
  final int tileIndex;
  final String letter;
  final double size;
  final Color color;

  const _DraggableTile({
    required this.tileIndex,
    required this.letter,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tile = _TileFace(letter: letter, size: size, color: color);

    return Draggable<int>(
      data: tileIndex,
      feedback: Material(
        color: Colors.transparent,
        child: _TileFace(letter: letter, size: size * 1.12, color: color),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TileFace(letter: letter, size: size, color: color),
      ),
      child: tile,
    );
  }
}

class _TileFace extends StatelessWidget {
  final String letter;
  final double size;
  final Color color;

  const _TileFace({
    required this.letter,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.2)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.46,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Action button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.42),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
