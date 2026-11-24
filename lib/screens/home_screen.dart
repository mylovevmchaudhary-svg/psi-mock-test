import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/exam_category.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';
import 'bookmarks_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'refer_screen.dart';
import 'test_series_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _user = UserModel();
  final List<ExamCategory> _categories = ExamCategory.getCategories();

  Map<String, String> _socialLinks = {
    'website': 'https://gujaratpoliceprep.in',
    'whatsapp': 'https://chat.whatsapp.com/KhakhiPrep2026',
    'telegram': 'https://t.me/GujaratPolicePrep',
    'youtube': 'https://youtube.com/@GujaratPolicePrep',
    'instagram': 'https://instagram.com/gujaratpoliceprep',
  };

  @override
  void initState() {
    super.initState();
    _loadDynamicLinks();
  }

  void _loadDynamicLinks() async {
    final links = await FirebaseService().fetchSocialLinks();
    if (mounted) {
      setState(() {
        _socialLinks = links;
      });
    }
  }

  Future<void> _openUrlDirectly(String url, String title) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title લિંક ઓપન થઈ શકી નથી: $url')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D253F),
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ).then((_) => setState(() {}));
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
                ),
                child: const CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xFF1E3C72),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _user.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Color(0xFFFFC107), size: 14),
                    ],
                  ),
                  const Text(
                    'મિશન ખાખી 2026 👮‍♂️',
                    style: TextStyle(fontSize: 11, color: Color(0xFFFFC107), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Coins indicator button (navigates to wallet tab: index 3)
          InkWell(
            onTap: () => widget.onTabChange(3),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, size: 16, color: Color(0xFFFFC107)),
                  const SizedBox(width: 4),
                  ValueListenableBuilder<int>(
                    valueListenable: _user.coinsNotifier,
                    builder: (_, currentCoins, __) => Text(
                      '$currentCoins',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Notification Bell with dynamic unread counter badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
                tooltip: 'નોટિફિકેશન & પરીક્ષા એલર્ટ્સ',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  ).then((_) => setState(() {}));
                },
              ),
              if (NotificationService().unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                    child: Center(
                      child: Text(
                        '${NotificationService().unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motivational Khakhi Banner
            _buildHeroBanner(),

            const SizedBox(height: 18),

            // Quick Actions Grid (6 Tiles)
            _buildQuickActionsGrid(),

            const SizedBox(height: 20),

            // Section Header: Exam Cards (Strictly 2 Exams: Constable & PSI)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'તમારી લક્ષ્ય પરીક્ષા (Target Exams)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D253F),
                  ),
                ),
                Text(
                  '2 સત્તાવાર ભરતી',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2 Exam Cards
            ..._categories.map((cat) => _buildExamCard(cat)).toList(),

            const SizedBox(height: 16),

            // Daily Tip Box
            _buildDailyTipCard(),

            const SizedBox(height: 22),

            // Website & Social Media Communities Section
            _buildWebsiteAndSocialLinksSection(),

            const SizedBox(height: 20),

            // App Footer & Copyright
            _buildFooterCopyright(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D253F), Color(0xFF1E3C72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D253F).withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 12, color: Color(0xFF0D253F)),
                    SizedBox(width: 4),
                    Text(
                      '3 મોક ટેસ્ટ સંપૂર્ણ મફત',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D253F),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '200 MCQs • 180 મિનિટ',
                style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'PSI Mock Test 2026',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'કોન્સ્ટેબલ (LRD) અને PSI ના વાસ્તવિક ઓનલાઇન પેપર સોલ્વ કરો.',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: const Color(0xFF0D253F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 2,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text(
                  'મોક ટેસ્ટ આપો',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () => widget.onTabChange(1), // Go to Mock Tests tab
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                icon: const Icon(Icons.menu_book, size: 16),
                label: const Text('સિલેબસ', style: TextStyle(fontSize: 13)),
                onPressed: () => widget.onTabChange(2), // Go to Syllabus tab
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {
        'title': 'મોક ટેસ્ટ',
        'subtitle': '200 પ્રશ્નો',
        'icon': Icons.assignment_outlined,
        'color': const Color(0xFF1976D2),
        'onTap': () => widget.onTabChange(1),
      },
      {
        'title': 'નવો સિલેબસ',
        'subtitle': 'વિષયવાર ગુણ',
        'icon': Icons.menu_book_outlined,
        'color': const Color(0xFF2E7D32),
        'onTap': () => widget.onTabChange(2),
      },
      {
        'title': 'વૉલેટ / UPI',
        'subtitle': 'રોકડ ઉપાડ',
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFFE65100),
        'onTap': () => widget.onTabChange(3),
      },
      {
        'title': 'રેફર કરો',
        'subtitle': '+50 કોઈન્સ',
        'icon': Icons.people_outline,
        'color': const Color(0xFF6A1B9A),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReferScreen()),
          );
        },
      },
      {
        'title': 'બુકમાર્ક્સ',
        'subtitle': 'સાચવેલા પ્રશ્નો',
        'icon': Icons.bookmark_border,
        'color': const Color(0xFF00838F),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookmarksScreen()),
          );
        },
      },
      {
        'title': 'પ્રોફાઇલ',
        'subtitle': 'મારી પ્રગતિ',
        'icon': Icons.person_outline,
        'color': const Color(0xFF0D253F),
        'onTap': () => widget.onTabChange(4),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        final color = item['color'] as Color;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: item['onTap'] as VoidCallback,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: color.withOpacity(0.12),
                    child: Icon(item['icon'] as IconData, color: color, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    item['subtitle'] as String,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamCard(ExamCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestSeriesScreen(initialCategory: category),
            ),
          ).then((_) => setState(() {}));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [category.primaryColor, category.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: category.primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(category.icon, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            category.titleGujarati,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0D253F),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: category.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category.badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: category.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.quiz_outlined, size: 14, color: Color(0xFF2E7D32)),
                        SizedBox(width: 4),
                        Text(
                          '200 પ્રશ્નો • 180 મિનિટ • -0.25 ગુણ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFFF57F17)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'સત્તાવાર પરીક્ષા નિયમો: 200 ગુણ & 180 મિનિટ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF57F17)),
                ),
                SizedBox(height: 4),
                Text(
                  'ખોટા જવાબ માટે -0.25 માર્ક કપાશે. જો જવાબ ન આવડતો હોય તો વિકલ્પ "E" (પ્રયાસ કરેલ નથી) પસંદ કરો જેથી કોઈ માર્ક કપાશે નહીં.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF5D4037)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLinkDialog({
    required String title,
    required String url,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      url,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('બંધ કરો'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D253F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.copy, size: 16, color: Color(0xFFFFC107)),
            label: const Text('લિંક કોપી કરો'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF0D253F),
                  content: Text('$title ની લિંક કોપી થઈ ગઈ: $url 📋'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteAndSocialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '🌐 વેબસાઇટ & સોશિયલ મીડિયા',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D253F),
              ),
            ),
            Text(
              'સત્તાવાર લિંક્સ',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'મહત્વના પરિપત્રો, ડેઇલી મોક ટેસ્ટ સોલ્યુશન અને મટીરીયલ માટે જોડાઓ:',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        // Main Official Website Banner Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D253F), Color(0xFF1E3C72)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D253F).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.language, color: Color(0xFFFFC107), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'અધિકૃત વેબસાઇટ પોર્ટલ 🌐',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'www.gujaratpoliceprep.in',
                      style: TextStyle(fontSize: 12, color: Color(0xFFFFC107), fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ભરતી નિયમો, પરિણામો અને મોક ટેસ્ટ માહિતી',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: const Color(0xFF0D253F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  _openUrlDirectly(
                    _socialLinks['website'] ?? 'https://gujaratpoliceprep.in',
                    'અધિકૃત વેબસાઇટ',
                  );
                },
                child: const Text('ઓપન કરો ↗', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4 Social Media Communities Grid
        Row(
          children: [
            // WhatsApp Community
            Expanded(
              child: _buildSocialCard(
                title: 'WhatsApp',
                subtitle: 'સ્ટડી ગ્રુપ',
                icon: Icons.chat_bubble_outline,
                color: const Color(0xFF25D366),
                url: _socialLinks['whatsapp'] ?? 'https://chat.whatsapp.com/KhakhiPrep2026',
                description: 'રોજિંદા મહત્વપૂર્ણ પ્રશ્નો અને પરીક્ષા ચર્ચા માટે WhatsApp ગ્રુપમાં જોડાઓ.',
              ),
            ),
            const SizedBox(width: 10),
            // Telegram Channel
            Expanded(
              child: _buildSocialCard(
                title: 'Telegram',
                subtitle: 'ફ્રી PDF & GK',
                icon: Icons.send_rounded,
                color: const Color(0xFF0088CC),
                url: _socialLinks['telegram'] ?? 'https://t.me/GujaratPolicePrep',
                description: 'સંપૂર્ણ મોક ટેસ્ટ પેપર PDF અને કરંટ અફેર્સ માટે ટેલિગ્રામ ચેનલ સબ્સ્ક્રાઇબ કરો.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // YouTube Channel
            Expanded(
              child: _buildSocialCard(
                title: 'YouTube',
                subtitle: 'વિડિયો લેક્ચર્સ',
                icon: Icons.play_circle_filled,
                color: const Color(0xFFFF0000),
                url: _socialLinks['youtube'] ?? 'https://youtube.com/@GujaratPolicePrep',
                description: 'કાયદો, બંધારણ અને ગણિત-રીઝનિંગની શોર્ટ ટ્રીક્સના વિડીયો જુઓ.',
              ),
            ),
            const SizedBox(width: 10),
            // Instagram
            Expanded(
              child: _buildSocialCard(
                title: 'Instagram',
                subtitle: 'ડેઇલી ક્વિઝ',
                icon: Icons.camera_alt_outlined,
                color: const Color(0xFFE1306C),
                url: _socialLinks['instagram'] ?? 'https://instagram.com/gujaratpoliceprep',
                description: 'રોજિંદા કરંટ અફેર્સ અને GK ની શોર્ટ રીલ્સ જુઓ.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String url,
    required String description,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _openUrlDirectly(url, title);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterCopyright() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shield, color: Color(0xFFFFC107), size: 16),
              SizedBox(width: 6),
              Text(
                'PSI Mock Test • મિશન ખાખી 2026 👮‍♂️',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D253F)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'સત્યમેવ જયતે • PSI & Constable Exam Portal',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            '© 2026 PSI Mock Test Platform',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
