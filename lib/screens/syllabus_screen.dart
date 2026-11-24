import 'package:flutter/material.dart';
import '../models/exam_type.dart';
import '../models/quiz_model.dart';
import '../models/syllabus_model.dart';
import '../services/firebase_service.dart';
import 'quiz_screen.dart';

class SyllabusScreen extends StatefulWidget {
  final ExamType? examType;
  final List<SyllabusSubject>? subjects;
  final String? initialSubjectFilter;

  const SyllabusScreen({
    super.key,
    this.examType,
    this.subjects,
    this.initialSubjectFilter,
  });

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  late ExamType _selectedExam;
  List<SyllabusSubject> _currentSubjects = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedExam = widget.examType ?? ExamType.constable;
    if (widget.subjects != null) {
      _currentSubjects = widget.subjects!;
      _isLoading = false;
    } else {
      _loadSyllabusFromFirebase();
    }
  }

  void _loadSyllabusFromFirebase() async {
    setState(() => _isLoading = true);
    final examStr = _selectedExam == ExamType.psi ? 'psi' : 'constable';
    final liveSubjects = await FirebaseService().fetchSyllabusWithTopics(examId: examStr);
    if (mounted) {
      setState(() {
        _currentSubjects = liveSubjects;
        _isLoading = false;
      });
    }
  }

  void _onExamChanged(ExamType newExam) {
    setState(() {
      _selectedExam = newExam;
    });
    _loadSyllabusFromFirebase();
  }

  void _startTopicPractice(SyllabusTopic topic) async {
    // Show quick loading indicator
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
                Text('ટોપિક આધારિત પ્રશ્નો લોડ થઈ રહ્યા છે...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    final matchingQuestions =
        await FirebaseService().fetchQuestionsForTopic(topic.id, topic.nameGujarati);

    if (mounted) Navigator.pop(context); // pop loading

    if (matchingQuestions.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.menu_book, color: Color(0xFF0D253F)),
              SizedBox(width: 8),
              Text('પ્રેક્ટિસ પ્રશ્નો', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            '${topic.nameGujarati} માટેના MCQ પ્રશ્નો એડમિન દ્વારા ટૂંક સમયમાં અપલોડ કરવામાં આવશે. પ્રશ્નો ઉમેરાયા પછી આપ અહીં પ્રેક્ટિસ કરી શકશો.',
            style: const TextStyle(fontSize: 13),
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
      return;
    }

    final baseTest = MockTest(
      id: 'practice_${topic.id}',
      title: '${topic.nameGujarati} - પ્રેક્ટિસ',
      description: 'ટોપિક આધારિત મોક ટેસ્ટ',
      category: 'Practice',
      durationMinutes: (matchingQuestions.length * 1.5).ceil().clamp(15, 120),
      questions: matchingQuestions,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen(test: baseTest)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = _currentSubjects.where((subject) {
      if (widget.initialSubjectFilter != null) {
        if (!subject.id.contains(widget.initialSubjectFilter!)) {
          return false;
        }
      }
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final matchSubject = subject.title.toLowerCase().contains(query) ||
          subject.titleGujarati.toLowerCase().contains(query);
      final matchTopics = subject.topics.any((t) =>
          t.name.toLowerCase().contains(query) ||
          t.nameGujarati.toLowerCase().contains(query));
      return matchSubject || matchTopics;
    }).toList();

    int totalMCQsInSyllabus = 0;
    for (var sub in _currentSubjects) {
      totalMCQsInSyllabus += sub.mcqCount;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'સત્તાવાર અભ્યાસક્રમ (Syllabus & MCQs)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            Text(
              '${_selectedExam.badgeText} • કુલ $totalMCQsInSyllabus+ પ્રશ્નો બેંક',
              style: const TextStyle(fontSize: 11, color: Color(0xFFFFC107)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Exam Switcher Selector (Constable vs PSI)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildSelectorTab(
                    title: 'કોન્સ્ટેબલ (LRD)',
                    exam: ExamType.constable,
                    isSelected: _selectedExam == ExamType.constable,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSelectorTab(
                    title: 'PSI / ASI',
                    exam: ExamType.psi,
                    isSelected: _selectedExam == ExamType.psi,
                  ),
                ),
              ],
            ),
          ),

          // Total MCQ Bank Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D253F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_stories, color: Color(0xFFFFC107), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'વિષયવાર પ્રશ્નોની ગણતરી (MCQ Count):',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$totalMCQsInSyllabus MCQs',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0D253F)),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            color: const Color(0xFFF4F6F9),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ટોપિક કે વિષય શોધો (દા.ત. બંધારણ, IPC, ભૂગોળ)...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D253F)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Subject List with Topic & MCQ Counts with Pull-to-Refresh
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF0D253F)),
                        SizedBox(height: 16),
                        Text(
                          'Firebase માંથી સિલેબસ અને ટોપિક્સ લોડ થઈ રહ્યા છે...',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _loadSyllabusFromFirebase(),
                    color: const Color(0xFF0D253F),
                    child: filteredSubjects.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'કોઈ વિષય કે ટોપિક મળ્યો નથી.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: filteredSubjects.length,
                            itemBuilder: (context, index) {
                              final subject = filteredSubjects[index];
                              return _buildSubjectCard(subject);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTab({
    required String title,
    required ExamType exam,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onExamChanged(exam),
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

  Widget _buildSubjectCard(SyllabusSubject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0D253F).withOpacity(0.08),
          child: const Icon(Icons.menu_book, color: Color(0xFF0D253F)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                subject.titleGujarati,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0D253F),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.4)),
              ),
              child: Text(
                '${subject.mcqCount} MCQs',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${subject.title} • ભારાંક: ${subject.totalMarksWeightage} ગુણ • ${subject.topics.length} ટોપિક્સ',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        children: subject.topics.map((topic) => _buildTopicTile(topic)).toList(),
      ),
    );
  }

  Widget _buildTopicTile(SyllabusTopic topic) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF0D253F)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  topic.nameGujarati,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D253F)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${topic.mcqCount} પ્રશ્નો',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                ),
              ),
            ],
          ),
          if (topic.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'મુદ્દા: ${topic.keyPoints.join(" • ")}',
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topic.name,
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey[500]),
                ),
                InkWell(
                  onTap: () => _startTopicPractice(topic),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D253F),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.play_arrow, size: 12, color: Color(0xFFFFC107)),
                        SizedBox(width: 2),
                        Text(
                          'પ્રેક્ટિસ કરો',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
