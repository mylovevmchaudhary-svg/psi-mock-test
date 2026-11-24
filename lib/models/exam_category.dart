import 'package:flutter/material.dart';

class ExamCategory {
  final String id;
  final String titleGujarati;
  final String titleEnglish;
  final String totalTestsCount;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String badgeText;

  const ExamCategory({
    required this.id,
    required this.titleGujarati,
    required this.titleEnglish,
    required this.totalTestsCount,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.badgeText,
  });

  /// Strictly only the 2 requested Exams (Constable & PSI)
  static List<ExamCategory> getCategories() {
    return const [
      ExamCategory(
        id: 'constable',
        titleGujarati: 'કોન્સ્ટેબલ (LRD)',
        titleEnglish: 'Constable (Lokrakshak Dal)',
        totalTestsCount: 'મોક ટેસ્ટ સીરીઝ',
        description: 'કાયદો, બંધારણ, ગુજરાતનો ઇતિહાસ, ભૂગોળ, રીઝનિંગ, વિજ્ઞાન અને વર્તમાન પ્રવાહો',
        icon: Icons.shield,
        primaryColor: Color(0xFF0D253F), // Navy Blue
        secondaryColor: Color(0xFF1E3C72),
        badgeText: 'લોકરક્ષક દળ 👮‍♂️',
      ),
      ExamCategory(
        id: 'psi',
        titleGujarati: 'પોલીસ સબ ઇન્સ્પેક્ટર (PSI & ASI)',
        titleEnglish: 'Police Sub Inspector & Assistant Sub Inspector',
        totalTestsCount: 'મોક ટેસ્ટ સીરીઝ',
        description: 'કાયદો (IPC, CrPC, પુરાવા), ગુજરાતી વ્યાકરણ, અંગ્રેજી અને સામાન્ય અભ્યાસ',
        icon: Icons.shield,
        primaryColor: Color(0xFF1B5E20), // Khakhi Green Accent
        secondaryColor: Color(0xFF2E7D32),
        badgeText: 'PSI / ASI ભરતી 🎯',
      ),
    ];
  }
}
