class WalletManager {
  static final WalletManager _instance = WalletManager._internal();
  factory WalletManager() => _instance;
  WalletManager._internal();

  int coins = 35; // Welcome bonus
  String referralCode = 'KHAKHI2026';
  int totalReferrals = 3;
  int referralCoinsEarned = 150;
  bool isDailyBonusClaimed = false;

  // Set of unlocked test IDs across exams (Tests 1, 2, 3 are always free)
  final Set<String> _unlockedTests = {
    'test_1',
    'test_2',
    'test_3',
    'constable_1',
    'constable_2',
    'constable_3',
    'psi_1',
    'psi_2',
    'psi_3',
  };

  bool isTestUnlocked(String testId, int testIndex) {
    if (testIndex <= 3) return true; // First 3 tests are always Free
    return _unlockedTests.contains(testId);
  }

  bool unlockWithCoins(String testId, int requiredCoins) {
    if (coins >= requiredCoins) {
      coins -= requiredCoins;
      _unlockedTests.add(testId);
      return true;
    }
    return false;
  }

  void unlockWithAd(String testId) {
    _unlockedTests.add(testId);
    coins += 5; // Reward for watching ad
  }

  void addCoins(int amount) {
    coins += amount;
  }

  bool claimDailyBonus() {
    if (!isDailyBonusClaimed) {
      coins += 15;
      isDailyBonusClaimed = true;
      return true;
    }
    return false;
  }
}
