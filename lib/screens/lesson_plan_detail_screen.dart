import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/lesson_plan.dart';
import '../services/doc_download_service.dart';
import '../services/game_state_service.dart';
import '../widgets/plan_block_view.dart';

/// A full lesson plan, readable inside the app, with a download button that
/// hands the original Word document to the device.
class LessonPlanDetailScreen extends StatefulWidget {
  final LessonPlan plan;

  const LessonPlanDetailScreen({super.key, required this.plan});

  @override
  State<LessonPlanDetailScreen> createState() =>
      _LessonPlanDetailScreenState();
}

class _LessonPlanDetailScreenState extends State<LessonPlanDetailScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Opening a plan counts as reading it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GameStateService>().markPlanRead(widget.plan.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final accent = plan.colors.last;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 186,
            pinned: true,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, right: 16, bottom: 14),
              title: Text(
                plan.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: plan.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 62, 20, 54),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.emoji, style: const TextStyle(fontSize: 46)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.24),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${plan.grade}-sinf · dars ishlanmasi',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Download / share actions ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
              child: _DownloadBar(
                accent: accent,
                busy: _busy,
                onOpen: () => _run(DocDownloadService.openDoc),
                onShare: () => _run(DocDownloadService.shareDoc),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),
            ),
          ),

          // ── The plan itself ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
            sliver: SliverList.builder(
              itemCount: plan.blocks.length,
              itemBuilder: (context, i) => PlanBlockView(
                block: plan.blocks[i],
                accent: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _run(
    Future<DownloadResult> Function(String asset, String name) action,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await action(widget.plan.docAsset, widget.plan.docName);
    if (!mounted) return;
    setState(() => _busy = false);

    final (text, color) = switch (result.status) {
      DownloadStatus.opened => (
          '✅ Hujjat ochildi va qurilmaga saqlandi',
          const Color(0xFF2E7D32),
        ),
      DownloadStatus.shared => (
          '📄 Hujjat tayyor — saqlash joyini tanlang',
          const Color(0xFF1565C0),
        ),
      DownloadStatus.failed => (
          '⚠️ Hujjatni yuklab bo\'lmadi',
          const Color(0xFFC62828),
        ),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }
}

class _DownloadBar extends StatelessWidget {
  final Color accent;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  const _DownloadBar({
    required this.accent,
    required this.busy,
    required this.onOpen,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E6F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B579A).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📄', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Word hujjati',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C2C3E),
                      ),
                    ),
                    Text(
                      'To\'liq dars ishlanmasini yuklab oling',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8AA3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: busy ? null : onOpen,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(busy ? 'Yuklanmoqda…' : 'Yuklab olish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        accent.withValues(alpha: 0.55),
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onShare,
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Ulashish'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent.withValues(alpha: 0.45)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
