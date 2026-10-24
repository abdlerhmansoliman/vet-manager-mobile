import 'package:flutter/material.dart';

/// Root Application Widget for VetManager Mobile Client.
class VetManagerApp extends StatelessWidget {
  const VetManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetManager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF8F5), // Warm Cream
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488), // Fresh Emerald
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFFFF7E67), // Warm Coral
          surface: Colors.white,
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets_rounded,
                size: 64,
                color: Color(0xFF0D9488),
              ),
              SizedBox(height: 16),
              Text(
                'VetManager Mobile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Enterprise Clinical Client',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
