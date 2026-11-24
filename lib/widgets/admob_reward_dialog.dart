import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AdMobRewardedTestAdDialog extends StatefulWidget {
  final String title;
  final String? testId;
  final VoidCallback? onRewardEarned;

  const AdMobRewardedTestAdDialog({
    super.key,
    this.title = 'Google AdMob Rewarded Video',
    this.testId,
    this.onRewardEarned,
  });

  static Future<bool> show(
    BuildContext context, {
    String title = 'Google AdMob Rewarded Video',
    String? testId,
    VoidCallback? onRewardEarned,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdMobRewardedTestAdDialog(
        title: title,
        testId: testId,
        onRewardEarned: onRewardEarned,
      ),
    );
    return result ?? false;
  }

  @override
  State<AdMobRewardedTestAdDialog> createState() => _AdMobRewardedTestAdDialogState();
}

class _AdMobRewardedTestAdDialogState extends State<AdMobRewardedTestAdDialog> {
  final _user = UserModel();
  int _countdown = 10; // 10-second AdMob Test Video
  Timer? _timer;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() {
          _countdown = 0;
          _isCompleted = true;
        });
        _grantReward();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void _grantReward() {
    if (widget.testId != null) {
      _user.unlockWithAd(widget.testId!);
    } else {
      _user.addCoins(10, 'Google AdMob ટેસ્ટ એડ રિવોર્ડ');
    }
    widget.onRewardEarned?.call();
  }

  void _tryCloseEarly() {
    if (_isCompleted) {
      Navigator.pop(context, true);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('એડ સ્કીપ કરવી છે?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'જો તમે અત્યારે એડ બંધ કરશો તો તમને +10 બોનસ કોઈન્સ નહીં મળે. શું તમે ખરેખર બહાર નીકળવા માંગો છો?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close warning
              Navigator.pop(context, false); // Cancel Ad
            },
            child: const Text('હા, સ્કીપ કરો', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D253F),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('એડ ચાલુ રાખો'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (10 - _countdown) / 10.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Google AdMob Official Test Ad Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AdMob Test Ad',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sponsored',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!_isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'રિવોર્ડ: $_countdown s',
                            style: const TextStyle(color: Color(0xFFFFC107), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(_isCompleted ? Icons.check_circle : Icons.close, color: _isCompleted ? Colors.greenAccent : Colors.white70, size: 22),
                        onPressed: _tryCloseEarly,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Linear Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
              minHeight: 3,
            ),

            // 3. Ad Content Player Simulation
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        center: Alignment.center,
                        radius: 0.9,
                        colors: [Color(0xFF1E3C72), Color(0xFF0D253F)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5), width: 1.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield, color: Color(0xFFFFC107), size: 48),
                            const SizedBox(height: 8),
                            const Text(
                              'PSI Mock Test 2026',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Constable & PSI Mock Test Series',
                              style: TextStyle(color: Color(0xFFFFC107), fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Ad Unit: ca-app-pub-3940256099942544/5224354917',
                                style: TextStyle(color: Colors.white54, fontSize: 9, fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                        if (_isCompleted)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B5E20).withOpacity(0.92),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Color(0xFFFFC107), size: 54),
                                  SizedBox(height: 8),
                                  Text(
                                    '🎉 રિવોર્ડ અનલોક થયું!',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '+10 કોઈન્સ તમારા વૉલેટમાં જમા થયા છે.',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom Action / Claim
                  if (!_isCompleted) ...[
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107))),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'વિડિઓ જોઈને ફ્રી કોઈન્સ મેળવો...',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
                      label: const Text('કોઈન્સ મેળવો અને બંધ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
