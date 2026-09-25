import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:economicgame/data/lesson_plans_data.dart';
import 'package:economicgame/models/lesson_plan.dart';
import 'package:economicgame/models/student_profile.dart';
import 'package:economicgame/widgets/plan_block_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('lesson plans asset', () {
    test('loads 13 plans spread across grades 1–4', () async {
      final plans = await loadLessonPlans();

      expect(plans, hasLength(13));
      for (final grade in kGrades) {
        expect(
          plans.where((p) => p.grade == grade),
          isNotEmpty,
          reason: '$grade-sinf has no lesson plans',
        );
      }
    });

    test('every plan carries content, a bundled .doc and a gradient', () async {
      final plans = await loadLessonPlans();

      for (final p in plans) {
        expect(p.title.trim(), isNotEmpty, reason: '${p.id} has no title');
        expect(p.blocks, isNotEmpty, reason: '${p.id} has no blocks');
        expect(p.docAsset, startsWith('assets/lessons/docs/'));
        expect(p.docAsset, endsWith('.doc'));
        expect(p.colors, hasLength(2), reason: '${p.id} gradient');
        expect(p.sectionCount, greaterThan(0), reason: '${p.id} sections');
      }
    });

    test('plan ids are unique', () async {
      final plans = await loadLessonPlans();
      expect(plans.map((p) => p.id).toSet(), hasLength(plans.length));
    });

    test('every plan carries the six core lesson-plan sections', () async {
      final plans = await loadLessonPlans();

      const core = [
        'Dars haqida umumiy ma’lumot',
        'Dars maqsadlari',
        'Kutiladigan natijalar',
        'Darsning texnologik xaritasi',
        'Darsning batafsil ishlanmasi',
        'Yakuniy xulosa',
      ];

      for (final p in plans) {
        final headings = p.blocks
            .where((b) => b.kind == BlockKind.heading)
            .map((b) => b.text)
            .toList();

        for (final section in core) {
          expect(headings, contains(section), reason: '${p.id} is missing it');
        }

        // Regression guard: numbered list items (e.g. the reflection questions
        // "6. Bugun uyda ...?") must never be promoted to section headings.
        for (final h in headings) {
          expect(h, isNot(endsWith('?')), reason: '${p.id}: "$h" is a list item');
        }
        expect(headings.length, lessThanOrEqualTo(9), reason: p.id);

        // Section numbers run 1..n without gaps or repeats.
        final numbers = p.blocks
            .where((b) => b.kind == BlockKind.heading)
            .map((b) => b.number)
            .toList();
        expect(numbers, List.generate(numbers.length, (i) => i + 1),
            reason: '${p.id}: section numbering');
      }
    });

    test('tables are rectangular — every row matches its header width',
        () async {
      final plans = await loadLessonPlans();

      for (final p in plans) {
        final tables = p.blocks.where((b) => b.kind == BlockKind.table);
        expect(tables, isNotEmpty, reason: '${p.id} has no tables');
        for (final t in tables) {
          expect(t.header, isNotEmpty);
          for (final row in t.rows) {
            expect(
              row,
              hasLength(t.header.length),
              reason: '${p.id}: ragged row $row',
            );
          }
        }
      }
    });
  });

  group('StudentProfile', () {
    test('is incomplete until a first name is entered', () {
      expect(StudentProfile.empty.isComplete, isFalse);
      expect(
        const StudentProfile(
          firstName: '   ',
          lastName: 'Karimov',
          gender: Gender.girl,
        ).isComplete,
        isFalse,
      );
      expect(
        const StudentProfile(
          firstName: 'Alisher',
          lastName: '',
          gender: Gender.boy,
        ).isComplete,
        isTrue,
      );
    });

    test('shortName abbreviates the surname, and copes without one', () {
      const withSurname = StudentProfile(
        firstName: 'Alisher',
        lastName: 'Karimov',
        gender: Gender.boy,
      );
      expect(withSurname.shortName, 'Alisher K.');
      expect(withSurname.fullName, 'Alisher Karimov');

      const noSurname = StudentProfile(
        firstName: 'Zilola',
        lastName: '',
        gender: Gender.girl,
      );
      expect(noSurname.shortName, 'Zilola');
      expect(noSurname.fullName, 'Zilola');
    });

    test('gender round-trips through its stored id', () {
      expect(GenderX.fromId(Gender.boy.id), Gender.boy);
      expect(GenderX.fromId(Gender.girl.id), Gender.girl);
      expect(GenderX.fromId(null), Gender.boy); // default for a fresh install
    });
  });

  group('PlanBlockView', () {
    Future<void> pump(WidgetTester tester, PlanBlock block) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PlanBlockView(
                  block: block,
                  accent: const Color(0xFF6C63FF),
                ),
              ),
            ),
          ),
        );

    testWidgets('a heading shows its number badge without the "4." prefix',
        (tester) async {
      await pump(
        tester,
        const PlanBlock(
          kind: BlockKind.heading,
          text: '4. Darsning texnologik xaritasi',
          number: 4,
        ),
      );

      expect(find.text('Darsning texnologik xaritasi'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('4. Darsning texnologik xaritasi'), findsNothing);
    });

    testWidgets('a table renders its header and every cell', (tester) async {
      await pump(
        tester,
        const PlanBlock(
          kind: BlockKind.table,
          header: ['Mezon', 'Ball', 'Ko\'rsatkich'],
          rows: [
            ['Hamkorlik', '1', 'Guruhda faol ishladi'],
            ['Jami', '8', '7–8: a\'lo'],
          ],
        ),
      );

      expect(find.text('Mezon'), findsOneWidget);
      expect(find.text('Ko\'rsatkich'), findsOneWidget);
      expect(find.text('Hamkorlik'), findsOneWidget);
      expect(find.text('Guruhda faol ishladi'), findsOneWidget);
      expect(find.text('Jami'), findsOneWidget);
    });

    testWidgets('a minor heading renders its bold run-in title',
        (tester) async {
      await pump(
        tester,
        const PlanBlock(
          kind: BlockKind.minorHeading,
          text: '1-o\'yin: "Men buni o\'zim qilaman!" — 4 daqiqa',
        ),
      );

      expect(
        find.text('1-o\'yin: "Men buni o\'zim qilaman!" — 4 daqiqa'),
        findsOneWidget,
      );
    });

    testWidgets('a key/value block shows label and value', (tester) async {
      await pump(
        tester,
        const PlanBlock(
          kind: BlockKind.keyValue,
          label: 'Mavzu',
          text: 'Asrab-avaylaymiz',
        ),
      );

      expect(find.text('Mavzu'), findsOneWidget);
      expect(find.text('Asrab-avaylaymiz'), findsOneWidget);
    });
  });
}
