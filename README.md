# 🌟 Iqtisodchi Bolajon — bolalar uchun moliyaviy savodxonlik ilovasi

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

## Bo'limlar

| Bo'lim | Nima qiladi |
|--------|-------------|
| 📚 **Darslar** | 1–4-sinf uchun 13 ta to'liq **dars ishlanmasi**. Ilova ichida o'qish yoki Word (.doc) fayl sifatida yuklab olish |
| 📖 **Atamalar** | Iqtisodiy atamalar lug'ati — pul, tejash, budjet, foyda va boshqalar |
| 🧠 **Test** | 3 guruhga bo'lingan ko'p variantli savollar |
| 🛒 **Do'kon** | Ehtiyoj → Hohish → Orzu — bosqichma-bosqich ochiladi |
| 🎲 **O'yin** | Kupyuralarni sudrab kerakli summani yig'ish |
| 🔤 **Harflar** | So'z tuzish o'yini |
| 🪙 **Sanash** | Tangalarni sanash mashqi |
| 🧩 **Puzzle** | Rasm yig'ish |

### Dars ishlanmalari

Har bir sinf uchun tayyor dars ishlanmalari asl Word hujjatlaridan olingan va
ilovada aynan hujjatdagidek ko'rinadi — sarlavhalar, jadvallar (texnologik
xarita, baholash mezonlari), ro'yxatlar va bosqichlar saqlangan.

| Sinf | Darslar |
|------|---------|
| 1-sinf | Asrab-avaylaymiz · Maktabim — ikkinchi uyim · Men mustaqil bo'laman |
| 2-sinf | Bizga telefon, televizor va kompyuter nima uchun kerak? · Jamoat transporti · Hamkorlik an'analari |
| 3-sinf | Mening odatlarim · Volontyorlik · O'zimni boshqaraman |
| 4-sinf | Baxt oiladan boshlanadi · Chiqindini qayta ishlash · Qobiliyatlarni rivojlantiramiz · Suv zahiralari |

Har bir darsda ikkita tugma bor:
- **Yuklab olish** — hujjatni qurilmaga saqlaydi va Word ilovasida ochadi
- **Ulashish** — tizim menyusi orqali Files / Drive / Telegramga yuboradi

Fayllar `assets/lessons/docs/` ichida ilova bilan birga keladi, shuning uchun
internet talab qilinmaydi.

### O'quvchi profili

Ilova birinchi marta ochilganda bola o'zini tanishtiradi: **o'g'il yoki qiz**
avatarini tanlaydi va **ism-familiyasini** kiritadi. Ism bosh ekranda
ko'rinadi; avatarga bosib uni istalgan vaqtda o'zgartirish mumkin.
Ma'lumot faqat qurilmada saqlanadi va progressni tozalaganda ham o'chmaydi.

---

## Loyiha tuzilmasi

```
lib/
├── main.dart                      # Ilova kirish nuqtasi
├── app.dart                       # MaterialApp + M3 tema + profil darvozasi
├── models/
│   ├── lesson.dart                # Iqtisodiy atama modeli
│   ├── lesson_plan.dart           # Dars ishlanmasi + PlanBlock
│   ├── student_profile.dart       # O'quvchi ismi va avatari
│   ├── quiz_question.dart
│   ├── shop_item.dart             # Do'kon mahsuloti + ShopRules
│   └── money_note.dart
├── services/
│   ├── storage_service.dart       # SharedPreferences qatlami
│   ├── game_state_service.dart    # ChangeNotifier — markaziy holat
│   ├── doc_download_service.dart  # .doc faylni saqlash / ochish / ulashish
│   └── sound_service.dart
├── data/
│   ├── lesson_plans_data.dart     # lesson_plans.json ni yuklaydi
│   ├── lessons_data.dart          # Iqtisodiy atamalar
│   ├── quiz_data.dart
│   ├── word_game_data.dart
│   └── shop_data.dart
├── screens/
│   ├── home_screen.dart           # Bosh ekran
│   ├── onboarding_screen.dart     # Ism + avatar tanlash
│   ├── grades_screen.dart         # Sinf tanlash (1–4)
│   ├── lesson_plans_screen.dart   # Sinf ichidagi darslar
│   ├── lesson_plan_detail_screen.dart # Dars matni + yuklab olish
│   ├── terms_screen.dart          # Iqtisodiy atamalar ro'yxati
│   ├── term_detail_screen.dart    # Atama tafsiloti
│   ├── quiz_groups_screen.dart · quiz_screen.dart
│   ├── shop_screen.dart · mini_game_screen.dart
│   └── word_game_*.dart · coin_count_screen.dart · puzzle_screen.dart
└── widgets/
    ├── plan_block_view.dart       # Dars ishlanmasi bloklarini chizadi
    ├── animated_button.dart · money_display.dart
    ├── lesson_card.dart · lesson_illustration.dart
    ├── quiz_option_button.dart · shop_item_card.dart
    └── money_note_widget.dart · celebration_overlay.dart

assets/
├── lessons/lesson_plans.json      # 13 ta dars ishlanmasi (matn)
├── lessons/docs/*.doc             # asl Word hujjatlari
├── avatars/{boy,girl}.png         # o'g'il / qiz avatarlari
├── icon/app_icon.png              # ilova belgisi manbasi
├── puzzle/ · sounds/
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

---

## Ilova belgisi va avatarlarni qayta yaratish

Rasm fayllari `assets/icon/` va `assets/avatars/` ichida. Ularni qayta
generatsiya qilish uchun:

```bash
python3 tool/generate_art.py
```

Skript `assets/avatars/{boy,girl}.png`, `assets/icon/app_icon.png` hamda
`android/app/src/main/res/mipmap-*/ic_launcher{,_round}.png` fayllarini
qaytadan chizadi. Faqat Pillow kerak: `pip install pillow`.

---

## Testlar

```bash
flutter test
```

`test/widget_test.dart` — modellar, dars ishlanmasi ma'lumotlari va blok
render qilish. `test/screens_test.dart` — ekranlarning telefon o'lchamida
overflow'siz chizilishi, profil saqlash va progress mantiqi.

> Eslatma: ilovada doimiy animatsiyalar bor (`AnimatedButton` idle float),
> shuning uchun testlarda `pumpAndSettle()` emas, chegaralangan `pump()`
> ishlatiladi.

---

## Texnik stack
- Flutter 3.x + Dart 3.x, Material 3
- Provider (holat boshqaruvi)
- SharedPreferences (mahalliy saqlash)
- flutter_animate (animatsiyalar)
- share_plus · open_filex · path_provider (hujjat yuklab olish)
- Faqat mahalliy — backend yo'q
