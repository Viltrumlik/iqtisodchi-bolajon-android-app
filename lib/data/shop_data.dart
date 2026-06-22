import '../models/shop_item.dart';

/// Full shop catalogue.
/// Ehtiyoj → buy 3 to unlock Hohish
/// Hohish  → buy 2 to unlock Orzu
/// Orzu    → can only buy 1 (dream item)
List<ShopItem> buildShopItems() {
  return [
    // ── Ehtiyoj (zaruriy narsalar) ────────────────────────────────────────────
    ShopItem(id: 'item_non',      name: 'Non',          price: 5000,  emoji: '🍞', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_suv',      name: 'Suv',          price: 3000,  emoji: '💧', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_daftar',   name: 'Daftar',       price: 7000,  emoji: '📓', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_qalam',    name: 'Qalam',        price: 2000,  emoji: '✏️', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_meva',     name: 'Meva',         price: 6000,  emoji: '🍎', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_tuxum',    name: 'Tuxum',        price: 8000,  emoji: '🥚', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_kitob',    name: 'Darslik',      price: 12000, emoji: '📖', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_sabun',    name: 'Sovun',        price: 4000,  emoji: '🧼', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_poyabzal', name: 'Poyabzal',    price: 40000, emoji: '👟', section: ShopSection.ehtiyoj),
    ShopItem(id: 'item_kiyim',    name: 'Kiyim',        price: 30000, emoji: '👕', section: ShopSection.ehtiyoj),

    // ── Hohish (yoqimli narsalar) ─────────────────────────────────────────────
    ShopItem(id: 'item_oyinchoq',   name: 'O\'yinchoq',     price: 25000,  emoji: '🧸', section: ShopSection.hohish),
    ShopItem(id: 'item_velosiped',  name: 'Velosiped',      price: 80000,  emoji: '🚲', section: ShopSection.hohish),
    ShopItem(id: 'item_shirinlik',  name: 'Shirinlik',      price: 12000,  emoji: '🍭', section: ShopSection.hohish),
    ShopItem(id: 'item_futbol',     name: 'Futbol to\'pi',  price: 35000,  emoji: '⚽', section: ShopSection.hohish),
    ShopItem(id: 'item_rasm',       name: 'Rasm to\'plam',  price: 20000,  emoji: '🎨', section: ShopSection.hohish),
    ShopItem(id: 'item_muzqaymoq',  name: 'Muzqaymoq',      price: 9000,   emoji: '🍦', section: ShopSection.hohish),
    ShopItem(id: 'item_skuter',     name: 'Skuter',         price: 160000, emoji: '🛴', section: ShopSection.hohish),
    ShopItem(id: 'item_gitara',     name: 'Gitara',         price: 120000, emoji: '🎸', section: ShopSection.hohish),
    ShopItem(id: 'item_kino',       name: 'Kino chiptasi',  price: 18000,  emoji: '🎬', section: ShopSection.hohish),
    ShopItem(id: 'item_puzzle',     name: 'Puzzle',         price: 22000,  emoji: '🧩', section: ShopSection.hohish),

    // ── Orzu (katta orzular) ──────────────────────────────────────────────────
    ShopItem(id: 'item_laptop',      name: 'Laptop',         price: 500000,  emoji: '💻', section: ShopSection.orzu),
    ShopItem(id: 'item_sayohat',     name: 'Xorijga sayohat',price: 1000000, emoji: '✈️', section: ShopSection.orzu),
    ShopItem(id: 'item_playstation', name: 'Playstation',    price: 800000,  emoji: '🎮', section: ShopSection.orzu),
    ShopItem(id: 'item_smartfon',    name: 'Smartfon',       price: 450000,  emoji: '📱', section: ShopSection.orzu),
    ShopItem(id: 'item_drone',       name: 'Drone',          price: 700000,  emoji: '🚁', section: ShopSection.orzu),
    ShopItem(id: 'item_robot',       name: 'Robot to\'plam', price: 600000,  emoji: '🤖', section: ShopSection.orzu),
    ShopItem(id: 'item_tv',          name: 'Katta TV',       price: 350000,  emoji: '📺', section: ShopSection.orzu),
    ShopItem(id: 'item_velopark',    name: 'Mototsikl',      price: 2000000, emoji: '🏍️', section: ShopSection.orzu),
    ShopItem(id: 'item_teleskop',    name: 'Teleskop',       price: 300000,  emoji: '🔭', section: ShopSection.orzu),
    ShopItem(id: 'item_kamera',      name: 'Kamera',         price: 550000,  emoji: '📷', section: ShopSection.orzu),
  ];
}
