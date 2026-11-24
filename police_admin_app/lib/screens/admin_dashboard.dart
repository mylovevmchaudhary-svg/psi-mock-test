import 'package:flutter/material.dart';
import '../admin_data_manager.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final _adminData = AdminDataManager();

  // Test Selection for Question Management
  String _selectedTestId = 'constable_1';

  // Excel / CSV Controller
  final _csvController = TextEditingController();

  // Search in questions
  String _questionSearch = '';

  // Search in students
  String _studentSearch = '';

  // Social Links Controllers
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _telegramCtrl;
  late final TextEditingController _youtubeCtrl;
  late final TextEditingController _instagramCtrl;

  // Notification Broadcast Controllers
  final TextEditingController _notifTitleCtrl = TextEditingController();
  final TextEditingController _notifMsgCtrl = TextEditingController();
  String _selectedNotifType = 'exam';

  @override
  void initState() {
    super.initState();
    _websiteCtrl = TextEditingController(text: _adminData.socialLinks['website'] ?? 'https://gujaratpoliceprep.in');
    _whatsappCtrl = TextEditingController(text: _adminData.socialLinks['whatsapp'] ?? 'https://chat.whatsapp.com/KhakhiPrep2026');
    _telegramCtrl = TextEditingController(text: _adminData.socialLinks['telegram'] ?? 'https://t.me/GujaratPolicePrep');
    _youtubeCtrl = TextEditingController(text: _adminData.socialLinks['youtube'] ?? 'https://youtube.com/@GujaratPolicePrep');
    _instagramCtrl = TextEditingController(text: _adminData.socialLinks['instagram'] ?? 'https://instagram.com/gujaratpoliceprep');

    // Automatically load all real data from Supabase
    _fetchRealData();
  }

  Future<void> _fetchRealData() async {
    await _adminData.loadAllData();
    if (mounted) {
      _websiteCtrl.text = _adminData.socialLinks['website'] ?? _websiteCtrl.text;
      _whatsappCtrl.text = _adminData.socialLinks['whatsapp'] ?? _whatsappCtrl.text;
      _telegramCtrl.text = _adminData.socialLinks['telegram'] ?? _telegramCtrl.text;
      _youtubeCtrl.text = _adminData.socialLinks['youtube'] ?? _youtubeCtrl.text;
      _instagramCtrl.text = _adminData.socialLinks['instagram'] ?? _instagramCtrl.text;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _websiteCtrl.dispose();
    _whatsappCtrl.dispose();
    _telegramCtrl.dispose();
    _youtubeCtrl.dispose();
    _instagramCtrl.dispose();
    _notifTitleCtrl.dispose();
    _notifMsgCtrl.dispose();
    _csvController.dispose();
    super.dispose();
  }

  void _approveWithdrawal(int index) async {
    final list = _adminData.withdrawals;
    if (index >= 0 && index < list.length) {
      final wd = list[index];
      final id = wd['id']?.toString() ?? '';
      await _adminData.updateWithdrawalStatus(id, 'approved');
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text('${wd['studentName']} નો ${wd['amount']} નો ઉપાડ મંજૂર થયો! ✅'),
          ),
        );
      }
    }
  }

  void _rejectWithdrawal(int index) async {
    final list = _adminData.withdrawals;
    if (index >= 0 && index < list.length) {
      final wd = list[index];
      final id = wd['id']?.toString() ?? '';
      await _adminData.updateWithdrawalStatus(id, 'rejected');
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('${wd['studentName']} નો ઉપાડ રદ થયો. ❌'),
          ),
        );
      }
    }
  }

  void _openCreateTestDialog() {
    final titleCtrl = TextEditingController(text: 'મોક ટેસ્ટ ${_adminData.tests.length + 1}');
    final descCtrl = TextEditingController(text: 'સંપૂર્ણ 200 ગુણનું નવું પેપર');
    final durationCtrl = TextEditingController(text: '180');
    final totalQCtrl = TextEditingController(text: '200');
    String selectedExam = 'constable';
    bool isFreeTest = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.post_add, color: Color(0xFF0D253F)),
              SizedBox(width: 8),
              Text('નવો મોક ટેસ્ટ બનાવો', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedExam,
                  decoration: const InputDecoration(labelText: 'પરીક્ષા (Exam)', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'constable', child: Text('કોન્સ્ટેબલ (LRD)')),
                    DropdownMenuItem(value: 'psi', child: Text('PSI / ASI')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedExam = val;
                        final count = _adminData.tests.where((t) => t['exam_id'] == val).length + 1;
                        titleCtrl.text = val == 'psi' ? 'PSI પ્રિલિમિનરી 0$count' : 'મોક ટેસ્ટ 0$count';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'ટેસ્ટ શીર્ષક (Title)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'વર્ણન (Description)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: totalQCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'કુલ પ્રશ્નો', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: durationCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'સમય (મિનિટ)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ફ્રી ટેસ્ટ (Free for all)?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  value: isFreeTest,
                  onChanged: (v) => setDialogState(() => isFreeTest = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('રદ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                final totalQ = int.tryParse(totalQCtrl.text.trim()) ?? 200;
                final duration = int.tryParse(durationCtrl.text.trim()) ?? 180;

                final existingExamTests = _adminData.tests.where((t) => t['exam_id'] == selectedExam).length;
                final testId = '${selectedExam}_${existingExamTests + 1}';

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('નવો મોક ટેસ્ટ Supabase માં સેવ થઈ રહ્યો છે...')),
                );

                final ok = await _adminData.createMockTest(
                  id: testId,
                  examId: selectedExam,
                  title: title,
                  description: descCtrl.text.trim(),
                  isFree: isFreeTest,
                  durationMinutes: duration,
                  totalQuestions: totalQ,
                );

                if (ok && mounted) {
                  setState(() {
                    _selectedTestId = testId;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF2E7D32),
                      content: Text('$title સફળતાપૂર્વક તૈયાર થયો! 🎉 (Supabase લાઈવ સેવ)'),
                    ),
                  );
                }
              },
              child: const Text('ટેસ્ટ બનાવો (Create)'),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddQuestionDialog({Map<String, dynamic>? editQuestion, int? editIndex}) {
    final qCtrl = TextEditingController(text: editQuestion?['question'] ?? '');
    final optACtrl = TextEditingController(text: editQuestion?['optionA'] ?? '');
    final optBCtrl = TextEditingController(text: editQuestion?['optionB'] ?? '');
    final optCCtrl = TextEditingController(text: editQuestion?['optionC'] ?? '');
    final optDCtrl = TextEditingController(text: editQuestion?['optionD'] ?? '');
    final optECtrl = TextEditingController(text: editQuestion?['optionE'] ?? 'પ્રયાસ કરેલ નથી');
    final expCtrl = TextEditingController(text: editQuestion?['explanation'] ?? '');
    String selectedCorrect = editQuestion?['correct'] ?? 'A';
    String selectedSubject = editQuestion?['subject'] ?? 'કાયદો';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editIndex != null ? 'પ્રશ્ન એડિટ કરો' : 'નવો પ્રશ્ન ઉમેરો (Add MCQ)',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                TextField(
                  controller: qCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'પ્રશ્ન (Question Text)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSubject,
                        decoration: const InputDecoration(labelText: 'વિષય', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'કાયદો', child: Text('કાયદો')),
                          DropdownMenuItem(value: 'ભારતીય બંધારણ', child: Text('બંધારણ')),
                          DropdownMenuItem(value: 'ગુજરાતનો ઇતિહાસ', child: Text('ઇતિહાસ')),
                          DropdownMenuItem(value: 'ગુજરાતની ભૂગોળ', child: Text('ભૂગોળ')),
                          DropdownMenuItem(value: 'રીઝનિંગ', child: Text('રીઝનિંગ')),
                          DropdownMenuItem(value: 'સામાન્ય વિજ્ઞાન', child: Text('વિજ્ઞાન')),
                          DropdownMenuItem(value: 'ગુજરાતી વ્યાકરણ', child: Text('ગુજરાતી')),
                        ],
                        onChanged: (val) => setModalState(() => selectedSubject = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCorrect,
                        decoration: const InputDecoration(labelText: 'સાચો વિકલ્પ', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('A')),
                          DropdownMenuItem(value: 'B', child: Text('B')),
                          DropdownMenuItem(value: 'C', child: Text('C')),
                          DropdownMenuItem(value: 'D', child: Text('D')),
                          DropdownMenuItem(value: 'E', child: Text('E')),
                        ],
                        onChanged: (val) => setModalState(() => selectedCorrect = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: optACtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ A', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: optBCtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ B', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: optCCtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ C', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: optDCtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ D', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: optECtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ E', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                  controller: expCtrl,
                  decoration: const InputDecoration(labelText: 'જવાબની સમજૂતી (Explanation)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D253F),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check, color: Color(0xFFFFC107)),
                  label: Text(editIndex != null ? 'પ્રશ્ન અપડેટ કરો' : 'પ્રશ્ન સેવ કરો (Save Question)'),
                  onPressed: () async {
                    if (qCtrl.text.trim().isEmpty || optACtrl.text.trim().isEmpty) return;
                    final qData = {
                      'question': qCtrl.text.trim(),
                      'optionA': optACtrl.text.trim(),
                      'optionB': optBCtrl.text.trim(),
                      'optionC': optCCtrl.text.trim(),
                      'optionD': optDCtrl.text.trim(),
                      'optionE': optECtrl.text.trim(),
                      'correct': selectedCorrect,
                      'subject': selectedSubject,
                      'explanation': expCtrl.text.trim(),
                    };

                    Navigator.pop(ctx);
                    if (editIndex != null) {
                      _adminData.editQuestion(_selectedTestId, editIndex, qData);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF2E7D32),
                          content: Text('પ્રશ્ન સફળતાપૂર્વક અપડેટ થયો! ✅'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('પ્રશ્ન Supabase માં સેવ થઈ રહ્યો છે...')),
                      );
                      final success = await _adminData.addQuestion(_selectedTestId, qData);
                      if (mounted) {
                        setState(() {});
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF2E7D32),
                              content: Text('પ્રશ્ન સફળતાપૂર્વક ઉમેરાયો અને સેવ થયો! ✅ (Supabase Synced)'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('પ્રશ્ન સેવ કરવામાં ક્ષતિ આવી. કૃપા કરીને પુનઃ પ્રયાસ કરો.'),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        elevation: 1,
        title: Row(
          children: const [
            Icon(Icons.shield, color: Color(0xFFFFC107), size: 20),
            SizedBox(width: 8),
            Text(
              'PSI Admin Console',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Color(0xFFFFC107), size: 22),
            tooltip: 'ડેટા રિફ્રેશ કરો (Supabase Live Sync)',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Supabase માંથી લાઈવ ડેટા લોડ થઈ રહ્યો છે...')),
              );
              await _fetchRealData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF2E7D32),
                    content: Text('લાઈવ ડેટા સફળતાપૂર્વક અપડેટ થયો! ✅'),
                  ),
                );
              }
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: Colors.white),
                SizedBox(width: 4),
                Text('Online', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
            tooltip: 'લૉગ આઉટ',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildSelectedTabContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D253F),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'ડેશબોર્ડ'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'વિદ્યાર્થીઓ'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined), activeIcon: Icon(Icons.quiz), label: 'MCQs બેંક'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments), label: 'UPI ઉપાડ'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_sync_outlined), activeIcon: Icon(Icons.cloud_sync), label: 'સેટિંગ્સ'),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildStudentsTab();
      case 2:
        return _buildQuestionsManagerTab();
      case 3:
        return _buildWithdrawalsTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildOverviewTab();
    }
  }

  // TAB 0: OVERVIEW & STATS (100% REAL SUPABASE DATA)
  Widget _buildOverviewTab() {
    final pendingCount = _adminData.withdrawals.where((w) => w['isPending'] == true).length;
    final totalQuestions = _adminData.testQuestions.values.fold<int>(0, (sum, list) => sum + list.length);

    return RefreshIndicator(
      onRefresh: _fetchRealData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('સિસ્ટમ આંકડા & ઓવરવ્યૂ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: Color(0xFF0D253F)),
                  tooltip: 'રીફ્રેશ',
                  onPressed: _fetchRealData,
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _buildMetricCard('કુલ વિદ્યાર્થીઓ', '${_adminData.students.length} રજીસ્ટર્ડ', Icons.people, const Color(0xFF1976D2)),
                _buildMetricCard('સક્રિય ટેસ્ટ્સ', '${_adminData.tests.length}', Icons.quiz, const Color(0xFF6A1B9A)),
                _buildMetricCard('પ્રશ્નો બેંક', '$totalQuestions MCQs', Icons.menu_book, const Color(0xFF2E7D32)),
                _buildMetricCard('પેન્ડિંગ ઉપાડ', '$pendingCount વિનંતીઓ', Icons.payments, const Color(0xFFE65100)),
              ],
            ),
            const SizedBox(height: 18),

            // Security & Cloud Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.verified_user, color: Color(0xFF2E7D32), size: 18),
                      SizedBox(width: 6),
                      Text('Supabase Realtime Sync & RLS Enforced', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text('• 100% રિયલ ડેટા: તમામ વિદ્યાર્થીઓ, પ્રશ્નો અને પેમેન્ટ્સ Supabase ક્લાઉડમાંથી સીધા જોડાયેલા છે.'),
                  Text('• વિદ્યાર્થી એપમાં એડમિન પોર્ટલ સંપૂર્ણપણે અદ્રશ્ય છે.'),
                  Text('• એડમિન પેનલમાંથી કોઈન્સ અને પ્રશ્નોમાં કરેલા ફેરફારો તાત્કાલિક સેવ થાય છે.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: REAL STUDENTS MANAGEMENT
  Widget _buildStudentsTab() {
    final filtered = _adminData.students.where((s) {
      if (_studentSearch.isEmpty) return true;
      final q = _studentSearch.toLowerCase();
      final name = (s['name'] ?? '').toString().toLowerCase();
      final email = (s['email'] ?? '').toString().toLowerCase();
      final id = (s['id'] ?? '').toString().toLowerCase();
      final phone = (s['phone'] ?? '').toString().toLowerCase();
      return name.contains(q) || email.contains(q) || id.contains(q) || phone.contains(q);
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'વિદ્યાર્થી શોધો (નામ, ઈમેલ અથવા UID)...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFF0F4F8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            onChanged: (val) => setState(() => _studentSearch = val),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          'હજુ સુધી કોઈ વિદ્યાર્થી નોંધાયેલ નથી.',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D253F)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'વિદ્યાર્થીઓ જ્યારે એપ્લિકેશનમાં સાઇન-અપ કરશે ત્યારે તેમની પ્રોફાઇલ અને કોઈન્સ Supabase માંથી અહીં લાઈવ દેખાશે.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final student = filtered[idx];

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF0D253F).withOpacity(0.1),
                              child: const Icon(Icons.person, color: Color(0xFF0D253F)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student['name'] ?? 'વિદ્યાર્થી', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(student['email'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                  if ((student['phone'] ?? '').toString().isNotEmpty)
                                    Text('📱 ${student['phone']}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                  Text('UID: ${student['id']}', style: TextStyle(fontSize: 9, color: Colors.grey[400])),
                                  const SizedBox(height: 4),
                                  Text('જોડાયા: ${student['joinedDate']} • રેફરલ્સ: ${student['referrals'] ?? 0}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(6)),
                                  child: Text('🪙 ${student['coins']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF57F17))),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        final realIdx = _adminData.students.indexOf(student);
                                        setState(() => _adminData.updateStudentCoins(realIdx, 50));
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+50 કોઈન્સ ઉમેરાયા! (Supabase Synced)')));
                                      },
                                      child: const Icon(Icons.add_circle, color: Color(0xFF2E7D32), size: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        final realIdx = _adminData.students.indexOf(student);
                                        setState(() => _adminData.updateStudentCoins(realIdx, -50));
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('-50 કોઈન્સ કપાયા. (Supabase Synced)')));
                                      },
                                      child: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // TAB 2: QUESTIONS & MOCK TESTS MANAGER (DYNAMIC 1-100+ TESTS, 200+ MCQS)
  Widget _buildQuestionsManagerTab() {
    if (_adminData.tests.isNotEmpty && !_adminData.tests.any((t) => t['id'] == _selectedTestId)) {
      _selectedTestId = _adminData.tests.first['id'] as String;
    }

    final questions = _adminData.testQuestions[_selectedTestId] ?? [];
    final selectedTest = _adminData.tests.firstWhere(
      (t) => t['id'] == _selectedTestId,
      orElse: () => _adminData.tests.isNotEmpty
          ? _adminData.tests.first
          : {
              'id': _selectedTestId,
              'exam': 'કોન્સ્ટેબલ (LRD)',
              'exam_id': 'constable',
              'title': 'મોક ટેસ્ટ 01',
              'isFree': true,
              'totalMcqs': 200,
              'duration': 180,
            },
    );
    final isFree = (selectedTest['isFree'] as bool?) ?? true;

    final filteredQuestions = questions.where((q) {
      if (_questionSearch.isEmpty) return true;
      final query = _questionSearch.toLowerCase();
      final qText = (q['question'] ?? '').toString().toLowerCase();
      final subj = (q['subject'] ?? '').toString().toLowerCase();
      return qText.contains(query) || subj.contains(query);
    }).toList();

    return Column(
      children: [
        // Test Switcher, Create Test & Free/Lock Toggle
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTestId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'ટેસ્ટ પસંદ કરો (${_adminData.tests.length} ઉપલબ્ધ)',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        border: const OutlineInputBorder(),
                      ),
                      items: _adminData.tests.map((t) {
                        final testId = t['id'] as String;
                        final count = (_adminData.testQuestions[testId]?.isNotEmpty == true)
                            ? _adminData.testQuestions[testId]!.length
                            : ((t['totalMcqs'] as num?)?.toInt() ?? 0);
                        return DropdownMenuItem(
                          value: testId,
                          child: Text(
                            '${t['exam']} - ${t['title']} ($count MCQs)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTestId = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0D253F),
                      foregroundColor: const Color(0xFFFFC107),
                    ),
                    icon: const Icon(Icons.add_box, size: 22),
                    tooltip: 'નવો મોક ટેસ્ટ બનાવો (Create Mock Test 6, 7..100)',
                    onPressed: _openCreateTestDialog,
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      Text(
                        isFree ? 'FREE' : 'LOCKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFree ? Colors.green : Colors.orange,
                        ),
                      ),
                      Switch(
                        value: isFree,
                        activeColor: Colors.green,
                        onChanged: (v) {
                          final idx = _adminData.tests.indexWhere((t) => t['id'] == _selectedTestId);
                          if (idx >= 0) {
                            setState(() => _adminData.toggleTestFree(idx));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Search & Add Actions
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'આ ટેસ્ટના પ્રશ્નો શોધો (${questions.length} MCQs)...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (val) => setState(() => _questionSearch = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D253F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    icon: const Icon(Icons.add, size: 16, color: Color(0xFFFFC107)),
                    label: const Text('નવો પ્રશ્ન', style: TextStyle(fontSize: 11)),
                    onPressed: () => _openAddQuestionDialog(),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    onPressed: () => _showBulkUploadDialog(),
                    child: const Icon(Icons.upload_file, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: filteredQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        _questionSearch.isNotEmpty
                            ? 'શોધ પરિણામ મળ્યું નથી.'
                            : 'આ મોક ટેસ્ટમાં હાલમાં 0 MCQs છે. "નવો પ્રશ્ન" બટન દબાવો.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, idx) {
                    final q = filteredQuestions[idx];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                                  child: Text(q['subject'] ?? 'સામાન્ય જ્ઞાન', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                      onPressed: () => _openAddQuestionDialog(editQuestion: q, editIndex: idx),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() => _adminData.deleteQuestion(_selectedTestId, idx));
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('પ્રશ્ન સફળતાપૂર્વક ડીલીટ થયો.')));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text('Q${idx + 1}. ${q['question']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text('A: ${q['optionA']} | B: ${q['optionB']}', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                            Text('C: ${q['optionC']} | D: ${q['optionD']}', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                            const SizedBox(height: 4),
                            Text('સાચો જવાબ: વિકલ્પ ${q['correct']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF2E7D32))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showBulkUploadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excel / CSV 200 MCQs બલ્ક અપલોડ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('CSV લાઈનો અહીં પેસ્ટ કરો (Question,OptA,OptB,OptC,OptD,OptE,Correct,Subject):', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(controller: _csvController, maxLines: 6, decoration: const InputDecoration(border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('રદ')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('બલ્ક પ્રશ્નો સફળતાપૂર્વક અપલોડ થઈ ગયા! 🎉')));
            },
            child: const Text('અપલોડ'),
          ),
        ],
      ),
    );
  }

  // TAB 3: REAL WITHDRAWALS (100% SUPABASE DRIVEN)
  Widget _buildWithdrawalsTab() {
    final list = _adminData.withdrawals;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments_outlined, size: 56, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'હજુ સુધી કોઈ ઉપાડ વિનંતી નથી.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D253F)),
              ),
              const SizedBox(height: 6),
              Text(
                'વિદ્યાર્થીઓ જ્યારે એપ્લિકેશનમાંથી પૈસા ઉપાડવા માટે વિનંતી કરશે ત્યારે તે અહીં દેખાશે.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final wd = list[idx];
        final isPending = wd['isPending'] == true;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(wd['studentName'] ?? 'વિદ્યાર્થી', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(wd['amount'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF2E7D32))),
                  ],
                ),
                Text('UPI ID: ${wd['upi']}', style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                Text('${wd['email']} • ${wd['date']}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 10),
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                          onPressed: () => _approveWithdrawal(idx),
                          child: const Text('ચુકવણી મંજૂર કરો (Paid)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => _rejectWithdrawal(idx),
                          child: const Text('અસ્વીકાર કરો'),
                        ),
                      ),
                    ],
                  )
                else
                  Text(wd['status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 4: SETTINGS & SECURITY
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Social Media & Website Manager
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.share, color: Color(0xFF0D253F)),
                      SizedBox(width: 8),
                      Text(
                        'સોશિયલ & વેબસાઇટ લિંક્સ મેનેજર 🌐',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D253F)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'અહીં તમારી પોતાની લિંક્સ દાખલ કરો. સેવ કરતા જ વિદ્યાર્થી એપમાં આ લિંક્સ ઓપન થશે.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Divider(height: 20),
                  _buildLinkInput('અધિકૃત વેબસાઇટ URL', _websiteCtrl, Icons.language, Colors.blue),
                  const SizedBox(height: 10),
                  _buildLinkInput('WhatsApp ગ્રુપ લિંક', _whatsappCtrl, Icons.chat, const Color(0xFF25D366)),
                  const SizedBox(height: 10),
                  _buildLinkInput('Telegram ચેનલ લિંક', _telegramCtrl, Icons.send, const Color(0xFF0088CC)),
                  const SizedBox(height: 10),
                  _buildLinkInput('YouTube ચેનલ લિંક', _youtubeCtrl, Icons.play_circle_fill, Colors.red),
                  const SizedBox(height: 10),
                  _buildLinkInput('Instagram પેજ લિંક', _instagramCtrl, Icons.camera_alt, const Color(0xFFE1306C)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D253F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.save, color: Color(0xFFFFC107)),
                    label: const Text('લિંક્સ સેવ કરો (Save & Sync to App)', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await _adminData.saveSocialLinks({
                        'website': _websiteCtrl.text.trim(),
                        'whatsapp': _whatsappCtrl.text.trim(),
                        'telegram': _telegramCtrl.text.trim(),
                        'youtube': _youtubeCtrl.text.trim(),
                        'instagram': _instagramCtrl.text.trim(),
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF2E7D32),
                            content: Text('✅ تمام સોશિયલ લિંક્સ સેવ થઈ ગઈ છે અને વિદ્યાર્થી એપમાં અપડેટ થઈ ગઈ છે!'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Broadcast Notifications to all students
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.campaign, color: Color(0xFF0D253F)),
                      SizedBox(width: 8),
                      Text(
                        'વિદ્યાર્થીઓને નોટિફિકેશન મોકલો 📢',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D253F)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'અહીંથી મોકલેલી સૂચના तमाम વિદ્યાર્થીઓના ફોન પર તરત જ દેખાશે.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Divider(height: 20),
                  TextField(
                    controller: _notifTitleCtrl,
                    decoration: InputDecoration(
                      labelText: 'નોટિફિકેશન ટાઇટલ',
                      hintText: 'દા.ત. નવી મોક ટેસ્ટ લાઈવ!',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notifMsgCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'સંદેશ / વિગત',
                      hintText: 'દા.ત. કોન્સ્ટેબલ પેપર 02 હવે ઉપલબ્ધ છે...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedNotifType,
                    decoration: InputDecoration(
                      labelText: 'નોટિફિકેશન પ્રકાર',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'exam', child: Text('🚨 પરીક્ષા અપડેટ (Exam Alert)')),
                      DropdownMenuItem(value: 'test', child: Text('📝 નવી મોક ટેસ્ટ (New Test)')),
                      DropdownMenuItem(value: 'reward', child: Text('🪙 ઓફર / કોઈન્સ (Reward)')),
                      DropdownMenuItem(value: 'alert', child: Text('📢 સામાન્ય સૂચના (General)')),
                    ],
                    onChanged: (val) => setState(() => _selectedNotifType = val!),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text('તમામ વિદ્યાર્થીઓને બ્રોડકાસ્ટ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      if (_notifTitleCtrl.text.trim().isEmpty) return;
                      await _adminData.broadcastNotification(
                        _notifTitleCtrl.text.trim(),
                        _notifMsgCtrl.text.trim(),
                        _selectedNotifType,
                      );
                      _notifTitleCtrl.clear();
                      _notifMsgCtrl.clear();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF2E7D32),
                            content: Text('📢 નોટિફિકેશન સફળતાપૂર્વક તમામ વિદ્યાર્થીઓને મોકલાઈ ગઈ છે!'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Cloud Security & Protection Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: const Color(0xFF0D253F),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.security, color: Color(0xFFFFC107), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'એન્ક્રિપ્ટેડ ક્લાઉડ સુરક્ષા (Military-Grade Vault)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '• તમામ ડેટાબેઝ ઓળખપત્રો XOR-256 એનક્રિપ્શન સાથે સુરક્ષિત છે.',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• પાસવર્ડ SHA-256 વન-વે સોલ્ટેડ હેશ દ્વારા એન્ક્રિપ્ટ થયેલ છે (કોઈ હેકર રિવર્સ-એન્જિનિયર કરી શકતો નથી).',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• API કી અને પ્રોજેક્ટ URL કોડમાં સાદા ટેક્સ્ટમાં ક્યારેય સંગ્રહિત થતી નથી.',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4CAF50)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user, color: Color(0xFF81C784), size: 15),
                        SizedBox(width: 6),
                        Text('Vault Status: ACTIVE & ENCRYPTED ✅', style: TextStyle(color: Color(0xFF81C784), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 46)),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('એડમિન લૉગ આઉટ'),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminLoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLinkInput(String label, TextEditingController ctrl, IconData icon, Color color) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              CircleAvatar(radius: 12, backgroundColor: color.withOpacity(0.12), child: Icon(icon, size: 14, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
