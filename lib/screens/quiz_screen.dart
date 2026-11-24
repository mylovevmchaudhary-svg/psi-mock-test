import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final MockTest test;

  const QuizScreen({super.key, required this.test});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionIndex -> optionIndex
  final Set<int> _markedForReview = {};
  final Set<int> _visitedQuestions = {0};
  late int _remainingSeconds;
  Timer? _timer;
  int _timeSpentSeconds = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.test.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _submitTest();
      } else {
        setState(() {
          _remainingSeconds--;
          _timeSpentSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = optionIndex;
      _visitedQuestions.add(_currentQuestionIndex);
    });
  }

  void _toggleMarkForReview() {
    setState(() {
      if (_markedForReview.contains(_currentQuestionIndex)) {
        _markedForReview.remove(_currentQuestionIndex);
      } else {
        _markedForReview.add(_currentQuestionIndex);
      }
      _visitedQuestions.add(_currentQuestionIndex);
    });
  }

  void _clearResponse() {
    setState(() {
      _selectedAnswers.remove(_currentQuestionIndex);
      _markedForReview.remove(_currentQuestionIndex);
    });
  }

  void _submitTest() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _timer?.cancel();

    final result = QuizAttemptResult(
      test: widget.test,
      selectedAnswers: _selectedAnswers,
      timeSpentSeconds: _timeSpentSeconds,
    );

    // Record local test completion stats
    UserModel().recordTestCompletion(
      score: result.correctCount,
      totalQuestions: widget.test.questions.length,
    );

    // Record Firestore test attempt with idempotency
    try {
      await FirebaseService().recordTestAttempt(
        testId: widget.test.id,
        testTitle: widget.test.title,
        examId: widget.test.examId,
        score: result.obtainedMarks,
        totalMarks: widget.test.totalPossibleMarks,
        correctCount: result.correctCount,
        incorrectCount: result.incorrectCount,
        unattemptedCount: result.unattemptedCount,
        accuracy: result.accuracyPercentage,
        timeSpentSeconds: _timeSpentSeconds,
        subjectBreakdown: result.subjectBreakdown,
      );
    } catch (_) {}

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(result: result),
        ),
      );
    }
  }

  void _confirmSubmit() {
    final answeredCount = _selectedAnswers.length;
    final totalCount = widget.test.questions.length;
    final reviewCount = _markedForReview.length;
    final unansweredCount = totalCount - answeredCount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.assignment_turned_in, color: Color(0xFF0D253F)),
            SizedBox(width: 8),
            Text('ટેસ્ટ સબમિટ કરવો છે?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('કુલ પ્રશ્નો', '$totalCount', Colors.black87),
                  const Divider(height: 12),
                  _buildSummaryRow('ઉત્તર આપેલ', '$answeredCount', const Color(0xFF2E7D32)),
                  const Divider(height: 12),
                  _buildSummaryRow('બાકી પ્રશ્નો', '$unansweredCount', Colors.red),
                  const Divider(height: 12),
                  _buildSummaryRow('રીવ્યુ માટે ચિહ્નિત', '$reviewCount', const Color(0xFF7B1FA2)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (unansweredCount > 0)
              const Text(
                'ચેતવણી: તમે હજુ કેટલાક પ્રશ્નોના ઉત્તર આપ્યા નથી.',
                style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 4),
            const Text(
              'શું તમે ખરેખર પરીક્ષા પૂર્ણ કરીને સબમિટ કરવા માંગો છો?',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ટેસ્ટ ચાલુ રાખો'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D253F),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _submitTest();
            },
            child: const Text('હા, સબમિટ કરો (Submit)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.test.questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D253F),
          title: Text(widget.test.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_outlined, size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'આ મોક ટેસ્ટમાં હજુ પ્રશ્નો ઉમેરાયા નથી.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'એડમિન દ્વારા પ્રશ્નો ઉમેરવામાં આવ્યા પછી અહીં આપોઆપ ટેસ્ટ શરૂ થશે.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D253F),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('પાછા જાઓ'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = widget.test.questions[_currentQuestionIndex];
    final selectedOption = _selectedAnswers[_currentQuestionIndex];
    final isTimerLow = _remainingSeconds < 600; // less than 10 mins
    final isMarkedForReview = _markedForReview.contains(_currentQuestionIndex);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _confirmSubmit();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D253F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _confirmSubmit,
          ),
          title: Text(
            'પ્રશ્ન ${_currentQuestionIndex + 1} / ${widget.test.questions.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isTimerLow
                    ? Colors.red.withOpacity(0.2)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isTimerLow ? Colors.red : Colors.white38,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: isTimerLow ? Colors.redAccent : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isTimerLow ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.grid_view, color: Colors.white),
              tooltip: 'પ્રશ્ન પેલેટ (200 MCQs)',
              onPressed: _showQuestionPalette,
            ),
          ],
        ),
        body: Column(
          children: [
            // Unified Official Subject Section Heading & Topic Pill (Single Paper, No Part A/B)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D253F),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'વિભાગ',
                                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                currentQuestion.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D253F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${widget.test.positiveMarksPerQuestion} / -${widget.test.negativeMarksPerQuestion}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              currentQuestion.isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: currentQuestion.isBookmarked
                                  ? const Color(0xFFFFC107)
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                currentQuestion.isBookmarked = !currentQuestion.isBookmarked;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 1),
                                  content: Text(
                                    currentQuestion.isBookmarked
                                        ? 'પ્રશ્ન બુકમાર્ક્સમાં સાચવ્યો!'
                                        : 'બુકમાર્ક્સમાંથી દૂર કર્યો.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (currentQuestion.topic != null && currentQuestion.topic!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ટોપિક: ${currentQuestion.topic!}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700], fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),

            // Question Text & Options (Single Question Paper Layout)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.questionText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D253F),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 4 Radio Options + Option E (Not Attempted)
                    ...List.generate(currentQuestion.options.length, (optIdx) {
                      final optionText = currentQuestion.options[optIdx];
                      final isSelected = selectedOption == optIdx;
                      final isOptionE = optIdx == 4;

                      return GestureDetector(
                        onTap: () => _selectOption(optIdx),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isOptionE
                                    ? const Color(0xFFFFF3E0)
                                    : const Color(0xFFE8F5E9))
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isOptionE
                                      ? Colors.orange
                                      : const Color(0xFF2E7D32))
                                  : Colors.grey.withOpacity(0.25),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? (isOptionE
                                          ? Colors.orange
                                          : const Color(0xFF2E7D32))
                                      : Colors.grey[200],
                                ),
                                child: Center(
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          size: 16, color: Colors.white)
                                      : Text(
                                          String.fromCharCode(65 + optIdx),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? (isOptionE
                                            ? Colors.deepOrange
                                            : const Color(0xFF1B5E20))
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Examination Action Bar: Prev, Review, Clear, Next/Submit
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Previous Button
                  if (_currentQuestionIndex > 0)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                          _visitedQuestions.add(_currentQuestionIndex);
                        });
                      },
                      child: const Text('પાછળ'),
                    )
                  else
                    const SizedBox(width: 60),

                  const Spacer(),

                  // Mark for Review Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isMarkedForReview ? const Color(0xFF7B1FA2) : Colors.grey[700],
                      side: BorderSide(
                        color: isMarkedForReview ? const Color(0xFF7B1FA2) : Colors.grey[400]!,
                        width: isMarkedForReview ? 1.5 : 1.0,
                      ),
                      backgroundColor: isMarkedForReview ? const Color(0xFFF3E5F5) : null,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: Icon(
                      isMarkedForReview ? Icons.flag : Icons.outlined_flag,
                      size: 16,
                      color: isMarkedForReview ? const Color(0xFF7B1FA2) : Colors.grey[700],
                    ),
                    label: Text(
                      isMarkedForReview ? 'ચિહ્નિત છે' : 'રીવ્યુ',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: _toggleMarkForReview,
                  ),

                  const SizedBox(width: 6),

                  // Clear Response Button
                  if (selectedOption != null || isMarkedForReview)
                    TextButton(
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                      onPressed: _clearResponse,
                      child: const Text('સાફ કરો', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),

                  const Spacer(),

                  // Next or Submit Button
                  if (_currentQuestionIndex < widget.test.questions.length - 1)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D253F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex++;
                          _visitedQuestions.add(_currentQuestionIndex);
                        });
                      },
                      child: const Text('આગળ'),
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('સબમિટ'),
                      onPressed: _confirmSubmit,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionPalette() {
    // Dynamic subject jump chips based on real questions
    final Map<String, int> subjectFirstIndices = {};
    for (int i = 0; i < widget.test.questions.length; i++) {
      final s = widget.test.questions[i].subject;
      if (!subjectFirstIndices.containsKey(s)) {
        subjectFirstIndices[s] = i;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setPaletteState) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'પ્રશ્ન પેલેટ (200 MCQs)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D253F),
                          ),
                        ),
                        Text(
                          'ઉત્તર આપેલ: ${_selectedAnswers.length} / ${widget.test.questions.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 5-Color Official Examination Legend Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildLegendBadge(const Color(0xFF2E7D32), 'ઉત્તર આપેલ'),
                          const SizedBox(width: 8),
                          _buildLegendBadge(const Color(0xFF7B1FA2), 'રીવ્યુ માટે'),
                          const SizedBox(width: 8),
                          _buildLegendBadge(const Color(0xFF1565C0), 'ઉત્તર + રીવ્યુ'),
                          const SizedBox(width: 8),
                          _buildLegendBadge(const Color(0xFFD32F2F), 'બાકી (મુલાકાત લીધેલ)'),
                          const SizedBox(width: 8),
                          _buildLegendBadge(Colors.grey[300]!, 'મુલાકાત લીધેલ નથી', textColor: Colors.black87),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dynamic Jump Chips by Actual Official Subjects
                    if (subjectFirstIndices.length > 1) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: subjectFirstIndices.entries.map((e) {
                            return _buildJumpChip(e.key, e.value, ctx);
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const Divider(height: 12),

                    // 1-200 Question Palette Grid
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: widget.test.questions.length,
                        itemBuilder: (context, idx) {
                          final isCurrent = idx == _currentQuestionIndex;
                          final isAnswered = _selectedAnswers.containsKey(idx);
                          final isReview = _markedForReview.contains(idx);
                          final isVisited = _visitedQuestions.contains(idx);

                          Color bgColor;
                          Color textColor = Colors.white;

                          if (isAnswered && isReview) {
                            bgColor = const Color(0xFF1565C0); // Blue
                          } else if (isReview) {
                            bgColor = const Color(0xFF7B1FA2); // Purple
                          } else if (isAnswered) {
                            bgColor = const Color(0xFF2E7D32); // Green
                          } else if (isVisited) {
                            bgColor = const Color(0xFFD32F2F); // Red
                          } else {
                            bgColor = Colors.grey[200]!;
                            textColor = Colors.black87;
                          }

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentQuestionIndex = idx;
                                _visitedQuestions.add(idx);
                              });
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: isCurrent ? Border.all(color: const Color(0xFFFFC107), width: 2.5) : null,
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Widget _buildLegendBadge(Color color, String label, {Color textColor = Colors.white}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black87)),
      ],
    );
  }

  Widget _buildJumpChip(String label, int targetIndex, BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFF0F4F8),
        onPressed: () {
          setState(() {
            _currentQuestionIndex = targetIndex;
            _visitedQuestions.add(targetIndex);
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }
}
