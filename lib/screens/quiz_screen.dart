import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../models/user_model.dart';
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
  late int _remainingSeconds;
  Timer? _timer;
  int _timeSpentSeconds = 0;

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
    });
  }

  void _clearResponse() {
    setState(() {
      _selectedAnswers.remove(_currentQuestionIndex);
    });
  }

  void _submitTest() {
    _timer?.cancel();
    final result = QuizAttemptResult(
      test: widget.test,
      selectedAnswers: _selectedAnswers,
      timeSpentSeconds: _timeSpentSeconds,
    );

    // Record real dynamic test score & attempts
    UserModel().recordTestCompletion(
      score: result.correctCount,
      totalQuestions: widget.test.questions.length,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(result: result),
      ),
    );
  }

  void _confirmSubmit() {
    final answeredCount = _selectedAnswers.length;
    final totalCount = widget.test.questions.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ટેસ્ટ સબમિટ કરવો છે?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• કુલ પ્રશ્નો: $totalCount'),
            Text('• ઉત્તર આપેલ: $answeredCount', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            Text('• બાકી પ્રશ્નો: ${totalCount - answeredCount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 12),
            const Text(
              'શું તમે ખરેખર ટેસ્ટ પૂર્ણ કરીને પરિણામ જોવા માંગો છો?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('રદ કરો (Cancel)'),
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
            child: const Text('સબમિટ કરો (Submit)'),
          ),
        ],
      ),
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
            // Subject pill & Bookmark row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentQuestion.subject,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${_selectedAnswers.length}/200 ઉત્તર આપેલ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
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
                            currentQuestion.isBookmarked =
                                !currentQuestion.isBookmarked;
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
            ),

            // Question Text & Options
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

                    // Options list
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

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      child: const Text('પાછળ'),
                    )
                  else
                    const SizedBox(width: 70),
                  const Spacer(),
                  if (selectedOption != null)
                    TextButton(
                      onPressed: _clearResponse,
                      child: const Text(
                        'ક્લિયર કરો',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const Spacer(),
                  if (_currentQuestionIndex < widget.test.questions.length - 1)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D253F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      },
                      child: const Text('આગળ'),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _confirmSubmit,
                      child: const Text('સબમિટ'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
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
                        'પ્રશ્ન પેલેટ (200 પ્રશ્નો)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D253F),
                        ),
                      ),
                      Text(
                        'ઉત્તર આપેલ: ${_selectedAnswers.length} / 200',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quick Jump Chips by Subject
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildJumpChip('બંધારણ (1-30)', 0, ctx),
                        _buildJumpChip('કાયદો (31-65)', 30, ctx),
                        _buildJumpChip('ઇતિહાસ (66-90)', 65, ctx),
                        _buildJumpChip('ભૂગોળ (91-115)', 90, ctx),
                        _buildJumpChip('રીઝનિંગ (116-150)', 115, ctx),
                        _buildJumpChip('ગણિત (151-170)', 150, ctx),
                        _buildJumpChip('વિજ્ઞાન (171-185)', 170, ctx),
                        _buildJumpChip('વર્તમાન (186-200)', 185, ctx),
                      ],
                    ),
                  ),
                  const Divider(height: 20),
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
                        final isAnswered = _selectedAnswers.containsKey(idx);
                        final isCurrent = idx == _currentQuestionIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentQuestionIndex = idx;
                            });
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0xFF0D253F)
                                  : (isAnswered
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  color: isCurrent || isAnswered
                                      ? Colors.white
                                      : Colors.black87,
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
        );
      },
    );
  }

  Widget _buildJumpChip(String label, int targetIndex, BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        backgroundColor: const Color(0xFFF0F4F8),
        onPressed: () {
          setState(() {
            _currentQuestionIndex = targetIndex;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }
}
