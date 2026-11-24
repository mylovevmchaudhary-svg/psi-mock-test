import '../models/quiz_model.dart';
import '../services/firebase_service.dart';

class CuratedQuestionBank {
  // 100% Dynamic repository loaded from Firebase Cloud Firestore
  // ZERO hardcoded tests and ZERO hardcoded MCQs as requested by user!
  static final Map<String, List<Question>> _cachedQuestions = {};

  // Dynamic Mock Tests cache grouped by Exam ID (Constable / PSI)
  static final Map<String, List<MockTest>> _dynamicTestsByExam = {};

  /// Set questions for a specific test
  static void setQuestions(String testId, List<Question> questions) {
    _cachedQuestions[testId] = List.from(questions);
  }

  /// Add a single question to a test
  static void addQuestion(String testId, Question question) {
    _cachedQuestions.putIfAbsent(testId, () => []).add(question);
  }

  /// Delete a question from a test
  static void removeQuestion(String testId, String questionId) {
    _cachedQuestions[testId]?.removeWhere((q) => q.id == questionId);
  }

  /// Load questions from Firebase for a test
  static Future<List<Question>> loadQuestionsFromFirebase(String testId) async {
    final questions = await FirebaseService().fetchAllQuestionsForTest(testId);
    if (questions.isNotEmpty) {
      _cachedQuestions[testId] = questions;
      for (final list in _dynamicTestsByExam.values) {
        for (final t in list) {
          if (t.id == testId) {
            t.questions = questions;
          }
        }
      }
    }
    return _cachedQuestions[testId] ?? [];
  }

  /// Load all dynamic mock tests from Firebase `mock_tests` collection
  static Future<List<MockTest>> loadAllTestsFromFirebase({String? examId}) async {
    final liveTests = await FirebaseService().fetchMockTests(examId: examId);
    if (liveTests.isNotEmpty) {
      for (final t in liveTests) {
        if (_cachedQuestions.containsKey(t.id)) {
          t.questions = _cachedQuestions[t.id]!;
        }
      }

      if (examId != null && examId.isNotEmpty) {
        _dynamicTestsByExam[examId] = liveTests;
      } else {
        _dynamicTestsByExam['constable'] =
            liveTests.where((t) => t.examId == 'constable').toList();
        _dynamicTestsByExam['psi'] =
            liveTests.where((t) => t.examId == 'psi').toList();
      }
      return liveTests;
    }
    return _dynamicTestsByExam[examId ?? 'constable'] ?? [];
  }

  /// Count questions available for a given subject keyword
  static int getQuestionCountForSubject(String subjectKeyword) {
    int count = 0;
    for (final list in _cachedQuestions.values) {
      for (final q in list) {
        if (q.subject.toLowerCase().contains(subjectKeyword.toLowerCase())) {
          count++;
        }
      }
    }
    return count;
  }

  /// Get mock tests for Constable or PSI - 100% dynamic from Firebase!
  /// ZERO hardcoded fallback tests when database has no tests!
  static List<MockTest> getCuratedTests(String examId) {
    if (_dynamicTestsByExam.containsKey(examId)) {
      return _dynamicTestsByExam[examId]!;
    }
    return [];
  }
}
