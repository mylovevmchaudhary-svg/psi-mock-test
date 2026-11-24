enum ExamType {
  constable,
  psi,
}

extension ExamTypeExtension on ExamType {
  String get title {
    switch (this) {
      case ExamType.constable:
        return 'Gujarat Police Constable (LRD)';
      case ExamType.psi:
        return 'Gujarat Police PSI (Sub-Inspector)';
    }
  }

  String get shortTitle {
    switch (this) {
      case ExamType.constable:
        return 'Constable';
      case ExamType.psi:
        return 'PSI';
    }
  }

  String get badgeText {
    switch (this) {
      case ExamType.constable:
        return 'લોકરક્ષક દળ (LRD)';
      case ExamType.psi:
        return 'પોલીસ સબ ઇન્સ્પેક્ટર';
    }
  }
}
