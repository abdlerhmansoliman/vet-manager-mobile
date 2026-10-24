import 'package:flutter/material.dart';
import '../features/showcase/presentation/screens/ui_showcase_screen.dart';
import 'theme/app_theme.dart';

/// Root Application Widget for VetManager Mobile Client.
class VetManagerApp extends StatelessWidget {
  const VetManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const UiShowcaseScreen(),
    );
  }
}
