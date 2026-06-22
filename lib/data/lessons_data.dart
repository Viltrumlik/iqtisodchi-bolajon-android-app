import 'package:flutter/material.dart';
import '../models/lesson.dart';

/// All financial literacy lessons in Uzbek for grades 1–4.
/// 35 lessons covering core economic concepts.
List<Lesson> buildLessons() {
  return [
    Lesson(
      id: 'lesson_pul',
      title: 'Pul',
      explanation:
          'Pul — narsa va xizmatlar uchun to\'lanadigan maxsus vosita. '
          'Non sotib olsak, kiyim kiyib, doktor ko\'rsak — bularning '
          'hammasi uchun pul to\'laymiz. Pul tirishib ishlash orqali topiladi!',
      emoji: '💵',
      color: const Color(0xFF4CAF50),
    ),
    Lesson(
      id: 'lesson_tejash',
      title: 'Tejash',
      explanation:
          'Tejash degani — pulni hozir sarflamasdan, kelajak uchun yig\'ib '
          'qo\'yishdir. Masalan, o\'yin uchun pul yig\'asan. '
          'Bu juda aqlli ish! Tejagan kishi kelajakda xursand bo\'ladi.',
      emoji: '🐷',
      color: const Color(0xFFFF8FAB),
    ),
    Lesson(
      id: 'lesson_ehtiyoj',
      title: 'Ehtiyoj',
      explanation:
          'Ehtiyoj — yashash uchun zarur bo\'lgan narsalar. '
          'Non, suv, kiyim va uy — bularning hammasi ehtiyoj. '
          'Ehtiyojni avval qondirish kerak!',
      emoji: '🍞',
      color: const Color(0xFFFFB347),
    ),
    Lesson(
      id: 'lesson_hohish',
      title: 'Hohish',
      explanation:
          'Hohish — yoqimli, lekin yashash uchun shart bo\'lmagan narsalar. '
          'O\'yinchoq, muzqaymoq yoki velosiped — bular hohish. '
          'Avval ehtiyojni qondir, keyin hohishing uchun tejab qo\'y!',
      emoji: '🎮',
      color: const Color(0xFF98D8C8),
    ),
    Lesson(
      id: 'lesson_budjet',
      title: 'Budjet',
      explanation:
          'Budjet — puling qancha kirib, qancha chiqishini oldindan '
          'rejalashtirishdir. Budjet tuzgan odam pulni isrof qilmaydi. '
          'Har oy boshida: "Qancha kirim? Qancha xarajat?" deb so\'ra!',
      emoji: '📋',
      color: const Color(0xFF9B89DC),
    ),
    Lesson(
      id: 'lesson_daromad',
      title: 'Daromad',
      explanation:
          'Daromad — ishlash yoki biror narsa qilish orqali oladigan pul. '
          'Ota-onang ishxonada ishlasa, ularning maoshi daromad hisoblanadi. '
          'Ko\'p ishlagan — ko\'p daromad oladi!',
      emoji: '💰',
      color: const Color(0xFF77DD77),
    ),
    Lesson(
      id: 'lesson_xarajat',
      title: 'Xarajat',
      explanation:
          'Xarajat — narsalar sotib olish yoki xizmatlardan foydalanish uchun '
          'sarflanadigan pul. Non sotib olsang — bu xarajat. '
          'Xarajatni nazorat qilsang, pulni tejab qolasan!',
      emoji: '🛒',
      color: const Color(0xFFFF6961),
    ),
    Lesson(
      id: 'lesson_narx',
      title: 'Narx',
      explanation:
          'Narx — biror narsa yoki xizmat uchun to\'lanadigan pul miqdori. '
          'Do\'konga borganda narxni tekshirish kerak. '
          'Aqlli haridor har doim narxni solishtiradi va arzonroqdan sotib oladi!',
      emoji: '🏷️',
      color: const Color(0xFFFF9800),
    ),
    Lesson(
      id: 'lesson_bozor',
      title: 'Bozor',
      explanation:
          'Bozor — odamlar bir-biriga narsa sotadigan va sotib oladigan joy. '
          'Bozorda narxlar talab va taklifga qarab o\'zgaradi. '
          'Ko\'p odamlar bir narsani xohlasa — narxi ko\'tariladi!',
      emoji: '🏬',
      color: const Color(0xFF26C6DA),
    ),
    Lesson(
      id: 'lesson_mahsulot',
      title: 'Mahsulot',
      explanation:
          'Mahsulot — odamlar foydalanishi uchun tayyorlangan buyum yoki '
          'oziq-ovqat. Non, kitob, kiyim, telefon — bularning hammasi mahsulot. '
          'Mahsulotni yaratish uchun mehnat va xomashyo kerak!',
      emoji: '📦',
      color: const Color(0xFF8BC34A),
    ),
    Lesson(
      id: 'lesson_savdo',
      title: 'Savdo',
      explanation:
          'Savdo — mahsulot yoki xizmatlarni sotish va sotib olish jarayoni. '
          'Sotuvchi narsa beradi, haridor pul to\'laydi — bu savdo! '
          'Savdo dunyoning barcha mamlakatlarida bo\'ladi.',
      emoji: '🤝',
      color: const Color(0xFF7E57C2),
    ),
    Lesson(
      id: 'lesson_xarid',
      title: 'Xarid',
      explanation:
          'Xarid — do\'kondan yoki bozordan narsa sotib olish. '
          'Xarid qilishdan oldin o\'yla: "Bu menga kerakmi? Pulim yetarlimi?" '
          'Rejalashtirilgan xarid — aqlli xarid!',
      emoji: '🛍️',
      color: const Color(0xFFEC407A),
    ),
    Lesson(
      id: 'lesson_sotish',
      title: 'Sotish',
      explanation:
          'Sotish — o\'zingdagi narsani boshqalarga pul evaziga berish. '
          'Agar ko\'chada limonad satsang — sen sotuvchisan! '
          'Narxni to\'g\'ri belgilab, xaridorga yaxshi munosabatda bo\'lish kerak.',
      emoji: '🏪',
      color: const Color(0xFF00ACC1),
    ),
    Lesson(
      id: 'lesson_foyda',
      title: 'Foyda',
      explanation:
          'Foyda — xarajatdan ortib qolgan pul. Masalan: 100 so\'mga narsa '
          'olib, 150 so\'mga sotsan — 50 so\'m foyda topasan! '
          'Biznes qilish uchun foyda muhim.',
      emoji: '💹',
      color: const Color(0xFF43A047),
    ),
    Lesson(
      id: 'lesson_jamgarma',
      title: 'Jamg\'arma',
      explanation:
          'Jamg\'arma — kelajak uchun yig\'ib qo\'yilgan pul. '
          'Har kuni biroz pul tejasang, oy oxirida katta summa bo\'ladi. '
          'Jamg\'arma seni katta orzung uchun tayyorlaydi!',
      emoji: '🏦',
      color: const Color(0xFFFF7043),
    ),
    Lesson(
      id: 'lesson_investitsiya',
      title: 'Investitsiya',
      explanation:
          'Investitsiya — kelajakda ko\'proq foyda olish maqsadida '
          'qilinadigan sarmoya. Kitob sotib olib o\'qisang — bu investitsiya! '
          'Bilim — eng yaxshi investitsiya.',
      emoji: '📈',
      color: const Color(0xFF87CEEB),
    ),
    Lesson(
      id: 'lesson_tadbirkor',
      title: 'Tadbirkor',
      explanation:
          'Tadbirkor — yangi g\'oya bilan ish boshlagan va boshqalarga '
          'ish o\'rni yaratib beradigan jasur inson. '
          'Sen ham katta bo\'lganingda tadbirkor bo\'lishing mumkin!',
      emoji: '🚀',
      color: const Color(0xFF5C6BC0),
    ),
    Lesson(
      id: 'lesson_tejamkorlik',
      title: 'Tejamkorlik',
      explanation:
          'Tejamkorlik — kerakli narsani ortiqcha sarf qilmay, oqilona '
          'ishlatish. Suvni, elektrni, qog\'ozni tejamoq — hammasi tejamkorlik. '
          'Tejamkor bola resurslarni muhofaza qiladi!',
      emoji: '♻️',
      color: const Color(0xFF26A69A),
    ),
    Lesson(
      id: 'lesson_isrof',
      title: 'Isrof',
      explanation:
          'Isrof — kerak bo\'lmagan narsalarga ortiqcha pul sarflash. '
          'Bir kunda 5 ta shirinlik sotib olish — isrof. '
          'Har bir so\'mni qadrla, isrof qilma!',
      emoji: '🚫',
      color: const Color(0xFFEF5350),
    ),
    Lesson(
      id: 'lesson_qarz',
      title: 'Qarz',
      explanation:
          'Qarz — birovdan olingan va qaytarib berish kerak bo\'lgan pul. '
          'Do\'stingdan pul olsang, uni unutmay qaytarib berishing kerak! '
          'Qarzni o\'z vaqtida qaytargan odam ishonchli hisoblanadi.',
      emoji: '🤲',
      color: const Color(0xFFFFD700),
    ),
    Lesson(
      id: 'lesson_iqtisod',
      title: 'Iqtisod',
      explanation:
          'Iqtisod — odamlarning pul, vaqt va buyumlarni tejab, to\'g\'ri '
          'ishlatishi. Iqtisod yaxshi yashash uchun zarur. '
          'Iqtisodchi bo\'lish uchun o\'qing va tejashni o\'rganinglar!',
      emoji: '📊',
      color: const Color(0xFF1565C0),
    ),
    Lesson(
      id: 'lesson_iqtisodiyot',
      title: 'Iqtisodiyot',
      explanation:
          'Iqtisodiyot — mamlakatdagi ishlab chiqarish, savdo, pul va '
          'ishlar tizimi. Har bir mamlakat o\'z iqtisodiyotini '
          'rivojlantirish uchun harakat qiladi!',
      emoji: '🌐',
      color: const Color(0xFF0288D1),
    ),
    Lesson(
      id: 'lesson_iqtisodiy_tarbiya',
      title: 'Iqtisodiy tarbiya',
      explanation:
          'Iqtisodiy tarbiya — bolalarni pulni tejashga, mehnat qilishga '
          'va buyumlarni asrashga o\'rgatish. Sen mana shu darslar orqali '
          'iqtisodiy tarbiya olmoqdasan!',
      emoji: '🎓',
      color: const Color(0xFF6A1B9A),
    ),
    Lesson(
      id: 'lesson_vaqt',
      title: 'Vaqt',
      explanation:
          'Vaqt — ish va dam olish uchun berilgan qimmatli daqiqalar. '
          'Vaqtni behuda o\'tkazma! O\'qish, o\'ynash, ishlash — '
          'hammasini vaqtida qilsang, ko\'p narsaga erishasiz.',
      emoji: '⏰',
      color: const Color(0xFFE65100),
    ),
    Lesson(
      id: 'lesson_ayirboshlash',
      title: 'Ayirboshlash',
      explanation:
          'Ayirboshlash — bir narsani boshqa narsaga almashtirish. '
          'Qadimda odamlar pul o\'rniga ayirboshlagan: baliq bersa non olgan. '
          'Hozir ham do\'stlar o\'rtasida ayirboshlash bo\'ladi!',
      emoji: '🔄',
      color: const Color(0xFF00695C),
    ),
    Lesson(
      id: 'lesson_haridor',
      title: 'Haridor',
      explanation:
          'Haridor — do\'kondan yoki bozordan narsa sotib oluvchi odam. '
          'Sen do\'konga borganda harikorsan! Aqlli haridor narxni '
          'solishtiradi va kerakli narsani oladi.',
      emoji: '🛍️',
      color: const Color(0xFFAD1457),
    ),
    Lesson(
      id: 'lesson_sotuvchi',
      title: 'Sotuvchi',
      explanation:
          'Sotuvchi — mahsulotni boshqalarga sotadigan odam. '
          'Do\'kondagi amaki yoki opa — sotuvchi! '
          'Yaxshi sotuvchi xaridorga to\'g\'ri va halol gapiradi.',
      emoji: '🏪',
      color: const Color(0xFF558B2F),
    ),
    Lesson(
      id: 'lesson_tarbiya',
      title: 'Tarbiya',
      explanation:
          'Tarbiya — bolaga yaxshi odob, bilim va foydali odatlarni '
          'o\'rgatish. Tejamkorlik, halollik, mehnatsevarlik — '
          'bularning hammasi yaxshi tarbiyaning belgisi!',
      emoji: '🌟',
      color: const Color(0xFF4E342E),
    ),
    Lesson(
      id: 'lesson_sarf',
      title: 'Sarf',
      explanation:
          'Sarf — biror ish yoki narsa uchun ishlatilgan pul, vaqt yoki kuch. '
          'Non olish uchun 5 000 so\'m sarflasan — bu sarf. '
          'Sarfni nazorat qilsang, ko\'p tejab qolasiz!',
      emoji: '💸',
      color: const Color(0xFFF57F17),
    ),
    Lesson(
      id: 'lesson_oila_budjeti',
      title: 'Oila budjeti',
      explanation:
          'Oila budjeti — oilaning kirim va chiqim rejasi. '
          'Ota-onan oylik maoshini qancha sarflashini rejalashtiradi — '
          'bu oila budjeti. Budjet bo\'lsa, pul taqchil bo\'lmaydi!',
      emoji: '👨‍👩‍👧‍👦',
      color: const Color(0xFF2E7D32),
    ),
    Lesson(
      id: 'lesson_mehnatsevarlik',
      title: 'Mehnatsevarlik',
      explanation:
          'Mehnatsevarlik — ishni sevib, tirishqoqlik bilan bajarish. '
          'Mehnatsevar odamlar muvaffaqiyatga erishadi! '
          'Darslaringni a\'lo o\'qisang — mehnatsevarsan.',
      emoji: '💪',
      color: const Color(0xFFBF360C),
    ),
    Lesson(
      id: 'lesson_halollik',
      title: 'Halollik',
      explanation:
          'Halollik — to\'g\'ri gapirish va aldamaslik. '
          'Savdoda halollik muhim: yaxshi mahsulot berish, '
          'to\'g\'ri narx qo\'yish. Halol odam hamma tomonidan hurmat qilinadi!',
      emoji: '🤝',
      color: const Color(0xFF1A237E),
    ),
    Lesson(
      id: 'lesson_biznes',
      title: 'Biznes',
      explanation:
          'Biznes — mahsulot yoki xizmat orqali foyda topishga qaratilgan ish. '
          'Nonvoy ham, dasturchi ham biznesmendir! '
          'Biznes qilish uchun g\'oya, mehnat va sabr kerak.',
      emoji: '💼',
      color: const Color(0xFF37474F),
    ),
    Lesson(
      id: 'lesson_ishbilarmonlik',
      title: 'Ishbilarmonlik',
      explanation:
          'Ishbilarmonlik — ishni yaxshi tashkil qilish va uddaburonlik '
          'bilan bajarish. Ishbilarmon odam ishni tez va sifatli qiladi. '
          'Sen ham ishbilarmon bo\'lishga o\'rgan!',
      emoji: '🧠',
      color: const Color(0xFF4527A0),
    ),
    Lesson(
      id: 'lesson_almashish',
      title: 'Almashish',
      explanation:
          'Almashish — bir narsani boshqasiga berib o\'zgartirish. '
          'Do\'stingga kitob bersang, u sanga o\'yinchoq bersa — almashish! '
          'Almashish orqali ikkalangiz ham kerakli narsaga egasiz.',
      emoji: '↔️',
      color: const Color(0xFF00838F),
    ),
  ];
}
