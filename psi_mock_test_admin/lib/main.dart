import 'package:flutter/material.dart';
import 'screens/admin_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PsiMockTestAdminApp());
}

class PsiMockTestAdminApp extends StatelessWidget {
  const PsiMockTestAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSI Mock Test Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0D253F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D253F),
          primary: const Color(0xFF0D253F),
          secondary: const Color(0xFFFFC107),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D253F),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AdminLoginScreen(), // Secured with Admin Email and Password
    );
  }
}
