import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/money_display.dart';
import 'word_game_screen.dart';

/// Shows 3 difficulty groups for the letter/word-building game.
/// Tap a group to start spelling words from that level.
class WordGameGroupsScreen extends StatelessWidget {
  const WordGameGroupsScreen({super.key});

  static const _groups = [
    _GroupInfo(
      groupId: 1,
      title: 'Oson',
      subtitle: 'Qisqa so\'zlar',
      emoji: '🌱',
      colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
      description: 'Pul, Narx, Qarz, Sarf — 3–4 ta harf',
    ),
    _GroupInfo(
      groupId: 2,
      title: 'O\'rtacha',
      subtitle: 'Uzunroq so\'zlar',
      emoji: '⚡',
      colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
      description: 'Bozor, Savdo, Xarid, Tejash — 5–6 ta harf',
    ),
    _GroupInfo(
      groupId: 3,
      title: 'Qiyin',
      subtitle: 'Katta so\'zlar',
      emoji: '🏆',
      colors: [Color(0xFFE53935), Color(0xFF880E4F)],
      description: 'Daromad, Mahsulot, Tadbirkor — 7+ ta harf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleBackButton(),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔤 Harflardan so\'z',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Darajani tanlang',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MoneyDisplay(),
                  ],
                ),
              ),

              // Intro hint
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Text('🖼️', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Rasmga qarab harflarni to\'g\'ri tartibda yig\'!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 8),

              // Group cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: _groups.length,
                  itemBuilder: (context, i) {
                    final g = _groups[i];
                    return _GroupCard(
                      info: g,
                      index: i,
                      onTap: () => _openGroup(context, g),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGroup(BuildContext context, _GroupInfo g) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, animation, __) => WordGameScreen(groupId: g.groupId),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }
}

// ── Group card ────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final _GroupInfo info;
  final int index;
  final VoidCallback onTap;

  const _GroupCard({
    required this.info,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: info.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: info.colors[0].withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Emoji circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(info.emoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          info.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Description
              Text(
                info.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.72),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 120).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

class _GroupInfo {
  final int groupId;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;
  final String description;

  const _GroupInfo({
    required this.groupId,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
    required this.description,
  });
}
