import 'package:flutter/material.dart';
import '../data/curated_question_bank.dart';
import '../models/exam_category.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';
import '../widgets/admob_reward_dialog.dart';
import 'quiz_screen.dart';

class TestSeriesScreen extends StatefulWidget {
  final ExamCategory? initialCategory;

  const TestSeriesScreen({super.key, this.initialCategory});

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  final _user = UserModel();
  late String _selectedExamId;

  bool _isLoadingTests = false;

  @override
  void initState() {
    super.initState();
    _selectedExamId = widget.initialCategory?.id ?? 'constable';
    _syncTestsFromFirebase();
  }

  void _syncTestsFromFirebase() async {
    setState(() => _isLoadingTests = true);
    final tests = await CuratedQuestionBank.loadAllTestsFromFirebase(examId: _selectedExamId);
    if (tests.isNotEmpty) {
      await CuratedQuestionBank.loadQuestionsFromFirebase(tests.first.id);
    }
    if (mounted) {
      setState(() => _isLoadingTests = false);
    }
  }

  void _showUnlockDialog(MockTest test, int testIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFFE65100)),
            const SizedBox(width: 8),
            Text(
              '${test.title} અનલોક કરો',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'આ મોક ટેસ્ટમાં સત્તાવાર સિલેબસ આધારિત 200 પ્રશ્નો અને 180 મિનિટ (3 કલાક) નો સમય છે.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('તમારું બેલેન્સ:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '${_user.coins} કોઈન્સ 🪙',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Option 1: Watch Ad to unlock
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D253F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.play_circle_fill, color: Color(0xFFFFC107)),
            label: const Text('વિડિઓ એડ જોઈને ફ્રી અનલોક કરો'),
            onPressed: () {
              Navigator.pop(ctx);
              _simulateWatchAd(test);
            },
          ),
          const SizedBox(height: 8),

          // Option 2: Unlock with Coins
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
            label: const Text('10 કોઈન્સ વાપરીને અનલોક કરો'),
            onPressed: () {
              if (_user.unlockWithCoins(test.id, 10)) {
                Navigator.pop(ctx);
                setState(() {});
                _startTest(test);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('તમારી પાસે પૂરતા કોઈન્સ નથી! એડ જોઈને કમાઓ.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _simulateWatchAd(MockTest test) async {
    final success = await AdMobRewardedTestAdDialog.show(
      context,
      title: 'Google AdMob Rewarded Video',
      testId: test.id,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2E7D32),
          content: Text('${test.title} સફળતાપૂર્વક અનલોક થઈ ગઈ! 🎉 (+10 બોનસ કોઈન્સ)'),
        ),
      );
      _startTest(test);
    }
  }

  void _startTest(MockTest test) async {
    if (test.questions.isEmpty) {
      // Show loading indicator while fetching questions from Firebase
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0D253F)),
                  SizedBox(height: 14),
                  Text('Firebase માંથી તમામ MCQs લોડ થઈ રહ્યા છે...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      );

      final loaded = await CuratedQuestionBank.loadQuestionsFromFirebase(test.id);
      if (mounted) Navigator.pop(context); // pop loading dialog

      if (loaded.isEmpty) {
        if (mounted) _showEmptyTestDialog(test);
        return;
      }
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen(test: test)),
      );
    }
  }

  void _showEmptyTestDialog(MockTest test) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFF1E3C72)),
            SizedBox(width: 8),
            Text('પ્રશ્નો ટૂંક સમયમાં ઉપલબ્ધ થશે', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${test.title} માટે પ્રશ્નો એડમિન દ્વારા ટૂંક સમયમાં અપડેટ કરવામાં આવશે.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_sync, size: 16, color: Color(0xFF0D253F)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ડેટાબેઝમાંથી પ્રશ્નો ઉમેરાયા પછી આપોઆપ અહીં શરૂ થશે.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF0D253F)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D253F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('સમજાયું'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tests = CuratedQuestionBank.getCuratedTests(_selectedExamId);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: const Text(
          'મોક ટેસ્ટ સીરીઝ (Mock Tests)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Color(0xFFFFC107)),
                const SizedBox(width: 4),
                ValueListenableBuilder<int>(
                  valueListenable: _user.coinsNotifier,
                  builder: (_, currentCoins, __) => Text(
                    '$currentCoins',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Exam Switcher Selector (Constable vs PSI)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildExamTab(
                    title: 'કોન્સ્ટેબલ (LRD)',
                    examId: 'constable',
                    isSelected: _selectedExamId == 'constable',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildExamTab(
                    title: 'PSI / ASI',
                    examId: 'psi',
                    isSelected: _selectedExamId == 'psi',
                  ),
                ),
              ],
            ),
          ),

          // Clean Curated Mock Test List with Pull-to-Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _syncTestsFromFirebase(),
              color: const Color(0xFF0D253F),
              child: _isLoadingTests
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF0D253F)),
                            const SizedBox(height: 16),
                            Text(
                              'Firebase માંથી મોક ટેસ્ટ લોડ થઈ રહી છે...',
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : tests.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.assignment_outlined, size: 56, color: Color(0xFF1E3C72)),
                                const SizedBox(height: 16),
                                const Text(
                                  'હજુ કોઈ મોક ટેસ્ટ ઉપલબ્ધ નથી',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'નવી મોક ટેસ્ટ ટૂંક સમયમાં Firebase ડેટાબેઝ દ્વારા ઉમેરવામાં આવશે.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        final test = tests[index];
                        final testNum = index + 1;
                        final isFree = test.isFree || testNum <= 3;
                        final isUnlocked = isFree || _user.isTestUnlocked(test.id, testNum);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 1.5,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isFree
                                            ? const Color(0xFFE8F5E9)
                                            : (isUnlocked ? const Color(0xFFE3F2FD) : const Color(0xFFFFF3E0)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isFree ? '🌟 મફત ટેસ્ટ (Free)' : (isUnlocked ? '✅ અનલોક થયેલ' : '🔒 પ્રીમિયમ'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isFree
                                              ? const Color(0xFF2E7D32)
                                              : (isUnlocked ? const Color(0xFF1565C0) : const Color(0xFFE65100)),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${test.durationMinutes} મિનિટ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  test.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D253F),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  test.description,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const Divider(height: 22),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.format_list_numbered, size: 16, color: Color(0xFF0D253F)),
                                        const SizedBox(width: 4),
                                        Text(
                                          test.questions.isNotEmpty
                                              ? '${test.questions.length} MCQs • ${test.questions.length} ગુણ'
                                              : '${test.totalQuestions} MCQs',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isUnlocked ? const Color(0xFF0D253F) : const Color(0xFFE65100),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                      ),
                                      icon: Icon(
                                        isUnlocked ? Icons.play_arrow : Icons.lock_open,
                                        size: 16,
                                      ),
                                      label: Text(
                                        isUnlocked ? 'ટેસ્ટ આપો' : 'અનલોક કરો',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        if (isUnlocked) {
                                          _startTest(test);
                                        } else {
                                          _showUnlockDialog(test, testNum);
                                        }
                                      },
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
          ),
        ],
      ),
    );
  }

  Widget _buildExamTab({
    required String title,
    required String examId,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (_selectedExamId != examId) {
          setState(() => _selectedExamId = examId);
          _syncTestsFromFirebase();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D253F) : const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
