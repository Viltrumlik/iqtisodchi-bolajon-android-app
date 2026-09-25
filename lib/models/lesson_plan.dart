import 'package:flutter/material.dart';

/// The kind of content a [PlanBlock] carries.
///
/// These mirror the structure of the original Word lesson plans so a plan
/// renders on screen the same way it reads in the document.
enum BlockKind {
  heading,     // numbered section, e.g. "4. Darsning texnologik xaritasi"
  subheading,  // roman sub-section, e.g. "III. Yangi mavzu bayoni — 7 daqiqa"
  minorHeading,// bold run-in title, e.g. "1-o'yin: ...", "Yodda tuting"
  paragraph,
  bullet,
  numbered,
  keyValue,   // "Mavzu: ...", "Ta'limiy: ..."
  table,
}

/// One renderable piece of a lesson plan.
class PlanBlock {
  final BlockKind kind;
  final String text;
  final String? label;        // keyValue: the key
  final int? number;          // heading / numbered: the original number
  final List<String> header;  // table: column titles
  final List<List<String>> rows;

  const PlanBlock({
    required this.kind,
    this.text = '',
    this.label,
    this.number,
    this.header = const [],
    this.rows = const [],
  });

  factory PlanBlock.fromJson(Map<String, dynamic> json) {
    final kind = switch (json['k'] as String) {
      'h1' => BlockKind.heading,
      'h2' => BlockKind.subheading,
      'h3' => BlockKind.minorHeading,
      'li' => BlockKind.bullet,
      'ol' => BlockKind.numbered,
      'kv' => BlockKind.keyValue,
      'table' => BlockKind.table,
      _ => BlockKind.paragraph,
    };
    return PlanBlock(
      kind: kind,
      text: (json['t'] as String?) ?? '',
      label: json['l'] as String?,
      number: json['n'] as int?,
      header: (json['h'] as List?)?.cast<String>() ?? const [],
      rows: (json['r'] as List?)
              ?.map((r) => (r as List).cast<String>())
              .toList() ??
          const [],
    );
  }
}

/// A full lesson plan (dars ishlanmasi) for one grade, mirroring the source
/// Word document that ships alongside it in [docAsset].
class LessonPlan {
  final String id;
  final int grade;          // 1–4
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors; // card gradient
  final String docAsset;    // bundled .doc, for the download button
  final String docName;     // friendly filename shown when saving/sharing
  final List<PlanBlock> blocks;

  const LessonPlan({
    required this.id,
    required this.grade,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
    required this.docAsset,
    required this.docName,
    required this.blocks,
  });

  factory LessonPlan.fromJson(Map<String, dynamic> json) {
    return LessonPlan(
      id: json['id'] as String,
      grade: json['grade'] as int,
      title: json['title'] as String,
      subtitle: (json['subtitle'] as String?) ?? '',
      emoji: json['emoji'] as String,
      colors: (json['colors'] as List)
          .map((c) => Color(int.parse(c as String)))
          .toList(),
      docAsset: json['doc'] as String,
      docName: json['docName'] as String,
      blocks: (json['blocks'] as List)
          .map((b) => PlanBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Rough reading length, shown on the card so a teacher knows what to expect.
  int get sectionCount =>
      blocks.where((b) => b.kind == BlockKind.heading).length;
}
