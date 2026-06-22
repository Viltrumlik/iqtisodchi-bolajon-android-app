import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/money_note.dart';
import '../services/game_state_service.dart';
import '../utils/format.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import '../widgets/money_note_widget.dart';
import '../widgets/celebration_overlay.dart';

/// Drag-and-drop money counting mini-game.
/// Drop banknotes into the wallet until the total matches the target.
/// Exact match → instant auto-check + celebration + reward.
class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen>
    with TickerProviderStateMixin {
  static const int _reward = 5000;

  late int _targetAmount;

  // Grouped by denomination: value → count
  final Map<int, int> _walletCounts = {};

  bool _showOverlay = false;
  bool _overlaySuccess = false;
  String _overlayMessage = '';
  String? _overlaySubMessage;
  bool _checking = false;

  // Session score
  int _roundsPlayed = 0;
  int _roundsCorrect = 0;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  final Random _rng = Random();

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

    _generateTarget();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Target ─────────────────────────────────────────────────────────────────

  void _generateTarget() {
    const multiples = [
      1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 95
    ];
    setState(() {
      _targetAmount = multiples[_rng.nextInt(multiples.length)] * 1000;
      _walletCounts.clear();
      _checking = false;
    });
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  int get _walletTotal =>
      _walletCounts.entries.fold(0, (s, e) => s + e.key * e.value);

  int get _walletNoteCount =>
      _walletCounts.values.fold(0, (s, c) => s + c);

  // ── Actions ───────────────────────────────────────────────────────────────

  void _onNoteDropped(MoneyNote note) {
    setState(() {
      _walletCounts[note.value] = (_walletCounts[note.value] ?? 0) + 1;
    });
    if (_walletTotal == _targetAmount && !_checking) {
      _checking = true;
      Future.delayed(const Duration(milliseconds: 180), _autoSuccess);
    }
  }

  void _onRemoveNote(int noteValue) {
    setState(() {
      final current = _walletCounts[noteValue] ?? 0;
      if (current <= 1) {
        _walletCounts.remove(noteValue);
      } else {
        _walletCounts[noteValue] = current - 1;
      }
    });
  }

  Future<void> _autoSuccess() async {
    if (!mounted) return;
    _roundsPlayed++;
    _roundsCorrect++;
    _pulseCtrl.forward(from: 0);
    await context.read<GameStateService>().addMoney(_reward);
    if (!mounted) return;
    setState(() {
      _overlaySuccess = true;
      _overlayMessage = '🎉 Ajoyib!';
      _overlaySubMessage =
          '${formatMoney(_targetAmount)} to\'g\'ri topdingiz!\n+${formatMoney(_reward)} mukofot!';
      _showOverlay = true;
    });
  }

  Future<void> _checkAnswer() async {
    if (_walletNoteCount == 0 || _showOverlay) return;
    _roundsPlayed++;
    if (_walletTotal == _targetAmount) {
      _roundsCorrect++;
      _pulseCtrl.forward(from: 0);
      await context.read<GameStateService>().addMoney(_reward);
      if (!mounted) return;
      setState(() {
        _overlaySuccess = true;
        _overlayMessage = '🎉 To\'g\'ri!';
        _overlaySubMessage =
            '${formatMoney(_targetAmount)} to\'g\'ri!\n+${formatMoney(_reward)} mukofot!';
        _showOverlay = true;
      });
    } else {
      _shakeCtrl.forward(from: 0);
      setState(() {
        _overlaySuccess = false;
        _overlayMessage = 'Noto\'g\'ri 😅';
        _overlaySubMessage =
            'Sizniki: ${formatMoney(_walletTotal)}\nKerak: ${formatMoney(_targetAmount)}';
        _showOverlay = true;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final total = _walletTotal;
    final isOver = total > _targetAmount;
    final isExact = total == _targetAmount && _walletNoteCount > 0;
    final progress =
        _targetAmount == 0 ? 0.0 : (total / _targetAmount).clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
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
                              '🎲 Pul O\'yini',
                              style: TextStyle(
                                fontSize: 22,
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

                // Target card
                _TargetCard(amount: _targetAmount)
                    .animate(key: ValueKey(_targetAmount))
                    .fadeIn(duration: 380.ms)
                    .slideY(begin: -0.12, end: 0),

                const SizedBox(height: 8),

                // White content area
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F0FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 14),

                          // Wallet drop zone
                          _WalletDropZone(
                            walletCounts: _walletCounts,
                            total: total,
                            target: _targetAmount,
                            progress: progress,
                            isOver: isOver,
                            isExact: isExact,
                            shakeAnim: _shakeAnim,
                            pulseAnim: _pulseAnim,
                            onAccept: _onNoteDropped,
                            onRemoveNote: _onRemoveNote,
                          ),

                          const SizedBox(height: 10),

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
                                    onTap: () => setState(
                                        () => _walletCounts.clear()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ActionBtn(
                                    label: '🔀 Yangi',
                                    color: const Color(0xFF5E35B1),
                                    onTap: _generateTarget,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: _ActionBtn(
                                    label: '✅ Tekshirish',
                                    color: const Color(0xFF7B1FA2),
                                    onTap: _checkAnswer,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Bank label
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text('💸', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  'Pullarni sudrab Hamyonga tashlang',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6A1B9A),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Banknote grid
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.75,
                              children: kMoneyNotes.asMap().entries.map((e) {
                                return DraggableMoneyNote(note: e.value)
                                    .animate(delay: (e.key * 55).ms)
                                    .fadeIn(duration: 280.ms)
                                    .scale(
                                      begin: const Offset(0.8, 0.8),
                                      end: const Offset(1, 1),
                                      duration: 280.ms,
                                    );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
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
                setState(() {
                  _showOverlay = false;
                  _checking = false;
                });
                if (_overlaySuccess) _generateTarget();
              },
            ),
        ],
      ),
    );
  }
}

// ── Target card ───────────────────────────────────────────────────────────────

class _TargetCard extends StatelessWidget {
  final int amount;
  const _TargetCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yig\'ish kerak:',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatMoney(amount),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7B1FA2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Wallet drop zone ──────────────────────────────────────────────────────────

class _WalletDropZone extends StatefulWidget {
  final Map<int, int> walletCounts;
  final int total;
  final int target;
  final double progress;
  final bool isOver;
  final bool isExact;
  final Animation<double> shakeAnim;
  final Animation<double> pulseAnim;
  final ValueChanged<MoneyNote> onAccept;
  final ValueChanged<int> onRemoveNote;

  const _WalletDropZone({
    required this.walletCounts,
    required this.total,
    required this.target,
    required this.progress,
    required this.isOver,
    required this.isExact,
    required this.shakeAnim,
    required this.pulseAnim,
    required this.onAccept,
    required this.onRemoveNote,
  });

  @override
  State<_WalletDropZone> createState() => _WalletDropZoneState();
}

class _WalletDropZoneState extends State<_WalletDropZone> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isExact
        ? const Color(0xFF43A047)
        : widget.isOver
            ? const Color(0xFFF44336)
            : _hovering
                ? const Color(0xFF9C27B0)
                : const Color(0xFFCE93D8);

    final bgColor = widget.isExact
        ? const Color(0xFFE8F5E9)
        : widget.isOver
            ? const Color(0xFFFFEBEE)
            : _hovering
                ? const Color(0xFFF3E5F5)
                : const Color(0xFFFAF0FF);

    return AnimatedBuilder(
      animation: Listenable.merge([widget.shakeAnim, widget.pulseAnim]),
      builder: (_, child) => Transform.translate(
        offset: Offset(widget.shakeAnim.value, 0),
        child: Transform.scale(
          scale: widget.isExact ? widget.pulseAnim.value : 1.0,
          child: child,
        ),
      ),
      child: DragTarget<MoneyNote>(
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
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor, width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('👜', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 6),
                        Text(
                          'Hamyon',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                      ],
                    ),
                    // Running total chip
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        formatMoney(widget.total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    backgroundColor:
                        Colors.purple.withValues(alpha: 0.15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 8),

                // Notes in wallet
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: widget.walletCounts.isEmpty
                      ? Center(
                          child: Text(
                            _hovering
                                ? '✨ Qo\'yib yuboring!'
                                : '👆 Pullarni shu yerga tashlang',
                            style: TextStyle(
                              color: Colors.purple.shade300,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.walletCounts.entries
                              .where((e) => e.value > 0)
                              .map((e) {
                            final note = kMoneyNotes
                                .firstWhere((n) => n.value == e.key);
                            return GestureDetector(
                              onTap: () => widget.onRemoveNote(e.key),
                              child: _WalletNoteChip(
                                note: note,
                                count: e.value,
                              )
                                  .animate()
                                  .fadeIn(duration: 180.ms)
                                  .scale(
                                    begin: const Offset(0.7, 0.7),
                                    end: const Offset(1, 1),
                                    duration: 200.ms,
                                  ),
                            );
                          }).toList(),
                        ),
                ),

                if (widget.isExact)
                  const Center(
                    child: Text(
                      '🎯 Aniq!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ).animate().fadeIn(duration: 280.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Wallet note chip (grouped) ────────────────────────────────────────────────

class _WalletNoteChip extends StatelessWidget {
  final MoneyNote note;
  final int count;

  const _WalletNoteChip({required this.note, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        MoneyNoteWidget(note: note, small: true),
        // Count badge
        Positioned(
          top: -6,
          right: -6,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: note.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: note.color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        // Remove indicator
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove, size: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ── Action button ──────────────────────────────────────────────────────────────

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
