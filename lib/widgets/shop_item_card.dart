import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/shop_item.dart';
import '../utils/format.dart';

/// Card for a single shop item — shows price, purchase state, and buy button.
class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final bool canAfford;
  final bool sectionLocked;
  final VoidCallback? onBuy;
  final int index;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.canAfford,
    required this.sectionLocked,
    this.onBuy,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final purchased = item.isPurchased;
    final disabled = purchased || sectionLocked || !canAfford;
    final accent = _sectionAccent(item.section);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: disabled ? const Color(0xFFF0F0F0) : accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: purchased
              ? const Color(0xFF43A047)
              : disabled
                  ? const Color(0xFFDDDDDD)
                  : accent.withValues(alpha: 0.45),
          width: purchased ? 2.5 : 1.5,
        ),
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // Emoji circle
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: disabled
                    ? const Color(0xFFE0E0E0)
                    : accent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item.emoji,
                  style: TextStyle(fontSize: disabled ? 24 : 28),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: disabled
                          ? const Color(0xFFAAAAAA)
                          : const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatMoney(item.price),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: canAfford && !purchased && !sectionLocked
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),

            // Action
            if (purchased)
              _PurchasedBadge()
            else
              _BuyButton(
                disabled: disabled,
                accent: accent,
                onTap: disabled ? null : onBuy,
              ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 55).ms)
        .fadeIn(duration: 330.ms)
        .slideY(begin: 0.18, end: 0, curve: Curves.easeOut);
  }

  Color _sectionAccent(ShopSection section) => switch (section) {
        ShopSection.ehtiyoj => const Color(0xFF43A047),
        ShopSection.hohish => const Color(0xFF1E88E5),
        ShopSection.orzu => const Color(0xFFFF9800),
      };
}

class _PurchasedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF43A047),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'Olindi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final bool disabled;
  final Color accent;
  final VoidCallback? onTap;

  const _BuyButton({
    required this.disabled,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: disabled ? const Color(0xFFE0E0E0) : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Sotib ol',
          style: TextStyle(
            color: disabled ? const Color(0xFFAAAAAA) : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
