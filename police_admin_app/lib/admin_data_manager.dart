import 'dart:convert';
import 'dart:io';
import 'firebase_vault.dart';

class AdminDataManager {
  static final AdminDataManager _instance = AdminDataManager._internal();
  factory AdminDataManager() => _instance;
  AdminDataManager._internal();

  String get projectId => FirebaseVault.projectId;
  String get apiKey => FirebaseVault.apiKey;
  String get firestoreUrl => FirebaseVault.firestoreBaseUrl;

  bool isConnectedToFirebase = true;
  bool isLoading = false;

  String? adminToken;
  String? adminEmail;
  String? adminUid;

  // Active Mock Tests list - 100% DYNAMIC from Firebase Firestore
  final List<Map<String, dynamic>> tests = [];

  // Dynamic Question Bank per Test - 100% REAL from Firebase Firestore
  final Map<String, List<Map<String, dynamic>>> testQuestions = {};

  // Real Registered Students List - 100% from Firestore `profiles` and `users`
  final List<Map<String, dynamic>> students = [];

  // Real Withdrawal Requests List - 100% from Firestore `withdrawals`
  final List<Map<String, dynamic>> withdrawals = [];

  // Dynamic Social & Website links
  Map<String, String> socialLinks = {
    'website': 'https://gujaratpoliceprep.in',
    'whatsapp': 'https://chat.whatsapp.com/KhakhiPrep2026',
    'telegram': 'https://t.me/GujaratPolicePrep',
    'youtube': 'https://youtube.com/@GujaratPolicePrep',
    'instagram': 'https://instagram.com/gujaratpoliceprep',
  };

  // Firestore Field Encoders & Decoders
  static Map<String, dynamic> _encodeValue(dynamic val) {
    if (val == null) return {'nullValue': null};
    if (val is bool) return {'booleanValue': val};
    if (val is int) return {'integerValue': val.toString()};
    if (val is double) return {'doubleValue': val};
    if (val is String) return {'stringValue': val};
    if (val is List) {
      return {'arrayValue': {'values': val.map((e) => _encodeValue(e)).toList()}};
    }
    if (val is Map) {
      final Map<String, dynamic> f = {};
      val.forEach((k, v) => f[k.toString()] = _encodeValue(v));
      return {'mapValue': {'fields': f}};
    }
    return {'stringValue': val.toString()};
  }

  static dynamic _decodeValue(Map<String, dynamic> v) {
    if (v.containsKey('stringValue')) return v['stringValue'];
    if (v.containsKey('integerValue')) return int.tryParse(v['integerValue'].toString()) ?? 0;
    if (v.containsKey('doubleValue')) return (v['doubleValue'] as num?)?.toDouble() ?? 0.0;
    if (v.containsKey('booleanValue')) return v['booleanValue'] == true;
    if (v.containsKey('arrayValue')) {
      final l = v['arrayValue']?['values'];
      if (l is List) return l.map((e) => _decodeValue(e as Map<String, dynamic>)).toList();
      return [];
    }
    if (v.containsKey('mapValue')) {
      final f = v['mapValue']?['fields'];
      if (f is Map<String, dynamic>) {
        final Map<String, dynamic> res = {};
        f.forEach((k, val) => res[k] = _decodeValue(val as Map<String, dynamic>));
        return res;
      }
      return {};
    }
    return null;
  }

  static Map<String, dynamic> _decodeDoc(Map<String, dynamic> doc) {
    final Map<String, dynamic> res = {};
    final name = doc['name']?.toString() ?? '';
    if (name.isNotEmpty) {
      final segs = name.split('/');
      if (segs.isNotEmpty) res['id'] = segs.last;
    }
    final fields = doc['fields'];
    if (fields is Map<String, dynamic>) {
      fields.forEach((k, v) {
        if (v is Map<String, dynamic>) res[k] = _decodeValue(v);
      });
    }
    return res;
  }

  Future<List<Map<String, dynamic>>> _firestoreList(String collection, {int pageSize = 300}) async {
    final List<Map<String, dynamic>> docs = [];
    try {
      final uri = Uri.parse('$firestoreUrl/$collection?pageSize=$pageSize&key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final req = await client.getUrl(uri);
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> json = jsonDecode(body);
        final rawDocs = json['documents'];
        if (rawDocs is List) {
          for (final d in rawDocs) {
            if (d is Map<String, dynamic>) docs.add(_decodeDoc(d));
          }
        }
      }
    } catch (_) {}
    return docs;
  }

  Future<bool> _firestoreSet(String collection, String docId, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$firestoreUrl/$collection/$docId?key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final req = await client.patchUrl(uri);
      req.headers.set('Content-Type', 'application/json');

      final Map<String, dynamic> fields = {};
      data.forEach((k, v) => fields[k] = _encodeValue(v));
      req.write(jsonEncode({'fields': fields}));

      final res = await req.close();
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _firestoreDelete(String collection, String docId) async {
    try {
      final uri = Uri.parse('$firestoreUrl/$collection/$docId?key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final req = await client.deleteUrl(uri);
      final res = await req.close();
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // =========================================================================
  // FIREBASE AUTHENTICATION (ADMIN LOGIN VIA EMAIL & PASSWORD)
  // =========================================================================

  /// Real Firebase Authentication: Login Admin via Email & Password
  /// Checks directly against the Firebase project's Authentication users
  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    try {
      final uri = Uri.parse('${FirebaseVault.authBaseUrl}/accounts:signInWithPassword?key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final req = await client.postUrl(uri);
      req.headers.set('Content-Type', 'application/json');
      req.write(jsonEncode({
        'email': email.trim(),
        'password': password.trim(),
        'returnSecureToken': true,
      }));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        adminToken = json['idToken']?.toString();
        adminEmail = json['email']?.toString() ?? email.trim();
        adminUid = json['localId']?.toString();
        return {'success': true};
      } else {
        final errorObj = json['error'];
        final errorMsg = errorObj is Map ? (errorObj['message'] ?? 'Login failed') : 'Login failed';
        String friendly = 'અમાન્ય એડમિન ઈમેલ અથવા પાસવર્ડ.';
        if (errorMsg.toString().contains('EMAIL_NOT_FOUND')) {
          friendly = 'આ એડમિન ઈમેલ Firebase માં નોંધાયેલ નથી. કૃપા કરીને Firebase Console માં એકાઉન્ટ બનાવો.';
        } else if (errorMsg.toString().contains('INVALID_PASSWORD') ||
            errorMsg.toString().contains('INVALID_LOGIN_CREDENTIALS')) {
          friendly = 'ખોટો પાસવર્ડ! કૃપા કરીને Firebase માં સેટ કરેલ સાચો પાસવર્ડ દાખલ કરો.';
        } else if (errorMsg.toString().contains('USER_DISABLED')) {
          friendly = 'આ એડમિન એકાઉન્ટ નિષ્ક્રિય કરવામાં આવેલ છે.';
        }
        return {'success': false, 'error': friendly};
      }
    } catch (e) {
      return {'success': false, 'error': 'નેટવર્ક કનેક્શન તપાસો: $e'};
    }
  }

  // =========================================================================
  // DATA FETCHING & SYNCHRONIZATION
  // =========================================================================

  /// 1. Fetch Real Mock Tests from Firestore (Zero hardcoded fallback!)
  Future<void> fetchRealMockTests() async {
    final docs = await _firestoreList('mock_tests');
    final mtqDocs = await _firestoreList('mock_test_questions', pageSize: 1000);

    final Map<String, int> counts = {};
    for (final mtq in mtqDocs) {
      final tId = mtq['test_id']?.toString();
      if (tId != null) counts[tId] = (counts[tId] ?? 0) + 1;
    }

    tests.clear();
    for (final item in docs) {
      final examId = item['exam_id']?.toString() ?? 'constable';
      final testId = item['id']?.toString() ?? '';
      final mcqCount = counts[testId] ?? (item['total_questions'] as num?)?.toInt() ?? 0;

      tests.add({
        'id': testId,
        'exam': examId == 'psi' ? 'PSI / ASI' : 'કોન્સ્ટેબલ (LRD)',
        'exam_id': examId,
        'title': item['title']?.toString() ?? 'મોક ટેસ્ટ',
        'description': item['description']?.toString() ?? '',
        'isFree': item['is_free'] == true,
        'totalMcqs': mcqCount,
        'duration': (item['duration_minutes'] as num?)?.toInt() ?? 180,
      });

      if (!testQuestions.containsKey(testId)) {
        testQuestions[testId] = [];
      }
    }
  }

  /// 2. Fetch Real Students from Firestore `profiles` and `users`
  Future<void> fetchRealStudents() async {
    final profileDocs = await _firestoreList('profiles');
    final userDocs = await _firestoreList('users');

    final Map<String, Map<String, dynamic>> combined = {};
    for (final d in profileDocs) {
      final id = d['id']?.toString() ?? '';
      if (id.isNotEmpty) combined[id] = d;
    }
    for (final d in userDocs) {
      final id = d['id']?.toString() ?? '';
      if (id.isNotEmpty && !combined.containsKey(id)) {
        combined[id] = d;
      }
    }

    students.clear();
    for (final item in combined.values) {
      String joinedStr = 'તાજેતરમાં';
      if (item['created_at'] != null) {
        try {
          final dt = DateTime.parse(item['created_at'].toString());
          joinedStr = '${dt.day}/${dt.month}/${dt.year}';
        } catch (_) {}
      }
      students.add({
        'id': item['id']?.toString() ?? '',
        'name': item['name']?.toString() ?? 'વિદ્યાર્થી',
        'email': item['email']?.toString() ?? '',
        'phone': item['phone']?.toString() ?? '',
        'coins': (item['coins'] as num?)?.toInt() ?? 0,
        'referrals': (item['total_referrals'] as num?)?.toInt() ?? 0,
        'referralCode': item['my_referral_code']?.toString() ?? '',
        'joinedDate': joinedStr,
        'isActive': true,
      });
    }
  }

  /// 3. Fetch Real Withdrawals from Firestore `withdrawals` collection
  Future<void> fetchRealWithdrawals() async {
    final docs = await _firestoreList('withdrawals');
    withdrawals.clear();
    for (final item in docs) {
      final statusStr = item['status']?.toString().toLowerCase() ?? 'pending';
      final isPending = statusStr == 'pending';
      final isApproved = statusStr == 'approved';

      String dateStr = 'આજે';
      if (item['created_at'] != null) {
        try {
          final dt = DateTime.parse(item['created_at'].toString());
          dateStr = '${dt.day}/${dt.month}/${dt.year}';
        } catch (_) {}
      }

      withdrawals.add({
        'id': item['id']?.toString() ?? '',
        'studentName': item['student_name']?.toString() ?? 'વિદ્યાર્થી',
        'email': item['student_email']?.toString() ?? '',
        'amount': '₹${(item['amount_inr'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
        'coins': (item['coins_deducted'] as num?)?.toInt() ?? 0,
        'upi': item['upi_id']?.toString() ?? '',
        'status': isApproved ? 'મંજૂર થયેલ (Paid) ✅' : (isPending ? 'પેન્ડિંગ (Pending)' : 'અસ્વીકાર (Rejected) ❌'),
        'isPending': isPending,
        'date': dateStr,
      });
    }
  }

  /// 4. Fetch Real Questions from Firestore
  Future<void> fetchRealQuestions() async {
    for (final key in testQuestions.keys) {
      testQuestions[key]?.clear();
    }

    final mtqDocs = await _firestoreList('mock_test_questions', pageSize: 1000);
    final qDocs = await _firestoreList('questions', pageSize: 1000);

    final Map<String, Map<String, dynamic>> qById = {};
    for (final q in qDocs) {
      final qId = q['id']?.toString();
      if (qId != null) qById[qId] = q;
    }

    // Sort by position
    mtqDocs.sort((a, b) {
      final posA = (a['position'] as num?)?.toInt() ?? 0;
      final posB = (b['position'] as num?)?.toInt() ?? 0;
      return posA.compareTo(posB);
    });

    for (final mtq in mtqDocs) {
      final testId = mtq['test_id']?.toString();
      final qId = mtq['question_id']?.toString();
      if (testId != null && qId != null && qById.containsKey(qId)) {
        _addQuestionToTestMap(testId, qById[qId]!);
      }
    }

    // Also sync direct questions
    for (final q in qDocs) {
      final testId = q['test_id']?.toString();
      if (testId != null && testId.isNotEmpty) {
        _addQuestionToTestMap(testId, q);
      }
    }

    // Update totalMcqs for tests
    for (final t in tests) {
      final tid = t['id']?.toString();
      if (tid != null && testQuestions.containsKey(tid)) {
        t['totalMcqs'] = testQuestions[tid]!.length;
      }
    }
  }

  void _addQuestionToTestMap(String testId, Map<String, dynamic> item) {
    if (!testQuestions.containsKey(testId)) {
      testQuestions[testId] = [];
    }

    final questionId = item['id']?.toString() ?? '';
    if (testQuestions[testId]!.any((q) => q['id'] == questionId)) return;

    final opts = item['options'];
    List<String> optionsList = [];
    if (opts is List) optionsList = opts.map((e) => e.toString()).toList();

    int correctIndex = 0;
    final rawCorrect = item['correct_option_index'];
    if (rawCorrect is num) {
      correctIndex = rawCorrect.toInt().clamp(0, 4);
    } else if (rawCorrect is String) {
      final s = rawCorrect.trim().toUpperCase();
      if (s == 'B' || s == '1') correctIndex = 1;
      if (s == 'C' || s == '2') correctIndex = 2;
      if (s == 'D' || s == '3') correctIndex = 3;
      if (s == 'E' || s == '4') correctIndex = 4;
    }

    String correctLetter = 'A';
    if (correctIndex == 1) correctLetter = 'B';
    if (correctIndex == 2) correctLetter = 'C';
    if (correctIndex == 3) correctLetter = 'D';
    if (correctIndex == 4) correctLetter = 'E';

    testQuestions[testId]?.add({
      'id': questionId,
      'question': item['question_text']?.toString() ?? '',
      'optionA': optionsList.isNotEmpty ? optionsList[0] : '',
      'optionB': optionsList.length > 1 ? optionsList[1] : '',
      'optionC': optionsList.length > 2 ? optionsList[2] : '',
      'optionD': optionsList.length > 3 ? optionsList[3] : '',
      'optionE': optionsList.length > 4 ? optionsList[4] : 'પ્રયાસ કરેલ નથી',
      'correct': correctLetter,
      'subject': item['subject']?.toString() ?? 'સામાન્ય જ્ઞાન',
      'topic': item['topic']?.toString() ?? '',
      'explanation': item['explanation']?.toString() ?? '',
      'topic_id': item['topic_id']?.toString(),
    });
  }

  Future<void> fetchSocialLinks() async {
    final docs = await _firestoreList('app_settings');
    for (final doc in docs) {
      if (doc['id'] == 'social_links') {
        socialLinks['website'] = doc['website']?.toString() ?? socialLinks['website']!;
        socialLinks['whatsapp'] = doc['whatsapp']?.toString() ?? socialLinks['whatsapp']!;
        socialLinks['telegram'] = doc['telegram']?.toString() ?? socialLinks['telegram']!;
        socialLinks['youtube'] = doc['youtube']?.toString() ?? socialLinks['youtube']!;
        socialLinks['instagram'] = doc['instagram']?.toString() ?? socialLinks['instagram']!;
      }
    }
  }

  Future<void> loadAllData() async {
    isLoading = true;
    try {
      await Future.wait([
        fetchRealMockTests(),
        fetchRealStudents(),
        fetchRealWithdrawals(),
        fetchRealQuestions(),
        fetchSocialLinks(),
      ]);
    } catch (_) {}
    isLoading = false;
  }

  /// Create new Mock Test in Firestore
  Future<bool> createMockTest({
    required String id,
    required String examId,
    required String title,
    required String description,
    required bool isFree,
    required int durationMinutes,
    required int totalQuestions,
  }) async {
    final success = await _firestoreSet('mock_tests', id, {
      'id': id,
      'exam_id': examId,
      'title': title,
      'description': description,
      'is_free': isFree,
      'duration_minutes': durationMinutes,
      'total_questions': totalQuestions,
      'positive_marks': 1.0,
      'negative_marks': 0.25,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (success) {
      tests.add({
        'id': id,
        'exam': examId == 'psi' ? 'PSI / ASI' : 'કોન્સ્ટેબલ (LRD)',
        'exam_id': examId,
        'title': title,
        'description': description,
        'isFree': isFree,
        'totalMcqs': 0,
        'duration': durationMinutes,
      });
      testQuestions[id] = [];
    }
    return success;
  }

  /// Import full Mock Test with its MCQs in bulk (100, 200 questions etc.)
  /// Maps each question to the mock test AND sets its subject & topic for syllabus integration!
  Future<Map<String, dynamic>> importMockTestWithQuestions({
    required String testId,
    required String examId,
    required String title,
    required String description,
    required bool isFree,
    required int durationMinutes,
    required List<Map<String, dynamic>> rawQuestionsList,
    void Function(int current, int total)? onProgress,
  }) async {
    // 1. Create or overwrite the Mock Test document in Firestore
    final testSuccess = await _firestoreSet('mock_tests', testId, {
      'id': testId,
      'exam_id': examId,
      'title': title,
      'description': description,
      'is_free': isFree,
      'duration_minutes': durationMinutes,
      'total_questions': rawQuestionsList.length,
      'positive_marks': 1.0,
      'negative_marks': 0.25,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (!testSuccess) {
      return {'success': false, 'error': 'મોક ટેસ્ટ Firebase માં સેવ કરી શક્યા નથી.'};
    }

    // Update local tests list
    final existingTestIdx = tests.indexWhere((t) => t['id'] == testId);
    final testEntry = {
      'id': testId,
      'exam': examId == 'psi' ? 'PSI / ASI' : 'કોન્સ્ટેબલ (LRD)',
      'exam_id': examId,
      'title': title,
      'description': description,
      'isFree': isFree,
      'totalMcqs': rawQuestionsList.length,
      'duration': durationMinutes,
    };
    if (existingTestIdx >= 0) {
      tests[existingTestIdx] = testEntry;
    } else {
      tests.add(testEntry);
    }
    testQuestions[testId] = [];

    // 2. Iterate and save all questions
    int savedCount = 0;
    for (int i = 0; i < rawQuestionsList.length; i++) {
      final raw = rawQuestionsList[i];
      final qId = raw['id']?.toString().isNotEmpty == true
          ? raw['id'].toString()
          : '${testId}_q_${i + 1}';

      final qText = (raw['question_text'] ?? raw['question'] ?? '').toString();

      List<String> optionsList = [];
      if (raw['options'] is List) {
        optionsList = (raw['options'] as List).map((e) => e.toString()).toList();
      } else {
        optionsList = [
          (raw['optionA'] ?? raw['option_a'] ?? raw['a'] ?? '').toString(),
          (raw['optionB'] ?? raw['option_b'] ?? raw['b'] ?? '').toString(),
          (raw['optionC'] ?? raw['option_c'] ?? raw['c'] ?? '').toString(),
          (raw['optionD'] ?? raw['option_d'] ?? raw['d'] ?? '').toString(),
        ];
      }

      int correctIdx = 0;
      final rawAns = raw['correct_option_index'] ?? raw['answer'] ?? raw['correct'] ?? raw['answer_index'];
      if (rawAns is num) {
        correctIdx = rawAns.toInt().clamp(0, 4);
      } else if (rawAns is String) {
        final s = rawAns.trim().toUpperCase();
        if (s == 'B' || s == '1') correctIdx = 1;
        else if (s == 'C' || s == '2') correctIdx = 2;
        else if (s == 'D' || s == '3') correctIdx = 3;
        else if (s == 'E' || s == '4') correctIdx = 4;
        else if (int.tryParse(s) != null) correctIdx = int.parse(s).clamp(0, 4);
      }

      final subject = (raw['subject'] ?? raw['subject_name'] ?? 'સામાન્ય જ્ઞાન').toString();
      final topic = (raw['topic'] ?? raw['topic_name'] ?? raw['topic_title'] ?? '').toString();
      final explanation = (raw['explanation'] ?? raw['desc'] ?? '').toString();
      final topicId = (raw['topic_id'] ?? '').toString();

      final questionDoc = {
        'id': qId,
        'test_id': testId,
        'exam_id': examId,
        'question_text': qText,
        'options': optionsList,
        'correct_option_index': correctIdx,
        'explanation': explanation,
        'subject': subject,
        'topic': topic,
        'topic_id': topicId,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Set to Firestore `questions`
      await _firestoreSet('questions', qId, questionDoc);

      // Set mapping to `mock_test_questions`
      final mtqId = 'mtq_${testId}_${i + 1}';
      await _firestoreSet('mock_test_questions', mtqId, {
        'id': mtqId,
        'test_id': testId,
        'question_id': qId,
        'position': i + 1,
        'created_at': DateTime.now().toIso8601String(),
      });

      String correctLetter = 'A';
      if (correctIdx == 1) correctLetter = 'B';
      if (correctIdx == 2) correctLetter = 'C';
      if (correctIdx == 3) correctLetter = 'D';
      if (correctIdx == 4) correctLetter = 'E';

      testQuestions[testId]?.add({
        'id': qId,
        'question': qText,
        'optionA': optionsList.isNotEmpty ? optionsList[0] : '',
        'optionB': optionsList.length > 1 ? optionsList[1] : '',
        'optionC': optionsList.length > 2 ? optionsList[2] : '',
        'optionD': optionsList.length > 3 ? optionsList[3] : '',
        'optionE': optionsList.length > 4 ? optionsList[4] : 'પ્રયાસ કરેલ નથી',
        'correct': correctLetter,
        'subject': subject,
        'topic': topic,
        'explanation': explanation,
        'topic_id': topicId,
      });

      savedCount++;
      if (onProgress != null) {
        onProgress(savedCount, rawQuestionsList.length);
      }
    }

    return {'success': true, 'count': savedCount};
  }

  /// Add single question to Firestore
  Future<bool> addQuestion(String testId, Map<String, dynamic> question) async {
    final questionId = 'q_${DateTime.now().millisecondsSinceEpoch}';

    final optionsList = [
      question['optionA'] ?? '',
      question['optionB'] ?? '',
      question['optionC'] ?? '',
      question['optionD'] ?? '',
    ];
    int correctIdx = 0;
    if (question['correct'] == 'B') correctIdx = 1;
    if (question['correct'] == 'C') correctIdx = 2;
    if (question['correct'] == 'D') correctIdx = 3;
    if (question['correct'] == 'E') correctIdx = 4;

    // 1. Insert into questions collection
    final qSuccess = await _firestoreSet('questions', questionId, {
      'id': questionId,
      'test_id': testId,
      'exam_id': testId.startsWith('psi') ? 'psi' : 'constable',
      'subject': question['subject'] ?? 'સામાન્ય જ્ઞાન',
      'topic': question['topic'] ?? '',
      'question_text': question['question'] ?? '',
      'options': optionsList,
      'correct_option_index': correctIdx,
      'explanation': question['explanation'] ?? '',
      'topic_id': question['topic_id'] ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });

    if (!qSuccess) return false;

    // 2. Map in mock_test_questions collection
    final mtqId = 'mtq_${DateTime.now().millisecondsSinceEpoch}';
    final currentPos = (testQuestions[testId]?.length ?? 0) + 1;
    await _firestoreSet('mock_test_questions', mtqId, {
      'id': mtqId,
      'test_id': testId,
      'question_id': questionId,
      'position': currentPos,
      'created_at': DateTime.now().toIso8601String(),
    });

    final qMap = Map<String, dynamic>.from(question);
    qMap['id'] = questionId;

    testQuestions.putIfAbsent(testId, () => []).add(qMap);

    final testIdx = tests.indexWhere((t) => t['id'] == testId);
    if (testIdx >= 0) {
      tests[testIdx]['totalMcqs'] = testQuestions[testId]?.length ?? 0;
    }

    return true;
  }

  void editQuestion(String testId, int index, Map<String, dynamic> question) {
    if (testQuestions[testId] != null && index < testQuestions[testId]!.length) {
      final existing = testQuestions[testId]![index];
      testQuestions[testId]![index] = question;

      final questionId = existing['id']?.toString();
      if (questionId != null && questionId.isNotEmpty) {
        final optionsList = [
          question['optionA'] ?? '',
          question['optionB'] ?? '',
          question['optionC'] ?? '',
          question['optionD'] ?? '',
        ];
        int correctIdx = 0;
        if (question['correct'] == 'B') correctIdx = 1;
        if (question['correct'] == 'C') correctIdx = 2;
        if (question['correct'] == 'D') correctIdx = 3;
        if (question['correct'] == 'E') correctIdx = 4;

        _firestoreSet('questions', questionId, {
          'subject': question['subject'] ?? 'સામાન્ય જ્ઞાન',
          'topic': question['topic'] ?? '',
          'question_text': question['question'] ?? '',
          'options': optionsList,
          'correct_option_index': correctIdx,
          'explanation': question['explanation'] ?? '',
        });
      }
    }
  }

  void deleteQuestion(String testId, int index) {
    if (testQuestions[testId] != null && index < testQuestions[testId]!.length) {
      final q = testQuestions[testId]!.removeAt(index);
      final questionId = q['id']?.toString();
      if (questionId != null && questionId.isNotEmpty) {
        _firestoreDelete('questions', questionId);
      }
      final testIdx = tests.indexWhere((t) => t['id'] == testId);
      if (testIdx >= 0) {
        tests[testIdx]['totalMcqs'] = testQuestions[testId]?.length ?? 0;
      }
    }
  }

  void updateStudentCoins(int index, int delta) {
    if (index >= 0 && index < students.length) {
      final student = students[index];
      final newCoins = ((student['coins'] as int? ?? 0) + delta).clamp(0, 99999);
      student['coins'] = newCoins;

      final studentId = student['id']?.toString();
      if (studentId != null && studentId.isNotEmpty) {
        _firestoreSet('profiles', studentId, {'coins': newCoins});
        _firestoreSet('users', studentId, {'coins': newCoins});
      }
    }
  }

  Future<void> updateWithdrawalStatus(String id, String newStatus) async {
    final idx = withdrawals.indexWhere((w) => w['id'] == id);
    if (idx != -1) {
      withdrawals[idx]['status'] = newStatus == 'approved' ? 'મંજૂર થયેલ (Paid) ✅' : 'અસ્વીકાર (Rejected) ❌';
      withdrawals[idx]['isPending'] = false;
    }
    await _firestoreSet('withdrawals', id, {'status': newStatus});
  }

  void toggleTestFree(int index) {
    if (index >= 0 && index < tests.length) {
      final current = tests[index]['isFree'] as bool? ?? false;
      tests[index]['isFree'] = !current;
      final testId = tests[index]['id']?.toString();
      if (testId != null) {
        _firestoreSet('mock_tests', testId, {'is_free': !current});
      }
    }
  }

  Future<bool> saveSocialLinks(Map<String, String> newLinks) async {
    socialLinks = Map.from(newLinks);
    await _firestoreSet('app_settings', 'social_links', socialLinks);
    return true;
  }

  Future<bool> broadcastNotification(String title, String message, String type) async {
    final docId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    await _firestoreSet('notifications', docId, {
      'id': docId,
      'title': title,
      'message': message,
      'type': type,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    });
    return true;
  }
}
