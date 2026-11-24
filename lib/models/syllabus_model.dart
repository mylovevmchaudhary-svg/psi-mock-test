class SyllabusTopic {
  final String id;
  final String name;
  final String nameGujarati;
  final String? syllabusId;
  final String? paperPart;
  final String? contentType;
  final List<String> keyPoints;
  int mcqCount;
  bool isCompleted;

  SyllabusTopic({
    required this.id,
    required this.name,
    required this.nameGujarati,
    this.syllabusId,
    this.paperPart,
    this.contentType,
    required this.keyPoints,
    this.mcqCount = 0,
    this.isCompleted = false,
  });
}

class SyllabusSubject {
  final String id;
  final String title;
  final String titleGujarati;
  final String iconName;
  final int totalMarksWeightage;
  final String examId;
  int dynamicMcqCount;
  final List<SyllabusTopic> topics;

  SyllabusSubject({
    required this.id,
    required this.title,
    required this.titleGujarati,
    required this.iconName,
    required this.totalMarksWeightage,
    this.examId = 'constable',
    this.dynamicMcqCount = 0,
    required this.topics,
  });

  /// Dynamic MCQ count calculated from topics or actual database questions
  int get mcqCount {
    if (dynamicMcqCount > 0) return dynamicMcqCount;
    int sum = 0;
    for (final t in topics) {
      sum += t.mcqCount;
    }
    return sum;
  }

  int get completedTopicsCount =>
      topics.where((topic) => topic.isCompleted).length;

  double get progressPercentage =>
      topics.isEmpty ? 0.0 : (completedTopicsCount / topics.length);
}
