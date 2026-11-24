import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const GujaratPolicePrepApp());
}

class GujaratPolicePrepApp extends StatelessWidget {
  const GujaratPolicePrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSI Mock Test (Gujarat Police)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D253F), // Gujarat Police Navy Blue
          primary: const Color(0xFF0D253F),
          secondary: const Color(0xFFFFC107), // Gold / Khaki accent
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
