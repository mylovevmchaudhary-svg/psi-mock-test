import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  final _user = UserModel();

  void _copyCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0D253F),
        content: Text('રેફરલ કોડ "${_user.myReferralCode}" ક્લિપબોર્ડ પર કોપી થયો! 📋'),
      ),
    );
  }

  void _shareOnWhatsApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF25D366),
        content: Text('WhatsApp શેરિંગ મેસેજ તૈયાર થયો!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: const Text(
          'રેફર અને કમાઓ (Refer & Earn)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Illustration Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D253F), Color(0xFF1E3C72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D253F).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFF2A4D7E),
                    child: Icon(Icons.people_alt, size: 40, color: Color(0xFFFFC107)),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'મિત્રોને જોડો અને કોઈન્સ મેળવો! 👥',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'તમારો મિત્ર જોડાય એટલે તમને +50 કોઈન્સ અને તમારા મિત્રને +20 કોઈન્સ બોનસ મળશે.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Referral Code Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'તમારો વિશિષ્ટ રેફરલ કોડ (Your Referral Code):',
                    style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0D253F).withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _user.myReferralCode,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            color: Color(0xFF0D253F),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D253F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('કોપી'),
                          onPressed: _copyCode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // WhatsApp Share Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // WhatsApp Color
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text(
                      'WhatsApp પર મિત્રોને આમંત્રિત કરો',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onPressed: _shareOnWhatsApp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Referral Stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.group_add, color: Color(0xFF1976D2), size: 28),
                        const SizedBox(height: 6),
                        Text(
                          '${_user.totalReferralsCount}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                        ),
                        const SizedBox(height: 2),
                        const Text('જોડાયેલ મિત્રો', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 28),
                        const SizedBox(height: 6),
                        Text(
                          '+${_user.referralCoinsEarned}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                        const SizedBox(height: 2),
                        const Text('કમાયેલા કોઈન્સ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // How it works 3 Steps
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'રેફરલ કેવી રીતે કામ કરે છે?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D253F)),
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    stepNum: '1',
                    title: 'તમારો રેફરલ કોડ શેર કરો',
                    desc: 'WhatsApp અથવા સોશિયલ મીડિયા પર તમારા પોલીસ તૈયારી કરતા મિત્રો સાથે કોડ શેર કરો.',
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNum: '2',
                    title: 'મિત્ર સાઇન અપ વખતે કોડ લખશે',
                    desc: 'તમારો મિત્ર એપમાં એકાઉન્ટ બનાવતી વખતે રેફરલ કોડ દાખલ કરશે.',
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNum: '3',
                    title: 'બંનેને મળશે મફત કોઈન્સ! 🎉',
                    desc: 'તમને તરત +50 કોઈન્સ અને તમારા મિત્રને +20 કોઈન્સનું બોનસ મળશે.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNum,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF0D253F),
          child: Text(
            stepNum,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}
