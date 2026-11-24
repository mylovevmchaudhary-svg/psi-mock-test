import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';
import '../models/syllabus_model.dart';
import '../models/user_model.dart';
import 'firebase_vault.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static String get projectId => FirebaseVault.projectId;
  static String get apiKey => FirebaseVault.apiKey;
  static String get authUrl => FirebaseVault.authBaseUrl;
  static String get firestoreUrl => FirebaseVault.firestoreBaseUrl;

  final UserModel _user = UserModel();

  // =========================================================================
  // FIRESTORE ENCODING & DECODING HELPERS (Standard Cloud Firestore REST API)
  // =========================================================================

  /// Encodes Dart value to Firestore Typed Field format
  static Map<String, dynamic> _encodeValue(dynamic val) {
    if (val == null) return {'nullValue': null};
    if (val is bool) return {'booleanValue': val};
    if (val is int) return {'integerValue': val.toString()};
    if (val is double) return {'doubleValue': val};
    if (val is String) return {'stringValue': val};
    if (val is List) {
      return {
        'arrayValue': {
          'values': val.map((e) => _encodeValue(e)).toList(),
        }
      };
    }
    if (val is Map) {
      final Map<String, dynamic> fields = {};
      val.forEach((k, v) {
        fields[k.toString()] = _encodeValue(v);
      });
      return {
        'mapValue': {'fields': fields}
      };
    }
    return {'stringValue': val.toString()};
  }

  /// Encodes Dart map to Firestore document fields
  static Map<String, dynamic> _encodeDoc(Map<String, dynamic> data) {
    final Map<String, dynamic> fields = {};
    data.forEach((k, v) {
      fields[k] = _encodeValue(v);
    });
    return {'fields': fields};
  }

  /// Decodes Firestore Typed Field format to standard Dart value
  static dynamic _decodeValue(Map<String, dynamic> valMap) {
    if (valMap.containsKey('stringValue')) return valMap['stringValue'];
    if (valMap.containsKey('integerValue')) {
      return int.tryParse(valMap['integerValue'].toString()) ?? 0;
    }
    if (valMap.containsKey('doubleValue')) {
      return (valMap['doubleValue'] as num?)?.toDouble() ?? 0.0;
    }
    if (valMap.containsKey('booleanValue')) {
      return valMap['booleanValue'] == true;
    }
    if (valMap.containsKey('arrayValue')) {
      final list = valMap['arrayValue']?['values'];
      if (list is List) {
        return list.map((e) => _decodeValue(e as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (valMap.containsKey('mapValue')) {
      final fields = valMap['mapValue']?['fields'];
      if (fields is Map<String, dynamic>) {
        final Map<String, dynamic> res = {};
        fields.forEach((k, v) {
          if (v is Map<String, dynamic>) res[k] = _decodeValue(v);
        });
        return res;
      }
      return {};
    }
    if (valMap.containsKey('nullValue')) return null;
    return null;
  }

  /// Decodes raw Firestore document to standard Dart Map
  static Map<String, dynamic> _decodeDoc(Map<String, dynamic> doc) {
    final Map<String, dynamic> res = {};
    final name = doc['name']?.toString() ?? '';
    if (name.isNotEmpty) {
      final segments = name.split('/');
      if (segments.isNotEmpty) {
        res['id'] = segments.last;
      }
    }
    final fields = doc['fields'];
    if (fields is Map<String, dynamic>) {
      fields.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          res[k] = _decodeValue(v);
        }
      });
    }
    return res;
  }

  // =========================================================================
  // GENERIC FIRESTORE REST CALLS
  // =========================================================================

  /// Get single document from Firestore
  Future<Map<String, dynamic>?> _firestoreGetDoc(String collection, String docId) async {
    try {
      final uri = Uri.parse('$firestoreUrl/$collection/$docId?key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonDoc = jsonDecode(body);
        return _decodeDoc(jsonDoc);
      }
    } catch (e) {
      debugPrint('[FirebaseService] GET $collection/$docId error: $e');
    }
    return null;
  }

  /// List documents in a Firestore collection
  Future<List<Map<String, dynamic>>> _firestoreListDocs(String collection, {int pageSize = 300}) async {
    final List<Map<String, dynamic>> docs = [];
    try {
      final uri = Uri.parse('$firestoreUrl/$collection?pageSize=$pageSize&key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResp = jsonDecode(body);
        final rawDocs = jsonResp['documents'];
        if (rawDocs is List) {
          for (final d in rawDocs) {
            if (d is Map<String, dynamic>) {
              docs.add(_decodeDoc(d));
            }
          }
        }
      } else {
        debugPrint('[FirebaseService] List $collection failed [Status ${response.statusCode}]: $body');
      }
    } catch (e) {
      debugPrint('[FirebaseService] List $collection network error: $e');
    }
    return docs;
  }

  /// Query documents with a field filter in Firestore
  Future<List<Map<String, dynamic>>> _firestoreQuery(String collection, {required String field, required dynamic value}) async {
    final List<Map<String, dynamic>> results = [];
    try {
      final uri = Uri.parse('https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents:runQuery?key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final queryPayload = {
        'structuredQuery': {
          'from': [{'collectionId': collection}],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': field},
              'op': 'EQUAL',
              'value': _encodeValue(value),
            }
          }
        }
      };

      request.write(jsonEncode(queryPayload));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(body);
        if (decoded is List) {
          for (final item in decoded) {
            final doc = item['document'];
            if (doc is Map<String, dynamic>) {
              results.add(_decodeDoc(doc));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[FirebaseService] Query on $collection error: $e');
    }
    return results;
  }

  /// Upsert document in Firestore
  Future<bool> _firestoreSetDoc(String collection, String docId, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$firestoreUrl/$collection/$docId?key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.patchUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final payload = _encodeDoc(data);
      request.write(jsonEncode(payload));
      final response = await request.close();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('[FirebaseService] SetDoc $collection/$docId error: $e');
      return false;
    }
  }

  // =========================================================================
  // FIREBASE AUTHENTICATION (SignUp & SignIn)
  // =========================================================================

  /// Real Firebase Authentication: Sign Up
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    int initialCoins = 30;
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      initialCoins += 20; // +50 total with referral bonus
    }

    try {
      final uri = Uri.parse('$authUrl/accounts:signUp?key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final authBody = {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      };

      request.write(jsonEncode(authBody));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> jsonResponse = jsonDecode(body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userId = jsonResponse['localId']?.toString();

        // Save student profile to Cloud Firestore `profiles` and `users` collections
        if (userId != null && userId.isNotEmpty) {
          final userProfile = {
            'id': userId,
            'name': name,
            'email': email,
            'coins': initialCoins,
            'my_referral_code': _user.myReferralCode,
            'referred_by': referralCode ?? '',
            'created_at': DateTime.now().toIso8601String(),
            'is_active': true,
          };
          await _firestoreSetDoc('profiles', userId, userProfile);
          await _firestoreSetDoc('users', userId, userProfile);
        }

        _user.register(userName: name, userEmail: email, referralCode: referralCode, uid: userId);
        _user.setCoins(initialCoins);

        return {'success': true, 'userId': userId};
      } else {
        final errorObj = jsonResponse['error'];
        final errorMsg = errorObj is Map ? (errorObj['message'] ?? 'Sign up failed') : 'Sign up failed';
        String friendly = 'નોંધણી નિષ્ફળ થઈ.';
        if (errorMsg.toString().contains('EMAIL_EXISTS')) {
          friendly = 'આ ઈમેલ પહેલેથી નોંધાયેલ છે.';
        } else if (errorMsg.toString().contains('OPERATION_NOT_ALLOWED')) {
          friendly = 'Firebase માં ઈમેલ/પાસવર્ડ ઓથોરાઈઝેશન સક્ષમ કરો.';
        }
        return {'success': false, 'error': friendly};
      }
    } catch (e) {
      debugPrint('[FirebaseService] SignUp error: $e');
      return {'success': false, 'error': 'નેટવર્ક કનેક્શન તપાસો: $e'};
    }
  }

  /// Real Firebase Authentication: Sign In
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$authUrl/accounts:signInWithPassword?key=$apiKey');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      final authBody = {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      };

      request.write(jsonEncode(authBody));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> jsonResponse = jsonDecode(body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userId = jsonResponse['localId']?.toString();

        // Fetch user profile from Firestore `profiles` collection
        String nameToSet = email.split('@').first;
        int coinsToSet = 30;

        if (userId != null && userId.isNotEmpty) {
          final profileDoc = await _firestoreGetDoc('profiles', userId) ??
              await _firestoreGetDoc('users', userId);
          if (profileDoc != null) {
            final remoteCoins = (profileDoc['coins'] as num?)?.toInt();
            final remoteName = profileDoc['name']?.toString();
            if (remoteCoins != null) coinsToSet = remoteCoins;
            if (remoteName != null && remoteName.isNotEmpty) nameToSet = remoteName;
          } else {
            // Upsert initial profile if first login
            final initialData = {
              'id': userId,
              'name': nameToSet,
              'email': email,
              'coins': coinsToSet,
              'my_referral_code': _user.myReferralCode,
              'created_at': DateTime.now().toIso8601String(),
              'is_active': true,
            };
            await _firestoreSetDoc('profiles', userId, initialData);
            await _firestoreSetDoc('users', userId, initialData);
          }
        }

        _user.login(userEmail: email, userName: nameToSet, uid: userId);
        _user.name = nameToSet;
        _user.setCoins(coinsToSet);

        return {'success': true, 'userId': userId, 'data': jsonResponse};
      } else {
        final errorObj = jsonResponse['error'];
        final errorMsg = errorObj is Map ? (errorObj['message'] ?? 'Login failed') : 'Login failed';
        String friendly = 'અમાન્ય ઈમેલ અથવા પાસવર્ડ.';
        if (errorMsg.toString().contains('EMAIL_NOT_FOUND')) {
          friendly = 'આ ઈમેલથી કોઈ ખાતું મળ્યું નથી.';
        } else if (errorMsg.toString().contains('INVALID_PASSWORD') || errorMsg.toString().contains('INVALID_LOGIN_CREDENTIALS')) {
          friendly = 'પાસવર્ડ ખોટો છે.';
        }
        return {'success': false, 'error': friendly};
      }
    } catch (e) {
      debugPrint('[FirebaseService] SignIn error: $e');
      return {'success': false, 'error': 'કૃપા કરીને ઇન્ટરનેટ કનેક્શન તપાસો.'};
    }
  }

  /// Synchronize coins to Firestore profile
  Future<void> syncCoinsToDatabase(String email, int coins) async {
    final uid = _user.userId;
    if (uid != null && uid.isNotEmpty) {
      await _firestoreSetDoc('profiles', uid, {'coins': coins});
    }
  }

  // =========================================================================
  // QUESTIONS & MOCK TESTS DATA LOGIC
  // =========================================================================

  Question _mapToQuestion(Map<String, dynamic> item) {
    final opts = item['options'];
    List<String> optionsList = [];
    if (opts is List) {
      optionsList = opts.map((e) => e.toString()).toList();
    }
    if (optionsList.length == 4) {
      optionsList.add('પ્રયાસ કરેલ નથી');
    }

    int correctIdx = 0;
    final rawCorrect = item['correct_option_index'];
    if (rawCorrect is num) {
      correctIdx = rawCorrect.toInt().clamp(0, 4);
    } else if (rawCorrect is String) {
      final s = rawCorrect.trim().toUpperCase();
      if (s == 'A' || s == '0') correctIdx = 0;
      if (s == 'B' || s == '1') correctIdx = 1;
      if (s == 'C' || s == '2') correctIdx = 2;
      if (s == 'D' || s == '3') correctIdx = 3;
      if (s == 'E' || s == '4') correctIdx = 4;
    }

    return Question(
      id: item['id']?.toString() ?? '',
      subject: item['subject']?.toString() ?? 'સામાન્ય જ્ઞાન',
      questionText: item['question_text']?.toString() ?? '',
      options: optionsList,
      correctOptionIndex: correctIdx,
      explanation: item['explanation']?.toString() ?? '',
      topicId: item['topic_id']?.toString(),
      examId: item['exam_id']?.toString(),
      difficulty: item['difficulty']?.toString(),
    );
  }

  /// Fetch all Mock Tests from Firestore `mock_tests` collection
  Future<List<MockTest>> fetchMockTests({String? examId}) async {
    final docs = await _firestoreListDocs('mock_tests');
    final List<Map<String, dynamic>> mtqDocs = await _firestoreListDocs('mock_test_questions', pageSize: 1000);

    // Count questions per test_id
    final Map<String, int> counts = {};
    for (final mtq in mtqDocs) {
      final tId = mtq['test_id']?.toString();
      if (tId != null && tId.isNotEmpty) {
        counts[tId] = (counts[tId] ?? 0) + 1;
      }
    }

    if (docs.isNotEmpty) {
      final List<MockTest> list = [];
      for (final item in docs) {
        final tExamId = item['exam_id']?.toString() ?? 'constable';
        if (examId != null && examId.isNotEmpty && tExamId != examId) {
          continue;
        }

        final tId = item['id']?.toString() ?? '';
        final isFreeVal = item['is_free'] == true;
        final actualCount = counts[tId] ?? 0;

        list.add(MockTest(
          id: tId,
          title: item['title']?.toString() ?? 'મોક ટેસ્ટ',
          description: item['description']?.toString() ?? '',
          category: isFreeVal ? 'Free Mock' : 'Premium Mock',
          durationMinutes: (item['duration_minutes'] as num?)?.toInt() ?? 180,
          positiveMarksPerQuestion: (item['positive_marks'] as num?)?.toDouble() ?? 1.0,
          negativeMarksPerQuestion: (item['negative_marks'] as num?)?.toDouble() ?? 0.25,
          isFree: isFreeVal,
          dbTotalQuestions: (item['total_questions'] as num?)?.toInt() ?? 200,
          actualMcqCount: actualCount,
          examId: tExamId,
          questions: [],
        ));
      }
      return list;
    }

    // Return empty list when no tests exist in Firebase Firestore (Zero hardcoded mock tests)
    return [];
  }

  /// Fetch all questions for a Mock Test from Firestore
  Future<List<Question>> fetchAllQuestionsForTest(String testId) async {
    final List<Question> collected = [];

    // 1. Fetch assignment records from mock_test_questions
    final mtqList = await _firestoreQuery('mock_test_questions', field: 'test_id', value: testId);

    if (mtqList.isNotEmpty) {
      // Sort by position
      mtqList.sort((a, b) {
        final posA = (a['position'] as num?)?.toInt() ?? 0;
        final posB = (b['position'] as num?)?.toInt() ?? 0;
        return posA.compareTo(posB);
      });

      for (final mtq in mtqList) {
        final qId = mtq['question_id']?.toString();
        if (qId != null && qId.isNotEmpty) {
          final qDoc = await _firestoreGetDoc('questions', qId);
          if (qDoc != null) {
            collected.add(_mapToQuestion(qDoc));
          }
        }
      }
    }

    // 2. Also check if questions have direct test_id in questions collection
    if (collected.isEmpty) {
      final directList = await _firestoreQuery('questions', field: 'test_id', value: testId);
      for (final d in directList) {
        collected.add(_mapToQuestion(d));
      }
    }

    return collected;
  }

  /// Fetch live MCQ counts grouped by topic_id from Firestore `questions`
  Future<Map<String, int>> fetchTopicMcqCounts() async {
    final Map<String, int> counts = {};
    final questions = await _firestoreListDocs('questions', pageSize: 1000);
    for (final q in questions) {
      final tId = q['topic_id']?.toString();
      if (tId != null && tId.isNotEmpty) {
        counts[tId] = (counts[tId] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Fetch dynamic Syllabus & Topics from Firestore `syllabus` & `syllabus_topics`
  Future<List<SyllabusSubject>> fetchSyllabusWithTopics({String? examId}) async {
    final counts = await fetchTopicMcqCounts();
    final syllabusDocs = await _firestoreListDocs('syllabus', pageSize: 100);
    final topicDocs = await _firestoreListDocs('syllabus_topics', pageSize: 500);

    // Group topics by syllabus_id
    final Map<String, List<SyllabusTopic>> topicsBySection = {};
    for (final t in topicDocs) {
      final sylId = t['syllabus_id']?.toString() ?? '';
      final topicId = t['id']?.toString() ?? '';
      final gujTitle = t['title_gujarati']?.toString() ?? t['title']?.toString() ?? '';
      final engTitle = t['title']?.toString() ?? gujTitle;
      final count = counts[topicId] ?? 0;

      final topic = SyllabusTopic(
        id: topicId,
        name: engTitle,
        nameGujarati: gujTitle,
        syllabusId: sylId,
        paperPart: t['paper_part']?.toString(),
        contentType: t['content_type']?.toString(),
        keyPoints: [],
        mcqCount: count,
      );

      topicsBySection.putIfAbsent(sylId, () => []).add(topic);
    }

    final List<SyllabusSubject> subjects = [];
    for (final item in syllabusDocs) {
      final exId = item['exam_id']?.toString() ?? 'constable';
      if (examId != null && examId.isNotEmpty && exId != examId) {
        continue;
      }

      final subjectId = item['id']?.toString() ?? '';
      final sectionTopics = topicsBySection[subjectId] ?? [];

      int totalSubjMcqs = 0;
      for (final st in sectionTopics) {
        totalSubjMcqs += st.mcqCount;
      }

      subjects.add(SyllabusSubject(
        id: subjectId,
        title: item['title']?.toString() ?? '',
        titleGujarati: item['title_gujarati']?.toString() ?? item['title']?.toString() ?? '',
        iconName: item['icon_name']?.toString() ?? 'menu_book',
        totalMarksWeightage: (item['total_marks_weightage'] as num?)?.toInt() ?? 10,
        examId: exId,
        dynamicMcqCount: totalSubjMcqs,
        topics: sectionTopics,
      ));
    }

    return subjects;
  }

  /// Fetch MCQs for a specific syllabus topic from Firestore `questions`
  /// Intelligently matches by topic_id, topic title (Gujarati/English), or subject keyword
  Future<List<Question>> fetchQuestionsForTopic(String topicId, [String? subjectGujarati]) async {
    List<Map<String, dynamic>> docs =
        await _firestoreQuery('questions', field: 'topic_id', value: topicId);

    if (docs.isEmpty && subjectGujarati != null && subjectGujarati.isNotEmpty) {
      docs = await _firestoreQuery('questions', field: 'topic', value: subjectGujarati);
      if (docs.isEmpty) {
        docs = await _firestoreQuery('questions', field: 'subject', value: subjectGujarati);
      }
    }

    if (docs.isEmpty) {
      final allQ = await _firestoreListDocs('questions', pageSize: 500);
      final target = (subjectGujarati ?? topicId).toLowerCase().trim();
      final filtered = allQ.where((d) {
        final t = (d['topic']?.toString() ?? '').toLowerCase().trim();
        final s = (d['subject']?.toString() ?? '').toLowerCase().trim();
        final tid = (d['topic_id']?.toString() ?? '').toLowerCase().trim();
        return tid == topicId.toLowerCase() ||
            (target.isNotEmpty &&
                (t.contains(target) || target.contains(t) || s.contains(target)));
      }).toList();
      return filtered.map((d) => _mapToQuestion(d)).toList();
    }

    return docs.map((d) => _mapToQuestion(d)).toList();
  }

  /// Fetch dynamic social & website links from Firestore `app_settings/social_links`
  Future<Map<String, String>> fetchSocialLinks() async {
    final doc = await _firestoreGetDoc('app_settings', 'social_links');
    if (doc != null) {
      return {
        'website': doc['website']?.toString() ?? 'https://gujaratpoliceprep.in',
        'whatsapp': doc['whatsapp']?.toString() ?? 'https://chat.whatsapp.com/KhakhiPrep2026',
        'telegram': doc['telegram']?.toString() ?? 'https://t.me/GujaratPolicePrep',
        'youtube': doc['youtube']?.toString() ?? 'https://youtube.com/@GujaratPolicePrep',
        'instagram': doc['instagram']?.toString() ?? 'https://instagram.com/gujaratpoliceprep',
      };
    }
    return {
      'website': 'https://gujaratpoliceprep.in',
      'whatsapp': 'https://chat.whatsapp.com/KhakhiPrep2026',
      'telegram': 'https://t.me/GujaratPolicePrep',
      'youtube': 'https://youtube.com/@GujaratPolicePrep',
      'instagram': 'https://instagram.com/gujaratpoliceprep',
    };
  }

  /// Fetch notifications from Firestore `notifications` collection
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final docs = await _firestoreListDocs('notifications');
    return docs.where((d) => d['is_active'] != false).toList();
  }

  /// Submit UPI Cashout / Withdrawal to Firestore `withdrawals` collection
  Future<bool> submitWithdrawal({
    required String studentName,
    required String studentEmail,
    required int coins,
    required double amountInr,
    required String upiId,
  }) async {
    final docId = 'wd_${DateTime.now().millisecondsSinceEpoch}';
    return await _firestoreSetDoc('withdrawals', docId, {
      'id': docId,
      'student_name': studentName,
      'student_email': studentEmail,
      'coins_deducted': coins,
      'amount_inr': amountInr,
      'upi_id': upiId,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  List<MockTest> _getDefaultMockTests(String? examId) {
    final List<MockTest> all = [
      MockTest(id: 'constable_1', title: 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 01', description: '🌟 મફત મોક ટેસ્ટ (નવા નિયમો મુજબ - 200 ગુણ)', category: 'Free Mock', durationMinutes: 180, actualMcqCount: 200, examId: 'constable', questions: []),
      MockTest(id: 'constable_2', title: 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 02', description: '🌟 મફત મોક ટેસ્ટ (ઇતિહાસ, ભૂગોળ, કાયદો વિશેષ)', category: 'Free Mock', durationMinutes: 180, actualMcqCount: 0, examId: 'constable', questions: []),
      MockTest(id: 'constable_3', title: 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 03', description: '🌟 મફત મોક ટેસ્ટ (રીઝનિંગ, ગણિત અને બંધારણ)', category: 'Free Mock', durationMinutes: 180, actualMcqCount: 0, examId: 'constable', questions: []),
      MockTest(id: 'constable_4', title: 'કોન્સ્ટેબલ પ્રીમિયમ મોક ટેસ્ટ 04', description: '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક)', category: 'Premium Mock', durationMinutes: 180, actualMcqCount: 0, examId: 'constable', questions: []),
      MockTest(id: 'constable_5', title: 'કોન્સ્ટેબલ પ્રીમિયમ મોક ટેસ્ટ 05', description: '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક)', category: 'Premium Mock', durationMinutes: 180, actualMcqCount: 0, examId: 'constable', questions: []),
      MockTest(id: 'psi_1', title: 'PSI પ્રિલિમિનરી મોક ટેસ્ટ 01', description: '🌟 મફત મોક ટેસ્ટ (જનરલ સ્ટડીઝ, રીઝનિંગ, બંધારણ - 200 ગુણ)', category: 'Free Mock', durationMinutes: 180, actualMcqCount: 0, examId: 'psi', questions: []),
      MockTest(id: 'psi_2', title: 'PSI કાયદો & બંધારણ મોક ટેસ્ટ 02', description: '🌟 મફત ટેસ્ટ (કાયદો, ક્રિમિનલ પ્રોસિજર, બંધારણ વિશેષ)', category: 'Free Mock', durationMinutes: 180, actualMcqCount: 0, examId: 'psi', questions: []),
      MockTest(id: 'psi_3', title: 'PSI ભાષાકીય & વ્યાકરણ મોક ટેસ્ટ 03', description: '🌟 મફત ટેસ્ટ (ગુજરાતી વ્યાકરણ, શબ્દભંડોળ અને અંગ્રેજી)', category: 'Free Mock', durationMinutes: 180, actualMcqCount: 0, examId: 'psi', questions: []),
      MockTest(id: 'psi_4', title: 'PSI પ્રીમિયમ સંપૂર્ણ મોક ટેસ્ટ 04', description: '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક)', category: 'Premium Mock', durationMinutes: 180, actualMcqCount: 0, examId: 'psi', questions: []),
    ];

    if (examId != null && examId.isNotEmpty) {
      return all.where((t) => t.examId == examId).toList();
    }
    return all;
  }
}
