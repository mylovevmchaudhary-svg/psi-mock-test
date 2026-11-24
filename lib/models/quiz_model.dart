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
}
