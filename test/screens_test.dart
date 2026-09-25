import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:economicgame/models/student_profile.dart';
import 'package:economicgame/screens/grades_screen.dart';
import 'package:economicgame/screens/home_screen.dart';
import 'package:economicgame/screens/lesson_plan_detail_screen.dart';
import 'package:economicgame/screens/lesson_plans_screen.dart';
import 'package:economicgame/screens/onboarding_screen.dart';
import 'package:economicgame/screens/terms_screen.dart';
import 'package:economicgame/services/game_state_service.dart';

/// Smallest screen we target — if a layout fits here it fits everywhere.
const _phone = Size(360, 690);

/// `flutter test` renders with a placeholder font whose every glyph is a square
/// of the font size, which makes text roughly twice as wide as reality and
/// produces overflow errors that never happen on a device. Registering the
/// Roboto that ships with the Flutter SDK gives realistic metrics, so an
/// overflow reported here is a genuine one.
Future<void> _useRealFont() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final file = File(
      '$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
  if (!file.existsSync()) return;

  final bytes = await file.readAsBytes();
  await (FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes)))))
      .load();
}

Future<GameStateService> _freshState({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(prefs));
  final gs = GameStateService();
  await gs.init();
  return gs;
}

extension on WidgetTester {
  /// Pumps [child] inside a provider at phone size.
  ///
  /// Deliberately avoids `pumpAndSettle`: [AnimatedButton] runs a permanent
  /// idle float, so nothing in this app ever "settles". Bounded pumps are
  /// enough — layout overflow is reported the moment a frame is laid out.
  Future<void> pumpScreen(GameStateService gs, Widget child) async {
    view.physicalSize = _phone;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await pumpWidget(
      ChangeNotifierProvider<GameStateService>.value(
        value: gs,
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
          home: child,
        ),
      ),
    );
    await settleEntryAnimations();
  }

  /// Runs past the staggered entry animations without waiting for the
  /// never-ending ones.
  Future<void> settleEntryAnimations() async {
    for (var i = 0; i < 6; i++) {
      await pump(const Duration(milliseconds: 350));
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_useRealFont);

  testWidgets('GradesScreen lists all four grades with their plan counts',
      (tester) async {
    final gs = await _freshState();
    await tester.pumpScreen(gs, const GradesScreen());

    expect(find.text('📚 Darslar'), findsOneWidget);
    for (final g in [1, 2, 3, 4]) {
      await tester.scrollUntilVisible(find.text('$g-sinf'), 200,
          scrollable: find.byType(Scrollable).last);
      expect(find.text('$g-sinf'), findsOneWidget);
    }
    // 1-, 2- and 3-sinf hold three plans each; 4-sinf holds four.
    expect(find.text('📄 3 ta dars ishlanma'), findsNWidgets(3));
    expect(find.text('📄 4 ta dars ishlanma'), findsOneWidget);
  });

  testWidgets('LessonPlansScreen renders one card per plan in the grade',
      (tester) async {
    final gs = await _freshState();
    await tester.pumpScreen(gs, const LessonPlansScreen(grade: 1));

    expect(find.text('1-sinf darslari'), findsOneWidget);
    expect(find.text('Asrab-avaylaymiz'), findsOneWidget);
    expect(find.text('Men mustaqil bo‘laman'), findsOneWidget);
    expect(find.text('⬇ Word'), findsNWidgets(gs.plansForGrade(1).length));
  });

  testWidgets('every lesson plan detail screen lays out without overflow',
      (tester) async {
    final gs = await _freshState();

    // Scrolling the whole document is what surfaces overflow in the tables
    // and long prose blocks, so do it for all 13 plans.
    for (final plan in gs.lessonPlans) {
      await tester.pumpScreen(
        gs,
        LessonPlanDetailScreen(key: ValueKey(plan.id), plan: plan),
      );

      expect(find.text('Yuklab olish'), findsOneWidget,
          reason: '${plan.id}: download button missing');
      expect(find.text('Ulashish'), findsOneWidget);

      // Scrolling the document is what surfaces overflow in the wide tables
      // and long prose blocks further down.
      for (var i = 0; i < 20; i++) {
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -520),
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 40));
      }
    }
  });

  testWidgets('opening a plan marks it read and updates the grade progress',
      (tester) async {
    final gs = await _freshState();
    final plan = gs.plansForGrade(2).first;

    expect(gs.readPlanIds, isEmpty);
    await tester.pumpScreen(gs, LessonPlanDetailScreen(plan: plan));
    expect(gs.readPlanIds, contains(plan.id));

    await tester.pumpScreen(gs, const LessonPlansScreen(grade: 2));
    expect(find.text('1/3 o\'qildi'), findsOneWidget);
  });

  testWidgets('HomeScreen shows the child by name and both lesson sections',
      (tester) async {
    final gs = await _freshState(prefs: {
      'eg_first_name': 'Zilola',
      'eg_last_name': 'Karimova',
      'eg_gender': 'girl',
    });
    await tester.pumpScreen(gs, const HomeScreen());

    expect(gs.hasProfile, isTrue);
    expect(find.text('Salom, Zilola! 👋'), findsOneWidget);
    expect(find.text('Karimova'), findsOneWidget);
    // Darslar (lesson plans) and Atamalar (the old term cards) are separate.
    expect(find.text('Darslar'), findsOneWidget);
    expect(find.text('Atamalar'), findsOneWidget);
  });

  testWidgets('TermsScreen is the "Iqtisodiy atamalar" section',
      (tester) async {
    final gs = await _freshState();
    await tester.pumpScreen(gs, const TermsScreen());

    expect(find.text('📖 Iqtisodiy atamalar'), findsOneWidget);
    expect(find.text('Pul'), findsOneWidget);
  });

  testWidgets('onboarding refuses an empty name, then saves the profile',
      (tester) async {
    final gs = await _freshState();
    await tester.pumpScreen(gs, const OnboardingScreen());

    // The button stays disabled until an avatar AND a name are supplied.
    ElevatedButton startButton() => tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Boshladik! 🚀'),
        );
    expect(startButton().onPressed, isNull);

    await tester.tap(find.text('Qiz bola'));
    await tester.settleEntryAnimations();
    expect(startButton().onPressed, isNull, reason: 'name still empty');

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Isming'), 'Zilola');
    await tester.settleEntryAnimations();
    expect(startButton().onPressed, isNotNull);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Familiyang'), 'Karimova');
    await tester.settleEntryAnimations();
    await tester.tap(find.text('Boshladik! 🚀'));
    await tester.settleEntryAnimations();

    expect(gs.profile.firstName, 'Zilola');
    expect(gs.profile.lastName, 'Karimova');
    expect(gs.profile.gender, Gender.girl);
    expect(gs.hasProfile, isTrue);
  });

  testWidgets('resetting progress keeps the child\'s name and avatar',
      (tester) async {
    final gs = await _freshState(prefs: {
      'eg_first_name': 'Alisher',
      'eg_last_name': 'Karimov',
      'eg_gender': 'boy',
      'eg_read_plans': <String>['asrab_avaylaymiz'],
      'eg_money': 4200,
    });
    expect(gs.readPlanIds, hasLength(1));

    await gs.resetGame();

    expect(gs.readPlanIds, isEmpty, reason: 'progress should be wiped');
    expect(gs.money, 10000);
    expect(gs.profile.firstName, 'Alisher', reason: 'name must survive');
    expect(gs.profile.gender, Gender.boy);
    expect(gs.hasProfile, isTrue);
  });
}
