import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/lesson_plan.dart';

/// Grades that have lesson plans, in the order they appear in the app.
const kGrades = [1, 2, 3, 4];

/// Loads the lesson plans (dars ishlanmalari) bundled from the original Word
/// documents. Parsed once at startup by [GameStateService].
///
/// Uses `load` + `utf8.decode` rather than `rootBundle.loadString`: the latter
/// hands anything over 50 KB to a background isolate via `compute`, and this
/// payload is ~125 KB. Spawning an isolate costs far more than decoding it
/// inline (a couple of milliseconds) on the low-end Android devices this app
/// targets — and it never completes inside a `testWidgets` fake-async zone.
Future<List<LessonPlan>> loadLessonPlans() async {
  final data = await rootBundle.load('assets/lessons/lesson_plans.json');
  final raw = utf8.decode(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  final list = jsonDecode(raw) as List;
  return list
      .map((e) => LessonPlan.fromJson(e as Map<String, dynamic>))
      .toList();
}
