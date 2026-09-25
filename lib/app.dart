import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_state_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

/// Root widget — configures Material 3 theme with child-friendly colors.
class EconomicGameApp extends StatelessWidget {
  const EconomicGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iqtisodchi Bolajon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        // Rounded card shape globally
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        fontFamily: 'Roboto',
      ),
      home: const _Root(),
    );
  }
}

/// Sends first-time users to the welcome screen; everyone else straight home.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final hasProfile =
        context.select<GameStateService, bool>((gs) => gs.hasProfile);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      child: hasProfile
          ? const HomeScreen(key: ValueKey('home'))
          : const OnboardingScreen(key: ValueKey('onboarding')),
    );
  }
}
