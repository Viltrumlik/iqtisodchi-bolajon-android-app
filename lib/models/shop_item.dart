/// Which section of the shop an item belongs to
enum ShopSection { ehtiyoj, hohish, orzu }

extension ShopSectionLabel on ShopSection {
  String get label {
    switch (this) {
      case ShopSection.ehtiyoj:
        return 'Ehtiyoj';
      case ShopSection.hohish:
        return 'Hohish';
      case ShopSection.orzu:
        return 'Orzu';
    }
  }

  String get description {
    switch (this) {
      case ShopSection.ehtiyoj:
        return 'Zaruriy narsalar';
      case ShopSection.hohish:
        return 'Yoqimli narsalar';
      case ShopSection.orzu:
        return 'Orzumdagi narsalar';
    }
  }
}

/// A purchasable item in the shop
class ShopItem {
  final String id;
  final String name;       // Item name in Uzbek
  final int price;         // Price in UZS
  final String emoji;      // Visual representation
  final ShopSection section;
  bool isPurchased;

  ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.section,
    this.isPurchased = false,
  });

  ShopItem copyWith({bool? isPurchased}) {
    return ShopItem(
      id: id,
      name: name,
      price: price,
      emoji: emoji,
      section: section,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

/// Unlock thresholds: how many items must be bought in the previous section
/// to unlock the next section.
class ShopRules {
  /// Buy 3 Ehtiyoj items → unlock Hohish
  static const int ehtiyojToUnlockHohish = 3;

  /// Buy 2 Hohish items → unlock Orzu
  static const int hohishToUnlockOrzu = 2;

  /// Player may only purchase 1 item from Orzu
  static const int orzuMaxPurchases = 1;
}
