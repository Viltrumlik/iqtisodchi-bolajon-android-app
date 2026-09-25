import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../utils/format.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import '../widgets/celebration_overlay.dart';

/// A draggable jigsaw puzzle built from picture assets in `assets/puzzle/`.
/// The image is cut into an n×n grid; the child drags the shuffled pieces
/// into the correct cells.
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleImage {
  final String name;
  final String asset;
  const _PuzzleImage(this.name, this.asset);
}

const _puzzleImages = [
  _PuzzleImage('Pul', 'assets/puzzle/pul.png'),
  _PuzzleImage('Bank', 'assets/puzzle/bank.png'),
  _PuzzleImage('Tanga', 'assets/puzzle/tanga.png'),
  _PuzzleImage('Do\'kon', 'assets/puzzle/dokon.png'),
  _PuzzleImage('Tejash', 'assets/puzzle/tejash.png'),
];

class _PuzzleScreenState extends State<PuzzleScreen>
    with TickerProviderStateMixin {
  static const int _reward = 3000;

  int _gridSize = 2; // 2×2 (easy) or 3×3 (hard)
  late _PuzzleImage _image;

  // Cell index → piece index placed there (or null). A piece's correct cell
  // equals its own index, so the puzzle is solved when placement[i] == i.
  late List<int?> _placement;
  // Shuffled display order for pieces still in the tray.
  late List<int> _trayOrder;

  bool _showOverlay = false;
  bool _overlaySuccess = false;
  String _overlayMessage = '';
  String? _overlaySubMessage;
  bool _checking = false;

  int _roundsCorrect = 0;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  final Random _rng = Random();

  int get _cellCount => _gridSize * _gridSize;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _image = _puzzleImages[_rng.nextInt(_puzzleImages.length)];
    _setupPuzzle(initial: true);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _setupPuzzle({bool initial = false, bool newImage = false}) {
    if (newImage && _puzzleImages.length > 1) {
      final prev = _image;
      do {
        _image = _puzzleImages[_rng.nextInt(_puzzleImages.length)];
      } while (_image.asset == prev.asset);
    }

    _placement = List<int?>.filled(_cellCount, null);
    _trayOrder = [for (var i = 0; i < _cellCount; i++) i];
    do {
      _trayOrder.shuffle(_rng);
    } while (_cellCount > 1 && _isSorted(_trayOrder));
    _checking = false;

    if (!initial) setState(() {});
  }

  static bool _isSorted(List<int> a) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != i) return false;
    }
    return true;
  }

  bool get _isComplete => !_placement.contains(null);

  List<int> get _trayPieces =>
      [for (final p in _trayOrder) if (!_placement.contains(p)) p];

  void _placePiece(int cell, int piece) {
    setState(() {
      final prev = _placement.indexOf(piece);
      if (prev != -1) _placement[prev] = null;
      _placement[cell] = piece;
    });
    if (_isComplete) _autoCheck();
  }

  void _removeFromCell(int cell) {
    if (_placement[cell] == null || _showOverlay) return;
    setState(() => _placement[cell] = null);
  }

  void _autoCheck() {
    if (_checking || _showOverlay) return;
    _checking = true;
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) _evaluate();
    });
  }

  Future<void> _evaluate() async {
    if (!_isComplete) {
      _checking = false;
      return;
    }
    var correct = true;
    for (var i = 0; i < _cellCount; i++) {
      if (_placement[i] != i) {
        correct = false;
        break;
      }
    }

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
          ? '"${_image.name}" rasmini yig\'ding!\n+${formatMoney(_reward)} mukofot!'
          : 'Bo\'laklarni to\'g\'ri joyga qo\'y.';
      _showOverlay = true;
    });
  }

  void _setGrid(int size) {
    if (_gridSize == size || _showOverlay) return;
    _gridSize = size;
    _setupPuzzle();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final board = min(screenW - 48, 320.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
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
                              '🧩 Puzzle',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _roundsCorrect > 0
                                  ? '✅ $_roundsCorrect ta yig\'ildi'
                                  : '${_image.name} rasmini yig\'',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
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

                // White content area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF1F6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: Column(
                        children: [
                          // Difficulty + new image controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SmallToggle(
                                label: '2×2',
                                active: _gridSize == 2,
                                onTap: () => _setGrid(2),
                              ),
                              const SizedBox(width: 8),
                              _SmallToggle(
                                label: '3×3',
                                active: _gridSize == 3,
                                onTap: () => _setGrid(3),
                              ),
                              const SizedBox(width: 16),
                              _SmallToggle(
                                label: '🔀 Yangi rasm',
                                active: false,
                                onTap: () =>
                                    _setupPuzzle(newImage: true),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Puzzle board
                          AnimatedBuilder(
                            animation: Listenable.merge(
                                [_shakeAnim, _pulseAnim]),
                            builder: (_, child) => Transform.translate(
                              offset: Offset(_shakeAnim.value, 0),
                              child: Transform.scale(
                                scale:
                                    _isComplete ? _pulseAnim.value : 1.0,
                                child: child,
                              ),
                            ),
                            child: _buildBoard(board),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            '🧩 Bo\'laklarni sudrab joyiga qo\'y',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFAD1457),
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Piece tray
                          _buildTray(board),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                if (wasSuccess) _setupPuzzle(newImage: true);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBoard(double board) {
    final cell = board / _gridSize;
    return Container(
      width: board,
      height: board,
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(16),
      ),
      // Border in foregroundDecoration so it does NOT consume layout space
      // (a normal border would shrink the child and overflow the cells).
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF48FB1), width: 2),
      ),
      child: Stack(
        children: [
          // Faint full image as a guide for the youngest.
          Opacity(
            opacity: 0.15,
            child: Image.asset(
              _image.asset,
              width: board,
              height: board,
              fit: BoxFit.contain,
            ),
          ),
          Column(
            children: [
              for (var r = 0; r < _gridSize; r++)
                Row(
                  children: [
                    for (var c = 0; c < _gridSize; c++)
                      _BoardCell(
                        cellIndex: r * _gridSize + c,
                        size: cell,
                        pieceIndex: _placement[r * _gridSize + c],
                        gridSize: _gridSize,
                        boardSize: board,
                        assetPath: _image.asset,
                        onAccept: (piece) =>
                            _placePiece(r * _gridSize + c, piece),
                        onTap: () => _removeFromCell(r * _gridSize + c),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTray(double board) {
    final cell = board / _gridSize;
    final pieces = _trayPieces;
    if (pieces.isEmpty) {
      return SizedBox(
        height: cell,
        child: Center(
          child: Text(
            _isComplete ? '✨ Tekshirilyapti...' : '',
            style: const TextStyle(
              color: Color(0xFFAD1457),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final p in pieces)
          Draggable<int>(
            data: p,
            feedback: Material(
              color: Colors.transparent,
              child: _PieceImage(
                assetPath: _image.asset,
                gridSize: _gridSize,
                index: p,
                boardSize: board,
                elevated: true,
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _PieceImage(
                assetPath: _image.asset,
                gridSize: _gridSize,
                index: p,
                boardSize: board,
              ),
            ),
            child: _PieceImage(
              assetPath: _image.asset,
              gridSize: _gridSize,
              index: p,
              boardSize: board,
            ),
          ),
      ],
    );
  }
}

// ── Board cell (drop target) ────────────────────────────────────────────────

class _BoardCell extends StatefulWidget {
  final int cellIndex;
  final double size;
  final int? pieceIndex;
  final int gridSize;
  final double boardSize;
  final String assetPath;
  final ValueChanged<int> onAccept;
  final VoidCallback onTap;

  const _BoardCell({
    required this.cellIndex,
    required this.size,
    required this.pieceIndex,
    required this.gridSize,
    required this.boardSize,
    required this.assetPath,
    required this.onAccept,
    required this.onTap,
  });

  @override
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.pieceIndex != null;
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) {
        setState(() => _hovering = true);
        return true;
      },
      onLeave: (_) => setState(() => _hovering = false),
      onAcceptWithDetails: (d) {
        setState(() => _hovering = false);
        widget.onAccept(d.data);
      },
      builder: (_, __, ___) {
        return GestureDetector(
          onTap: filled ? widget.onTap : null,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _hovering
                  ? const Color(0x33F5576C)
                  : Colors.transparent,
              border: Border.all(
                color: _hovering
                    ? const Color(0xFFF5576C)
                    : const Color(0x33AD1457),
                width: _hovering ? 2 : 0.5,
              ),
            ),
            child: filled
                ? _PieceImage(
                    assetPath: widget.assetPath,
                    gridSize: widget.gridSize,
                    index: widget.pieceIndex!,
                    boardSize: widget.boardSize,
                  )
                : null,
          ),
        );
      },
    );
  }
}

// ── A single puzzle piece: a clipped sub-region of the full illustration ─────

class _PieceImage extends StatelessWidget {
  final String assetPath;
  final int gridSize;
  final int index; // correct cell index for this piece
  final double boardSize;
  final bool elevated;

  const _PieceImage({
    required this.assetPath,
    required this.gridSize,
    required this.index,
    required this.boardSize,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final n = gridSize;
    final cell = boardSize / n;
    final row = index ~/ n;
    final col = index % n;
    // Map (row,col) to an alignment that reveals exactly that sub-cell of the
    // oversized full illustration inside a cell-sized clip window.
    final align = n == 1
        ? Alignment.center
        : Alignment(-1 + 2 * col / (n - 1), -1 + 2 * row / (n - 1));

    return Container(
      decoration: elevated
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF5576C).withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(elevated ? 8 : 4),
        child: SizedBox(
          width: cell,
          height: cell,
          child: OverflowBox(
            minWidth: boardSize,
            maxWidth: boardSize,
            minHeight: boardSize,
            maxHeight: boardSize,
            alignment: align,
            child: SizedBox(
              width: boardSize,
              height: boardSize,
              child: Image.asset(
                assetPath,
                width: boardSize,
                height: boardSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small toggle / control button ───────────────────────────────────────────

class _SmallToggle extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SmallToggle({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF5576C) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF5576C), width: 1.5),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFF5576C).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : const Color(0xFFF5576C),
          ),
        ),
      ),
    );
  }
}
