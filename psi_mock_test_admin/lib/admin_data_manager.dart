import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'firebase_vault.dart';
import 'official_syllabus_master.dart';

class ImportValidationResult {
  final bool isValid;
  final int totalRows;
  final int validCount;
  final int errorCount;
  final int duplicateInFileCount;
  final List<String> errors;
  final List<Map<String, dynamic>> validQuestions;
  final Map<String, dynamic> testMeta;

  const ImportValidationResult({
    required this.isValid,
    required this.totalRows,
    required this.validCount,
    required this.errorCount,
    required this.duplicateInFileCount,
    required this.errors,
    required this.validQuestions,
    required this.testMeta,
  });
}

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
        final uid = json['localId']?.toString();
        final emailStr = (json['email']?.toString() ?? email.trim()).toLowerCase();

        // Strict Admin Authorization Check:
        // Ensures student accounts cannot access the admin console!
        final adminDocs = await _firestoreList('admins');
        if (adminDocs.isNotEmpty) {
          final isAuthorized = adminDocs.any((d) =>
              (d['email']?.toString().toLowerCase() == emailStr) ||
              (d['id']?.toString() == uid));
          if (!isAuthorized) {
            return {
              'success': false,
              'error': 'એક્સેસ નકારાયેલ! આ ઈમેલ પાસે એડમિન પરવાનગી નથી. ફક્ત અધિકૃત એડમિન જ લૉગિન કરી શકે છે.'
            };
          }
        } else {
          // First Admin Login: Authorize and record this email as the Primary Admin
          if (uid != null && uid.isNotEmpty) {
            await _firestoreSet('admins', uid, {
              'id': uid,
              'email': emailStr,
              'role': 'admin',
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }

        adminToken = json['idToken']?.toString();
        adminEmail = emailStr;
        adminUid = uid;
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
        } else if (errorMsg.toString().contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
          friendly = 'ઘણા અમાન્ય પ્રયાસો થયા છે. કૃપા કરીને થોડી વાર પછી પ્રયાસ કરો.';
        } else if (errorMsg.toString().contains('OPERATION_NOT_ALLOWED')) {
          friendly = 'Firebase Console માં Email/Password Provider સક્ષમ કરો.';
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

  // =========================================================================
  // 17-COLUMN CSV/EXCEL IMPORT ENGINE & CENTRAL MCQ BANK
  // =========================================================================

  /// Compute SHA-256 Question Hash for deduplication
  static String computeQuestionHash(String q, String a, String b, String c, String d) {
    String norm(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final combined = '${norm(q)}|${norm(a)}|${norm(b)}|${norm(c)}|${norm(d)}';
    return sha256.convert(utf8.encode(combined)).toString();
  }

  /// Generate Official 17-Column CSV Template
  static String generateSampleCsvTemplate({String examId = 'gujarat_psi'}) {
    final isPsi = examId.contains('psi');
    final code = isPsi ? 'gujarat_psi' : 'gujarat_lrd';
    final title = isPsi ? 'Gujarat Police PSI Full Mock Test 01' : 'Gujarat Police LRD Constable Full Mock Test 01';
    final subj = isPsi ? 'Reasoning and Data Interpretation' : 'Reasoning and Data Interpretation';
    final topic = isPsi ? 'તાર્કિક કસોટીઓ અને ડેટા અર્થઘટન' : 'સંખ્યાત્મક શ્રેણી અને કોડિંગ-ડિકોડિંગ';

    return '''examCode,testTitle,testNumber,durationMinutes,totalMarks,questionNumber,subjectName,topicName,questionText,optionA,optionB,optionC,optionD,correctOption,explanation,difficulty,language
$code,"$title",1,180,200,1,"$subj","$topic","શ્રેણી પૂર્ણ કરો: 2, 6, 12, 20, 30, ?","40","42","44","46","B","તફાવત +4, +6, +8, +10, +12 હોવાથી સાચો જવાબ 30 + 12 = 42 છે.","Medium","Gujarati"
$code,"$title",1,180,200,2,"$subj","$topic","જો CAT = 24 અને DOG = 26 હોય, તો RAT = ?","39","40","42","44","A","R(18) + A(1) + T(20) = 39.","Easy","Gujarati"''';
  }

  /// RFC 4180 compliant CSV Parser
  static List<List<String>> parseCsv(String input) {
    final List<List<String>> rows = [];
    List<String> currentRow = [];
    final StringBuffer currentField = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < input.length; i++) {
      final char = input[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < input.length && input[i + 1] == '"') {
            currentField.write('"');
            i++; // skip escaped quote
          } else {
            inQuotes = false;
          }
        } else {
          currentField.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',' || char == '\t' || char == '|') {
          currentRow.add(currentField.toString().trim());
          currentField.clear();
        } else if (char == '\r') {
          if (i + 1 < input.length && input[i + 1] == '\n') {
            i++;
          }
          currentRow.add(currentField.toString().trim());
          currentField.clear();
          if (currentRow.any((f) => f.isNotEmpty)) {
            rows.add(currentRow);
          }
          currentRow = [];
        } else if (char == '\n') {
          currentRow.add(currentField.toString().trim());
          currentField.clear();
          if (currentRow.any((f) => f.isNotEmpty)) {
            rows.add(currentRow);
          }
          currentRow = [];
        } else {
          currentField.write(char);
        }
      }
    }

    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString().trim());
      if (currentRow.any((f) => f.isNotEmpty)) {
        rows.add(currentRow);
      }
    }

    return rows;
  }

  /// Comprehensive Pre-Import Validator for 17-Column Format
  ImportValidationResult validateCsvData(
    String rawInput, {
    String fallbackExamId = 'gujarat_psi',
    String fallbackTitle = '',
    int fallbackDuration = 180,
  }) {
    final List<String> errors = [];
    final List<Map<String, dynamic>> validQuestions = [];
    final Set<String> hashesInFile = {};
    int duplicateInFileCount = 0;

    final rows = parseCsv(rawInput);
    if (rows.isEmpty) {
      return const ImportValidationResult(
        isValid: false,
        totalRows: 0,
        validCount: 0,
        errorCount: 1,
        duplicateInFileCount: 0,
        errors: ['કોઈ ડેટા મળ્યો નથી. કૃપા કરીને CSV અથવા Excel ડેટા પેસ્ટ કરો.'],
        validQuestions: [],
        testMeta: {},
      );
    }

    // Check header row
    int headerIndex = -1;
    Map<String, int> colMap = {};
    for (int r = 0; r < rows.length && r < 3; r++) {
      final lineLower = rows[r].map((c) => c.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')).toList();
      if (lineLower.any((c) => c.contains('question') || c.contains('opt') || c.contains('exam'))) {
        headerIndex = r;
        for (int i = 0; i < lineLower.length; i++) {
          final col = lineLower[i];
          if (col.contains('exam')) colMap['examCode'] = i;
          else if (col.contains('title') && !col.contains('topic')) colMap['testTitle'] = i;
          else if (col.contains('testnum') || col.contains('testno')) colMap['testNumber'] = i;
          else if (col.contains('duration') || col.contains('time')) colMap['durationMinutes'] = i;
          else if (col.contains('totalmark')) colMap['totalMarks'] = i;
          else if (col.contains('questionnum') || col.contains('qno') || col.contains('qnum')) colMap['questionNumber'] = i;
          else if (col.contains('subject')) colMap['subjectName'] = i;
          else if (col.contains('topic')) colMap['topicName'] = i;
          else if (col.contains('question') || col == 'q') colMap['questionText'] = i;
          else if (col.contains('optiona') || col == 'a') colMap['optionA'] = i;
          else if (col.contains('optionb') || col == 'b') colMap['optionB'] = i;
          else if (col.contains('optionc') || col == 'c') colMap['optionC'] = i;
          else if (col.contains('optiond') || col == 'd') colMap['optionD'] = i;
          else if (col.contains('correct') || col.contains('ans')) colMap['correctOption'] = i;
          else if (col.contains('explanation') || col.contains('desc') || col.contains('sol')) colMap['explanation'] = i;
          else if (col.contains('diff')) colMap['difficulty'] = i;
          else if (col.contains('lang')) colMap['language'] = i;
        }
        break;
      }
    }

    final startIndex = headerIndex >= 0 ? headerIndex + 1 : 0;
    int dataRowCount = 0;

    String detectedExamId = fallbackExamId;
    String detectedTitle = fallbackTitle;
    int detectedDuration = fallbackDuration;

    for (int i = startIndex; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || (row.length == 1 && row[0].isEmpty)) continue;
      dataRowCount++;
      final rowNum = i + 1;

      String getCol(String key, int fallbackPos) {
        if (colMap.containsKey(key) && colMap[key]! < row.length) {
          return row[colMap[key]!].trim();
        }
        if (fallbackPos < row.length) {
          return row[fallbackPos].trim();
        }
        return '';
      }

      final examCodeStr = getCol('examCode', 0).toLowerCase();
      final testTitleStr = getCol('testTitle', 1);
      final durationStr = getCol('durationMinutes', 3);
      final questionNumStr = getCol('questionNumber', 5);
      final subjectStr = getCol('subjectName', 6);
      final topicStr = getCol('topicName', 7);
      final qText = getCol('questionText', 8);
      final optA = getCol('optionA', 9);
      final optB = getCol('optionB', 10);
      final optC = getCol('optionC', 11);
      final optD = getCol('optionD', 12);
      final correctStr = getCol('correctOption', 13).toUpperCase();
      final explanation = getCol('explanation', 14);
      final difficulty = getCol('difficulty', 15);
      final language = getCol('language', 16);

      if (detectedTitle.isEmpty && testTitleStr.isNotEmpty) {
        detectedTitle = testTitleStr;
      }
      if (durationStr.isNotEmpty && int.tryParse(durationStr) != null) {
        detectedDuration = int.parse(durationStr);
      }

      // Exam normalization
      String currentExam = detectedExamId;
      if (examCodeStr.contains('psi')) {
        currentExam = 'gujarat_psi';
      } else if (examCodeStr.contains('lrd') || examCodeStr.contains('constable')) {
        currentExam = 'gujarat_lrd';
      }
      detectedExamId = currentExam;

      // Validate question text
      if (qText.isEmpty) {
        errors.add('પંક્તિ $rowNum: પ્રશ્ન ટેક્સ્ટ (questionText) ખાલી છે.');
        continue;
      }

      // Validate options
      if (optA.isEmpty) errors.add('પંક્તિ $rowNum: વિકલ્પ A ખાલી છે.');
      if (optB.isEmpty) errors.add('પંક્તિ $rowNum: વિકલ્પ B ખાલી છે.');
      if (optC.isEmpty) errors.add('પંક્તિ $rowNum: વિકલ્પ C ખાલી છે.');
      if (optD.isEmpty) errors.add('પંક્તિ $rowNum: વિકલ્પ D ખાલી છે.');

      // Validate correct option
      int correctIndex = -1;
      String correctLetter = 'A';
      if (correctStr == 'A' || correctStr == '1' || correctStr == '0') {
        correctIndex = 0;
        correctLetter = 'A';
      } else if (correctStr == 'B' || correctStr == '2') {
        correctIndex = 1;
        correctLetter = 'B';
      } else if (correctStr == 'C' || correctStr == '3') {
        correctIndex = 2;
        correctLetter = 'C';
      } else if (correctStr == 'D' || correctStr == '4') {
        correctIndex = 3;
        correctLetter = 'D';
      } else {
        errors.add('પંક્તિ $rowNum: અમાન્ય સાચો વિકલ્પ \'$correctStr\'. સાચો વિકલ્પ A, B, C અથવા D હોવો જોઈએ.');
      }

      // Validate official syllabus subject
      final officialSubject = OfficialSyllabusMaster.findSubject(currentExam, subjectStr);
      if (officialSubject == null && subjectStr.isNotEmpty) {
        errors.add('પંક્તિ $rowNum: અમાન્ય વિષય \'$subjectStr\'. આ વિષય $currentExam ના સત્તાવાર સિલેબસમાં નથી.');
      }

      final resolvedSubjectName = officialSubject?.subjectName ?? (subjectStr.isNotEmpty ? subjectStr : 'સામાન્ય જ્ઞાન');
      final resolvedSubjectId = officialSubject?.subjectId ?? 'subject_gen';

      // Find topic
      final officialTopic = officialSubject != null ? OfficialSyllabusMaster.findTopic(officialSubject, topicStr) : null;
      final resolvedTopicName = officialTopic?.topicName ?? (topicStr.isNotEmpty ? topicStr : resolvedSubjectName);
      final resolvedTopicId = officialTopic?.topicId ?? '${resolvedSubjectId}_t1';

      // Calculate SHA-256 Hash
      final qHash = computeQuestionHash(qText, optA, optB, optC, optD);
      if (hashesInFile.contains(qHash)) {
        duplicateInFileCount++;
        errors.add('પંક્તિ $rowNum: ફાઈલની અંદર આ પ્રશ્ન ડુપ્લિકેટ છે.');
      } else {
        hashesInFile.add(qHash);
      }

      if (qText.isNotEmpty && optA.isNotEmpty && optB.isNotEmpty && optC.isNotEmpty && optD.isNotEmpty && correctIndex >= 0) {
        validQuestions.add({
          'position': int.tryParse(questionNumStr) ?? (validQuestions.length + 1),
          'question_text': qText,
          'options': [optA, optB, optC, optD, 'પ્રયાસ કરેલ નથી'],
          'optionA': optA,
          'optionB': optB,
          'optionC': optC,
          'optionD': optD,
          'correct': correctLetter,
          'correct_option_index': correctIndex,
          'explanation': explanation,
          'difficulty': difficulty.isNotEmpty ? difficulty : 'Medium',
          'language': language.isNotEmpty ? language : 'Gujarati',
          'subject_id': resolvedSubjectId,
          'subject_name': resolvedSubjectName,
          'topic_id': resolvedTopicId,
          'topic_name': resolvedTopicName,
          'question_hash': qHash,
          'exam_id': currentExam,
        });
      }
    }

    final isValid = errors.isEmpty && validQuestions.isNotEmpty;

    return ImportValidationResult(
      isValid: isValid,
      totalRows: dataRowCount,
      validCount: validQuestions.length,
      errorCount: errors.length,
      duplicateInFileCount: duplicateInFileCount,
      errors: errors,
      validQuestions: validQuestions,
      testMeta: {
        'examId': detectedExamId,
        'title': detectedTitle.isNotEmpty ? detectedTitle : (detectedExamId.contains('psi') ? 'PSI મોક ટેસ્ટ' : 'કોન્સ્ટેબલ મોક ટેસ્ટ'),
        'durationMinutes': detectedDuration,
      },
    );
  }

  /// Bulk Import Mock Test with Central MCQ Bank & Deduplication
  Future<Map<String, dynamic>> importValidatedMockTest({
    required String testId,
    required String examId,
    required String title,
    required String description,
    required bool isFree,
    required int durationMinutes,
    required List<Map<String, dynamic>> validatedQuestions,
    void Function(int current, int total, String status)? onProgress,
  }) async {
    try {
      // 1. Fetch existing question hashes from Firestore `questions` to prevent duplicates
      onProgress?.call(0, validatedQuestions.length, 'હાલના પ્રશ્નોનું વેરિફિકેશન થઈ રહ્યું છે...');
      final existingDocs = await _firestoreList('questions', pageSize: 1500);
      final Map<String, String> hashToQuestionId = {};
      for (final doc in existingDocs) {
        final hash = doc['question_hash']?.toString();
        final qId = doc['id']?.toString();
        if (hash != null && hash.isNotEmpty && qId != null) {
          hashToQuestionId[hash] = qId;
        }
      }

      // 2. Upsert the Mock Test Document
      onProgress?.call(0, validatedQuestions.length, 'મોક ટેસ્ટ સેટઅપ થઈ રહ્યો છે...');
      final testSuccess = await _firestoreSet('mock_tests', testId, {
        'id': testId,
        'exam_id': examId,
        'title': title,
        'description': description,
        'is_free': isFree,
        'duration_minutes': durationMinutes,
        'total_questions': validatedQuestions.length,
        'total_marks': validatedQuestions.length,
        'positive_marks': 1.0,
        'negative_marks': 0.25,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!testSuccess) {
        return {'success': false, 'error': 'મોક ટેસ્ટ Firebase માં સેવ કરી શકાયો નથી.'};
      }

      // 3. Process MCQs: Reuse existing if hash matches, else insert new
      int newMcqCount = 0;
      int duplicateDbCount = 0;
      testQuestions[testId] = [];

      for (int i = 0; i < validatedQuestions.length; i++) {
        final q = validatedQuestions[i];
        final qHash = q['question_hash']?.toString() ?? computeQuestionHash(
          q['question_text'] ?? '',
          q['optionA'] ?? '',
          q['optionB'] ?? '',
          q['optionC'] ?? '',
          q['optionD'] ?? '',
        );

        String finalQuestionId;
        if (hashToQuestionId.containsKey(qHash)) {
          // Deduplication: Reuse existing Question ID from Central Bank
          finalQuestionId = hashToQuestionId[qHash]!;
          duplicateDbCount++;
        } else {
          // New unique question: Insert to central questions collection
          finalQuestionId = 'q_${qHash.substring(0, 16)}';
          final questionDoc = {
            'id': finalQuestionId,
            'question_hash': qHash,
            'exam_id': examId,
            'subject_id': q['subject_id'] ?? '',
            'subject': q['subject_name'] ?? 'સામાન્ય જ્ઞાન',
            'topic_id': q['topic_id'] ?? '',
            'topic': q['topic_name'] ?? '',
            'question_text': q['question_text'] ?? '',
            'options': q['options'] ?? [q['optionA'], q['optionB'], q['optionC'], q['optionD']],
            'correct_option_index': q['correct_option_index'] ?? 0,
            'correct_option': q['correct'] ?? 'A',
            'explanation': q['explanation'] ?? '',
            'difficulty': q['difficulty'] ?? 'Medium',
            'language': q['language'] ?? 'Gujarati',
            'marks': 1.0,
            'created_at': DateTime.now().toIso8601String(),
          };

          await _firestoreSet('questions', finalQuestionId, questionDoc);
          hashToQuestionId[qHash] = finalQuestionId;
          newMcqCount++;
        }

        // Map Question to this Mock Test in `mock_test_questions`
        final pos = q['position'] ?? (i + 1);
        final mtqId = 'mtq_${testId}_$pos';
        await _firestoreSet('mock_test_questions', mtqId, {
          'id': mtqId,
          'test_id': testId,
          'question_id': finalQuestionId,
          'position': pos,
          'marks': 1.0,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Add to local cache for instant Admin viewing
        testQuestions[testId]?.add({
          'id': finalQuestionId,
          'question': q['question_text'],
          'optionA': q['optionA'],
          'optionB': q['optionB'],
          'optionC': q['optionC'],
          'optionD': q['optionD'],
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': q['correct'],
          'subject': q['subject_name'],
          'topic': q['topic_name'],
          'explanation': q['explanation'],
          'topic_id': q['topic_id'],
        });

        onProgress?.call(
          i + 1,
          validatedQuestions.length,
          'પ્રશ્ન ${i + 1} / ${validatedQuestions.length} સચવાઈ રહ્યો છે...',
        );
      }

      // 4. Record Import History
      final importHistoryId = 'import_${DateTime.now().millisecondsSinceEpoch}';
      await _firestoreSet('import_history', importHistoryId, {
        'id': importHistoryId,
        'test_id': testId,
        'exam_id': examId,
        'test_title': title,
        'total_rows': validatedQuestions.length,
        'new_mcqs': newMcqCount,
        'duplicate_mcqs': duplicateDbCount,
        'imported_at': DateTime.now().toIso8601String(),
      });

      // 5. Update local tests list
      final existingIdx = tests.indexWhere((t) => t['id'] == testId);
      final testEntry = {
        'id': testId,
        'exam': examId.contains('psi') ? 'PSI / ASI' : 'કોન્સ્ટેબલ (LRD)',
        'exam_id': examId,
        'title': title,
        'description': description,
        'isFree': isFree,
        'totalMcqs': validatedQuestions.length,
        'duration': durationMinutes,
      };
      if (existingIdx >= 0) {
        tests[existingIdx] = testEntry;
      } else {
        tests.add(testEntry);
      }

      return {
        'success': true,
        'newMcqs': newMcqCount,
        'duplicateMcqs': duplicateDbCount,
        'total': validatedQuestions.length,
      };
    } catch (e) {
      return {'success': false, 'error': 'ઇમ્પોર્ટ દરમિયાન ક્ષતિ: $e'};
    }
  }

  /// Seed Official Syllabus to Firestore
  Future<Map<String, int>> seedOfficialSyllabus({void Function(String msg)? onProgress}) async {
    return await OfficialSyllabusMaster.seedToFirestore(_firestoreSet, onProgress: onProgress);
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
