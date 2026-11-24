class Question {
  final String id;
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // 0 for A, 1 for B, 2 for C, 3 for D, 4 for E
  final String explanation;
  final String? topic;
  final String? topicId;
  final String? examId;
  final String? difficulty;
  bool isBookmarked;

  Question({
    required this.id,
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.topic,
    this.topicId,
    this.examId,
    this.difficulty,
    this.isBookmarked = false,
  });
}

class MockTest {
  final String id;
  final String title;
  final String description;
  final String category; // 'Full Mock', 'Subject Wise', 'Daily Booster'
  final int durationMinutes;
  final double positiveMarksPerQuestion;
  final double negativeMarksPerQuestion;
  final bool isFree;
  final int dbTotalQuestions;
  final int actualMcqCount;
  final String examId;
  List<Question> questions;

  MockTest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationMinutes,
    this.positiveMarksPerQuestion = 1.0,
    this.negativeMarksPerQuestion = 0.25,
    this.isFree = true,
    this.dbTotalQuestions = 200,
    this.actualMcqCount = 0,
    this.examId = 'constable',
    required this.questions,
  });

  int get totalQuestions => questions.isNotEmpty ? questions.length : actualMcqCount;
  double get totalPossibleMarks => totalQuestions * positiveMarksPerQuestion;
}

class QuizAttemptResult {
  final MockTest test;
  final Map<int, int> selectedAnswers; // questionIndex -> selectedOptionIndex (-1 for unattempted)
  final int timeSpentSeconds;

  QuizAttemptResult({
    required this.test,
    required this.selectedAnswers,
    required this.timeSpentSeconds,
  });

  int get correctCount {
    int count = 0;
    for (int i = 0; i < test.questions.length; i++) {
      if (selectedAnswers[i] == test.questions[i].correctOptionIndex) {
        count++;
      }
    }
    return count;
  }

  int get incorrectCount {
    int count = 0;
    for (int i = 0; i < test.questions.length; i++) {
      int? selected = selectedAnswers[i];
      if (selected != null &&
          selected >= 0 &&
          selected < 4 &&
          selected != test.questions[i].correctOptionIndex) {
        count++;
      }
    }
    return count;
  }

  int get unattemptedCount {
    int count = 0;
    for (int i = 0; i < test.questions.length; i++) {
      int? selected = selectedAnswers[i];
      if (selected == null || selected == -1 || selected == 4) {
        // Option index 4 is option E (Not Attempted)
        count++;
      }
    }
    return count;
  }

  double get obtainedMarks {
    double marks = (correctCount * test.positiveMarksPerQuestion) -
        (incorrectCount * test.negativeMarksPerQuestion);
    return marks < 0 ? 0.0 : double.parse(marks.toStringAsFixed(2));
  }

  double get accuracyPercentage {
    int attempted = correctCount + incorrectCount;
    if (attempted == 0) return 0.0;
    return double.parse(((correctCount / attempted) * 100).toStringAsFixed(1));
  }

  /// Subject-wise breakdown for post-test analysis
  Map<String, Map<String, dynamic>> get subjectBreakdown {
    final Map<String, Map<String, dynamic>> breakdown = {};
    for (int i = 0; i < test.questions.length; i++) {
      final q = test.questions[i];
      final subj = q.subject;
      breakdown.putIfAbsent(subj, () => {
        'total': 0,
        'correct': 0,
        'incorrect': 0,
        'unattempted': 0,
        'marks': 0.0,
      });

      breakdown[subj]!['total'] = (breakdown[subj]!['total'] as int) + 1;
      final ans = selectedAnswers[i];
      if (ans == q.correctOptionIndex) {
        breakdown[subj]!['correct'] = (breakdown[subj]!['correct'] as int) + 1;
      } else if (ans != null && ans >= 0 && ans < 4) {
        breakdown[subj]!['incorrect'] = (breakdown[subj]!['incorrect'] as int) + 1;
      } else {
        breakdown[subj]!['unattempted'] = (breakdown[subj]!['unattempted'] as int) + 1;
      }
    }

    for (final s in breakdown.keys) {
      final c = breakdown[s]!['correct'] as int;
      final inc = breakdown[s]!['incorrect'] as int;
      final m = (c * test.positiveMarksPerQuestion) - (inc * test.negativeMarksPerQuestion);
      breakdown[s]!['marks'] = m < 0 ? 0.0 : double.parse(m.toStringAsFixed(2));
      final attempted = c + inc;
      breakdown[s]!['accuracy'] = attempted > 0 ? double.parse(((c / attempted) * 100).toStringAsFixed(1)) : 0.0;
    }

    return breakdown;
  }

  /// Topic-wise performance analysis for weakness detection
  Map<String, Map<String, dynamic>> get topicBreakdown {
    final Map<String, Map<String, dynamic>> breakdown = {};
    for (int i = 0; i < test.questions.length; i++) {
      final q = test.questions[i];
      final top = (q.topic != null && q.topic!.isNotEmpty) ? q.topic! : q.subject;
      breakdown.putIfAbsent(top, () => {
        'subject': q.subject,
        'total': 0,
        'correct': 0,
        'incorrect': 0,
        'unattempted': 0,
      });

      breakdown[top]!['total'] = (breakdown[top]!['total'] as int) + 1;
      final ans = selectedAnswers[i];
      if (ans == q.correctOptionIndex) {
        breakdown[top]!['correct'] = (breakdown[top]!['correct'] as int) + 1;
      } else if (ans != null && ans >= 0 && ans < 4) {
        breakdown[top]!['incorrect'] = (breakdown[top]!['incorrect'] as int) + 1;
      } else {
        breakdown[top]!['unattempted'] = (breakdown[top]!['unattempted'] as int) + 1;
      }
    }
    return breakdown;
  }
}
