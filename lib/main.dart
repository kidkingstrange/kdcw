import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/game_storage.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize offline persistent game storage
  final storage = GameStorage();
  await storage.init();

  runApp(const KDramaCrosswordsApp());
}

class KDramaCrosswordsApp extends StatelessWidget {
  const KDramaCrosswordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GameStorage();

    return AnimatedBuilder(
      animation: storage,
      builder: (context, _) {
        return MaterialApp(
          title: 'K-Drama Crosswords',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
