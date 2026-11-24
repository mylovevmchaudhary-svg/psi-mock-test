import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PsiMockTestApp());
}

class PsiMockTestApp extends StatelessWidget {
  const PsiMockTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSI Mock Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D253F), // PSI Mock Test Navy Blue
          primary: const Color(0xFF0D253F),
          secondary: const Color(0xFFFFC107), // Gold accent
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
