import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/shop_item.dart';
import '../services/game_state_service.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import '../widgets/shop_item_card.dart';
import '../widgets/celebration_overlay.dart';
import '../services/sound_service.dart';

/// Three-section shop: Ehtiyoj → Hohish → Orzu, with progressive unlock logic.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _showOverlay = false;
  bool _overlaySuccess = false;
  String _overlayMessage = '';
  String? _overlaySubMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameStateService>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFC837), Color(0xFFFF8008)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const CircleBackButton(),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '🛒 Do\'kon',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const MoneyDisplay(),
                    ],
                  ),
                ),

                // Unlock progress
                _UnlockProgress(gs: gs),

                const SizedBox(height: 8),

                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: const Color(0xFFFF8008),
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: [
                      _sectionTab('🍞', 'Ehtiyoj', true),
                      _sectionTab('🧸', 'Hohish', gs.isHohishUnlocked),
                      _sectionTab('✈️', 'Orzu', gs.isOrzuUnlocked),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Tab views
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF8EE),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _SectionView(
                            section: ShopSection.ehtiyoj,
                            locked: false,
                            gs: gs,
                            onBuy: _handleBuy,
                          ),
                          _SectionView(
                            section: ShopSection.hohish,
                            locked: !gs.isHohishUnlocked,
                            gs: gs,
                            onBuy: _handleBuy,
                          ),
                          _SectionView(
                            section: ShopSection.orzu,
                            locked: !gs.isOrzuUnlocked,
                            gs: gs,
                            onBuy: _handleBuy,
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
              onDismiss: () => setState(() => _showOverlay = false),
            ),
        ],
      ),
    );
  }

  Future<void> _handleBuy(ShopItem item) async {
    final gs = context.read<GameStateService>();

    if (item.section == ShopSection.orzu && !gs.canBuyOrzu) {
      _show(false, 'Faqat bitta Orzu xaridi!',
          'Siz allaqachon bitta Orzu mahsulotini oldingiz.');
      return;
    }

    if (gs.money < item.price) {
      _show(false, 'Pul yetarli emas 💸',
          'Ko\'proq pul topish uchun testlarni yech!');
      return;
    }

    final wasHohishUnlocked = gs.isHohishUnlocked;
    final wasOrzuUnlocked = gs.isOrzuUnlocked;

    final success = await gs.purchaseItem(item.id);
    if (!success) return;
    SoundService().purchase();

    if (!wasHohishUnlocked && gs.isHohishUnlocked) {
      _showUnlockBanner(ShopSection.hohish);
    } else if (!wasOrzuUnlocked && gs.isOrzuUnlocked) {
      _showUnlockBanner(ShopSection.orzu);
    } else {
      _show(true, '${item.emoji} Sotib olindi!',
          '${item.name} sizniki bo\'ldi. Barakalla!');
    }
  }

  void _showUnlockBanner(ShopSection section) {
    final tabIndex = section == ShopSection.hohish ? 1 : 2;
    setState(() {
      _showOverlay = true;
      _overlaySuccess = true;
      _overlayMessage = '🔓 ${section.label} ochildi!';
      _overlaySubMessage = 'Yangi bo\'lim sizga ochildi!';
    });
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) _tabController.animateTo(tabIndex);
    });
  }

  void _show(bool success, String msg, String sub) {
    setState(() {
      _showOverlay = true;
      _overlaySuccess = success;
      _overlayMessage = msg;
      _overlaySubMessage = sub;
    });
  }

  Tab _sectionTab(String emoji, String label, bool unlocked) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(label),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: unlocked
                ? const SizedBox.shrink(key: ValueKey('u'))
                : const Icon(Icons.lock_rounded,
                    size: 12, key: ValueKey('l')),
          ),
        ],
      ),
    );
  }
}

// ── Section view ──────────────────────────────────────────────────────────────

class _SectionView extends StatelessWidget {
  final ShopSection section;
  final bool locked;
  final GameStateService gs;
  final Future<void> Function(ShopItem) onBuy;

  const _SectionView({
    required this.section,
    required this.locked,
    required this.gs,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final items = gs.shopItems.where((i) => i.section == section).toList();
    final orzuWarning = section == ShopSection.orzu;

    final content = locked
        ? _LockedView(section: section, gs: gs)
        : ListView(
            padding: const EdgeInsets.only(top: 10, bottom: 32),
            children: [
              if (orzuWarning)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFCC02)),
                  ),
                  child: const Text(
                    '⚠️ Orzu bo\'limidan faqat bitta mahsulot sotib olish mumkin!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),

              ...items.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                final canAfford = gs.money >= item.price;
                final sectionLocked =
                    section == ShopSection.orzu && !gs.canBuyOrzu;

                return ShopItemCard(
                  item: item,
                  canAfford: canAfford,
                  sectionLocked: sectionLocked && !item.isPurchased,
                  index: idx,
                  onBuy: () => onBuy(item),
                );
              }),
            ],
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 480),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(locked), child: content),
    );
  }
}

// ── Locked placeholder ─────────────────────────────────────────────────────────

class _LockedView extends StatelessWidget {
  final ShopSection section;
  final GameStateService gs;

  const _LockedView({required this.section, required this.gs});

  @override
  Widget build(BuildContext context) {
    final String hint;
    if (section == ShopSection.hohish) {
      final remaining =
          ShopRules.ehtiyojToUnlockHohish - gs.ehtiyojPurchased;
      hint = '"Ehtiyoj" bo\'limidan yana $remaining ta mahsulot sotib oing!';
    } else {
      final remaining = ShopRules.hohishToUnlockOrzu - gs.hohishPurchased;
      hint = '"Hohish" bo\'limidan yana $remaining ta mahsulot sotib oing!';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 72))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -10, duration: 1600.ms,
                  curve: Curves.easeInOut),
          const SizedBox(height: 16),
          Text(
            '${section.label} bo\'limi qulflangan',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Unlock progress bar ────────────────────────────────────────────────────────

class _UnlockProgress extends StatelessWidget {
  final GameStateService gs;
  const _UnlockProgress({required this.gs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _pill(
            '🍞',
            gs.ehtiyojPurchased,
            ShopRules.ehtiyojToUnlockHohish,
            'Hohish uchun',
            gs.isHohishUnlocked,
          ),
          const SizedBox(width: 8),
          _pill(
            '🧸',
            gs.hohishPurchased,
            ShopRules.hohishToUnlockOrzu,
            'Orzu uchun',
            gs.isOrzuUnlocked,
          ),
        ],
      ),
    );
  }

  Widget _pill(String emoji, int current, int total, String label,
      bool unlocked) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: unlocked ? 0.35 : 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (unlocked)
                        const Text('✅',
                            style: TextStyle(fontSize: 10))
                      else
                        Text(
                          '$current/$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (current / total).clamp(0.0, 1.0),
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
