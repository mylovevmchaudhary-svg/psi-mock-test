import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class UserModel {
  static final UserModel _instance = UserModel._internal();
  factory UserModel() => _instance;
  UserModel._internal() {
    _loadFromDisk();
  }

  bool isLoggedIn = false;
  String name = 'વિદ્યાર્થી';
  String email = '';
  String myReferralCode = 'KHAKHI2026';
  String appliedReferralCode = '';
  int coins = 0;
  int totalReferralsCount = 0;
  int referralCoinsEarned = 0;
  bool isDailyBonusClaimed = false;
  int testsTaken = 0;
  int totalCorrectAnswers = 0;
  int streakDays = 0;

  /// Reactive notifier for instant, real-time UI updates across all tabs & screens
  late final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(coins);

  final List<Map<String, dynamic>> coinHistory = [];

  // Withdrawal Requests list
  final List<Map<String, dynamic>> withdrawalRequests = [];

  // Set of unlocked test IDs
  final Set<String> _unlockedTests = {
    'constable_1',
    'constable_2',
    'constable_3',
    'psi_1',
    'psi_2',
    'psi_3',
  };

  File get _storageFile {
    final tempDir = Directory.systemTemp.path;
    return File('$tempDir/khakhi_user_session.json');
  }

  void _loadFromDisk() {
    try {
      final file = _storageFile;
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final data = jsonDecode(content);
        if (data is Map) {
          final storedEmail = data['email']?.toString() ?? '';
          // If stored session belonged to legacy mock dummy user, ignore it
          if (storedEmail == 'student@khakhi.in') {
            return;
          }
          name = data['name']?.toString() ?? name;
          email = storedEmail;
          coins = (data['coins'] as num?)?.toInt() ?? coins;
          isLoggedIn = (data['isLoggedIn'] as bool?) ?? isLoggedIn;
          myReferralCode = data['myReferralCode']?.toString() ?? myReferralCode;
          appliedReferralCode = data['appliedReferralCode']?.toString() ?? appliedReferralCode;
          isDailyBonusClaimed = (data['isDailyBonusClaimed'] as bool?) ?? false;
          totalReferralsCount = (data['totalReferralsCount'] as num?)?.toInt() ?? 0;
          referralCoinsEarned = (data['referralCoinsEarned'] as num?)?.toInt() ?? 0;
          testsTaken = (data['testsTaken'] as num?)?.toInt() ?? 0;
          totalCorrectAnswers = (data['totalCorrectAnswers'] as num?)?.toInt() ?? 0;
          streakDays = (data['streakDays'] as num?)?.toInt() ?? 0;

          if (data['coinHistory'] is List) {
            coinHistory.clear();
            coinHistory.addAll(List<Map<String, dynamic>>.from(data['coinHistory']));
          }
          if (data['withdrawalRequests'] is List) {
            withdrawalRequests.clear();
            withdrawalRequests.addAll(List<Map<String, dynamic>>.from(data['withdrawalRequests']));
          }

          if (data['unlockedTests'] is List) {
            _unlockedTests.addAll((data['unlockedTests'] as List).map((e) => e.toString()));
          }
          coinsNotifier.value = coins;
        }
      }
    } catch (_) {}
  }

  void _saveToDisk() {
    try {
      final data = {
        'name': name,
        'email': email,
        'coins': coins,
        'isLoggedIn': isLoggedIn,
        'myReferralCode': myReferralCode,
        'appliedReferralCode': appliedReferralCode,
        'isDailyBonusClaimed': isDailyBonusClaimed,
        'totalReferralsCount': totalReferralsCount,
        'referralCoinsEarned': referralCoinsEarned,
        'testsTaken': testsTaken,
        'totalCorrectAnswers': totalCorrectAnswers,
        'streakDays': streakDays,
        'coinHistory': coinHistory,
        'withdrawalRequests': withdrawalRequests,
        'unlockedTests': _unlockedTests.toList(),
      };
      _storageFile.writeAsStringSync(jsonEncode(data));
    } catch (_) {}
  }

  bool isTestUnlocked(String testId, int testIndex) {
    if (testIndex <= 3) return true; // First 3 tests are Free
    return _unlockedTests.contains(testId);
  }

  void setCoins(int newCoins) {
    coins = newCoins;
    coinsNotifier.value = coins;
    _saveToDisk();
  }

  bool unlockWithCoins(String testId, int requiredCoins) {
    if (coins >= requiredCoins) {
      coins -= requiredCoins;
      coinsNotifier.value = coins;
      _unlockedTests.add(testId);
      coinHistory.insert(0, {
        'title': 'મોક ટેસ્ટ અનલોક ($testId)',
        'amount': '-$requiredCoins',
        'isCredit': false,
        'date': 'હમણાં',
      });
      _saveToDisk();
      FirebaseService().syncCoinsToDatabase(email, coins);
      return true;
    }
    return false;
  }

  void unlockWithAd(String testId) {
    _unlockedTests.add(testId);
    coins += 10;
    coinsNotifier.value = coins;
    coinHistory.insert(0, {
      'title': 'AdMob રિવોર્ડ બોનસ',
      'amount': '+10',
      'isCredit': true,
      'date': 'હમણાં',
    });
    _saveToDisk();
    FirebaseService().syncCoinsToDatabase(email, coins);
  }

  void addCoins(int amount, String reason) {
    coins += amount;
    coinsNotifier.value = coins;
    coinHistory.insert(0, {
      'title': reason,
      'amount': '+$amount',
      'isCredit': true,
      'date': 'હમણાં',
    });
    _saveToDisk();
    FirebaseService().syncCoinsToDatabase(email, coins);
  }

  bool claimDailyBonus() {
    if (!isDailyBonusClaimed) {
      coins += 15;
      isDailyBonusClaimed = true;
      coinsNotifier.value = coins;
      coinHistory.insert(0, {
        'title': 'ડેઇલી ચેક-ઇન બોનસ',
        'amount': '+15',
        'isCredit': true,
        'date': 'આજે',
      });
      _saveToDisk();
      FirebaseService().syncCoinsToDatabase(email, coins);
      return true;
    }
    return false;
  }

  bool requestWithdrawal({
    required int coinsToDeduct,
    required double inrAmount,
    required String upiId,
  }) {
    if (coins >= coinsToDeduct) {
      coins -= coinsToDeduct;
      coinsNotifier.value = coins;
      coinHistory.insert(0, {
        'title': 'પૈસા ઉપાડ વિનંતી ($upiId)',
        'amount': '-$coinsToDeduct',
        'isCredit': false,
        'date': 'હમણાં',
      });

      withdrawalRequests.insert(0, {
        'id': 'wd_${DateTime.now().millisecondsSinceEpoch}',
        'amount': '₹${inrAmount.toStringAsFixed(2)}',
        'coins': coinsToDeduct,
        'upi': upiId,
        'status': 'પેન્ડિંગ (Processing) ⏳',
        'date': 'હમણાં',
        'isSuccess': false,
      });

      _saveToDisk();
      FirebaseService().syncCoinsToDatabase(email, coins);
      FirebaseService().submitWithdrawal(
        studentName: name,
        studentEmail: email,
        coins: coinsToDeduct,
        amountInr: inrAmount,
        upiId: upiId,
      );
      return true;
    }
    return false;
  }

  void recordTestCompletion({required int score, required int totalQuestions}) {
    testsTaken++;
    totalCorrectAnswers += score;
    if (streakDays == 0) streakDays = 1;
    addCoins(5, 'મોક ટેસ્ટ પૂર્ણ બોનસ');
    _saveToDisk();
  }

  void register({
    required String userName,
    required String userEmail,
    String? referralCode,
  }) {
    name = userName.trim().isNotEmpty ? userName.trim() : userEmail.split('@').first;
    email = userEmail.trim();
    isLoggedIn = true;
    coins = 30; // base welcome for real registration
    coinHistory.clear();
    withdrawalRequests.clear();
    coinHistory.insert(0, {
      'title': 'નવા વિદ્યાર્થી વેલકમ બોનસ',
      'amount': '+30',
      'isCredit': true,
      'date': 'આજે',
    });
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      appliedReferralCode = referralCode.trim();
      coins += 20; // referral bonus
      coinHistory.insert(0, {
        'title': 'રેફરલ કોડ બોનસ ($appliedReferralCode)',
        'amount': '+20',
        'isCredit': true,
        'date': 'આજે',
      });
    }
    coinsNotifier.value = coins;
    _saveToDisk();
  }

  void login({required String userEmail, String? userName}) {
    email = userEmail.trim();
    if (userName != null && userName.trim().isNotEmpty) {
      name = userName.trim();
    } else if (name.isEmpty || name == 'વિદ્યાર્થી') {
      name = userEmail.split('@').first;
    }
    isLoggedIn = true;
    _saveToDisk();
  }

  void logout() {
    isLoggedIn = false;
    _saveToDisk();
  }
}
