import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final QuizAttemptResult result;

  const QuizResultScreen({super.key, required this.result});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  String _solutionFilter = 'All'; // 'All', 'Incorrect', 'Correct'

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final test = result.test;

    final filteredQuestionsWithIndex = [];
    for (int i = 0; i < test.questions.length; i++) {
      final q = test.questions[i];
      final userAns = result.selectedAnswers[i];
      final isCorrect = userAns == q.correctOptionIndex;
      final isIncorrect = userAns != null && userAns != -1 && userAns != 4 && !isCorrect;

      if (_solutionFilter == 'All') {
        filteredQuestionsWithIndex.add({'index': i, 'question': q});
      } else if (_solutionFilter == 'Incorrect' && isIncorrect) {
        filteredQuestionsWithIndex.add({'index': i, 'question': q});
      } else if (_solutionFilter == 'Correct' && isCorrect) {
        filteredQuestionsWithIndex.add({'index': i, 'question': q});
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        elevation: 0,
        title: const Text(
          'ટેસ્ટ પરિણામ (Score Card)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Score Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D253F),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const Text(
                    'તમારો કુલ સ્કોર',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${result.obtainedMarks} / ${test.totalPossibleMarks.toInt()}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeaderStat('સચોટતા (Accuracy)', '${result.accuracyPercentage}%'),
                      Container(height: 24, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 16)),
                      _buildHeaderStat('સમય લીધો', '${result.timeSpentSeconds ~/ 60} મિ. ${result.timeSpentSeconds % 60} સે.'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Performance Cards Row (Correct, Incorrect, Unattempted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'સાચા ઉત્તર',
                      value: '${result.correctCount}',
                      subtext: '+${result.correctCount * test.positiveMarksPerQuestion} ગુણ',
                      color: const Color(0xFF2E7D32),
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'ખોટા ઉત્તર',
                      value: '${result.incorrectCount}',
                      subtext: '-${result.incorrectCount * test.negativeMarksPerQuestion} નેગેટિવ',
                      color: const Color(0xFFC62828),
                      icon: Icons.cancel_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'છોડી દીધેલ / E',
                      value: '${result.unattemptedCount}',
                      subtext: '0.0 ગુણ',
                      color: Colors.grey[700]!,
                      icon: Icons.remove_circle_outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filter Tabs for Answer Review
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ઉત્તર કૂંચી અને સમજૂતી',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D253F),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _solutionFilter,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('બધા પ્રશ્નો')),
                      DropdownMenuItem(value: 'Incorrect', child: Text('માત્ર ખોટા')),
                      DropdownMenuItem(value: 'Correct', child: Text('માત્ર સાચા')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _solutionFilter = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Questions Review List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredQuestionsWithIndex.length,
              itemBuilder: (context, idx) {
                final item = filteredQuestionsWithIndex[idx];
                final qIndex = item['index'] as int;
                final q = item['question'] as Question;
                final userAns = result.selectedAnswers[qIndex];
                final isCorrect = userAns == q.correctOptionIndex;
                final isUnattempted = userAns == null || userAns == -1 || userAns == 4;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'પ્રશ્ન ${qIndex + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? const Color(0xFFE8F5E9)
                                    : (isUnattempted
                                        ? Colors.grey[200]
                                        : const Color(0xFFFFEBEE)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isCorrect
                                    ? 'સાચો (+1)'
                                    : (isUnattempted ? 'છોડેલ (0)' : 'ખોટો (-0.25)'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect
                                      ? const Color(0xFF2E7D32)
                                      : (isUnattempted ? Colors.grey[800] : const Color(0xFFC62828)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q.questionText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D253F),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // User choice vs Correct choice
                        if (userAns != null && userAns >= 0 && userAns < q.options.length)
                          Text(
                            'તમારો જવાબ: ${q.options[userAns]}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            ),
                          ),
                        Text(
                          'સાચો જવાબ: ${q.options[q.correctOptionIndex]}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Text(
                            'વિશેષ સમજૂતી: ${q.explanation}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Action Buttons (Retake & Home)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => QuizScreen(test: test)),
                        );
                      },
                      child: const Text('ફરીથી ટેસ્ટ આપો'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D253F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('મુખ્ય સ્ક્રીન પર જાઓ'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
          const SizedBox(height: 2),
          Text(subtext, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
