# 🌟 Pul Olami — Bolalar uchun moliyaviy savodxonlik o'yini

Flutter Android ilovasi | 1–4-sinf o'quvchilari | O'zbek tilida

---

## Tezkor ishga tushirish

```bash
# 1. Paketlarni o'rnating
flutter pub get

# 2. Android qurilmada ishga tushiring
flutter run

# 3. APK yarating
flutter build apk --release
```

---

## Loyiha tuzilmasi

```
lib/
├── main.dart                  # Ilova kirish nuqtasi
├── app.dart                   # MaterialApp + M3 tema
├── models/
│   ├── lesson.dart            # Dars modeli
│   ├── quiz_question.dart     # Test savoli modeli
│   ├── shop_item.dart         # Do'kon mahsuloti + ShopRules
│   └── money_note.dart        # Pul kupyurasi modeli
├── services/
│   ├── storage_service.dart   # SharedPreferences qatlami
│   └── game_state_service.dart# ChangeNotifier — markaziy holat
├── data/
│   ├── lessons_data.dart      # 8 ta moliyaviy atama (o'zbek tilida)
│   ├── quiz_data.dart         # 10 ta test savoli
│   └── shop_data.dart         # 9 ta do'kon mahsuloti
├── screens/
│   ├── home_screen.dart       # Bosh ekran — pul va navigatsiya
│   ├── lessons_screen.dart    # Darslar ro'yxati
│   ├── lesson_detail_screen.dart # Dars tafsiloti
│   ├── quiz_screen.dart       # Ko'p variantli test
│   ├── shop_screen.dart       # 3 bo'limli do'kon (qulf/ochish)
│   └── mini_game_screen.dart  # Pul hisoblash mini-o'yini
└── widgets/
    ├── animated_button.dart   # Animatsiyali tugma
    ├── money_display.dart     # Animatsiyali pul ko'rsatkichi
    ├── lesson_card.dart       # Dars kartochkasi
    ├── quiz_option_button.dart# Test varianti tugmasi
    ├── shop_item_card.dart    # Do'kon mahsuloti kartasi
    ├── money_note_widget.dart # Sudraluvchi kupyura
    └── celebration_overlay.dart # To'liq ekran muvaffaqiyat/xato
```

---

## O'yin mexanizmlari

### Do'kon qulflash mantiq
| Bo'lim   | Qulf ochish sharti                    | Cheklov           |
|----------|--------------------------------------|-------------------|
| Ehtiyoj  | Ochiq (boshlang'ich)                 | Cheklovsiz xarid  |
| Hohish   | Ehtiyojdan 3 ta mahsulot sotib olish | Cheklovsiz xarid  |
| Orzu     | Hohishdan 2 ta mahsulot sotib olish  | Faqat 1 ta xarid  |

### Mukofotlar
- **Test** (to'g'ri javob): +5 000 so'm
- **Mini-o'yin** (to'g'ri yig'ilgan summa): +5 000 so'm
- **Boshlang'ich balans**: 10 000 so'm

### Mini-o'yin
- Tasodifiy maqsad summa: 1 000 – 95 000 so'm
- Kupyuralar: 1k · 2k · 5k · 10k · 20k · 50k
- Drag & Drop — hamyonga tashlash
- Hamyondagi summa aniq maqsadga teng bo'lsa — g'alaba

---

## Texnik stack
- Flutter 3.x + Dart 3.x
- Material 3
- Provider (holat boshqaruvi)
- SharedPreferences (mahalliy saqlash)
- flutter_animate (animatsiyalar)
- Faqat mahalliy — backend yo'q
