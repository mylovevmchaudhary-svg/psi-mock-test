import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'bookmarks_screen.dart';
import 'login_screen.dart';
import 'refer_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _user = UserModel();
  bool _notificationsEnabled = true;

  void _logout() {
    _user.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: const Text(
          'મારી પ્રોફાઇલ (Student Profile)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Student Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D253F),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFC107), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFF2A4D7E),
                          child: Icon(Icons.person, size: 44, color: Colors.white),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 13,
                        backgroundColor: Color(0xFFFFC107),
                        child: Icon(Icons.verified, size: 16, color: Color(0xFF0D253F)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _user.email,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PSI Mock Test - Constable & PSI Series',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('ટેસ્ટ આપેલ', '${_user.testsTaken}'),
                        _buildDivider(),
                        _buildStatColumn('સરેરાશ સ્કોર', _user.testsTaken > 0 ? '${(_user.totalCorrectAnswers / _user.testsTaken).round()}/200' : '0/200'),
                        _buildDivider(),
                        _buildStatColumn('સ્ટ્રીક 🔥', '${_user.streakDays} દિવસ'),
                        _buildDivider(),
                        ValueListenableBuilder<int>(
                          valueListenable: _user.coinsNotifier,
                          builder: (_, currentCoins, __) => _buildStatColumn('કોઈન્સ 🪙', '$currentCoins'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings & Options List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Refer & Earn Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: const Color(0xFFFFF8E1),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReferScreen()),
                        );
                      },
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFC107),
                        child: Icon(Icons.people, color: Color(0xFF0D253F), size: 22),
                      ),
                      title: const Text('👥 મિત્રોને રેફર કરો & ₹૫૦ કમાઓ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('તમારો કોડ: ${_user.myReferralCode}', style: const TextStyle(fontSize: 12, color: Color(0xFFF57F17), fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFF57F17)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildMenuCard(
                    icon: Icons.bookmark_outline,
                    color: const Color(0xFF1976D2),
                    title: 'સાચવેલા પ્રશ્નો (Bookmarked MCQs)',
                    subtitle: 'તમારા મનપસંદ પ્રશ્નોનું પુનરાવર્તન કરો',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchCard(
                    icon: Icons.notifications_active_outlined,
                    color: const Color(0xFF2E7D32),
                    title: 'પરીક્ષા નોટિફિકેશન',
                    subtitle: 'ડેઇલી ક્વિઝ અને એક્ઝામ અપડેટ્સ',
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                    },
                  ),
                  const SizedBox(height: 10),

                  _buildMenuCard(
                    icon: Icons.info_outline,
                    color: Colors.grey[700]!,
                    title: 'એપ વિશે અને વર્ઝન',
                    subtitle: 'PSI Mock Test Series v1.0.0 (2026)',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'PSI Mock Test',
                        applicationVersion: '1.0.0 (Firebase Edition)',
                        applicationLegalese: '© 2026 PSI Mock Test Platform',
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Logout Button
                  Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      onTap: _logout,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFEBEE),
                        child: Icon(Icons.logout, color: Colors.red, size: 20),
                      ),
                      title: const Text('લૉગ આઉટ (Log Out)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      subtitle: const Text('તમારા ખાતામાંથી બહાર નીકળો', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 20, width: 1, color: Colors.white24);
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        activeColor: const Color(0xFF0D253F),
      ),
    );
  }
}
