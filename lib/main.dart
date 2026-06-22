import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/game_state_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for a consistent child-friendly layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make status bar transparent so gradients extend behind it
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Bootstrap game state (loads SharedPreferences)
  final gameState = GameStateService();
  await gameState.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => gameState,
      child: const EconomicGameApp(),
    ),
  );
}
