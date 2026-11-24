import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/admob_reward_dialog.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _user = UserModel();
  bool _isWatchingAd = false;
  String _activeTab = 'History'; // 'History' or 'Withdrawals'

  void _watchAd() async {
    final success = await AdMobRewardedTestAdDialog.show(
      context,
      title: 'Google AdMob Rewarded Test Ad',
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Row(
            children: [
              Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
              SizedBox(width: 8),
              Text('અભિનંદન! તમને +10 કોઈન્સ મળ્યા! 🎉'),
            ],
          ),
        ),
      );
    }
  }

  void _claimDailyBonus() {
    if (_user.claimDailyBonus()) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Text('ડેઇલી બોનસ ક્લેમ થયું: +15 કોઈન્સ! 🌟'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('આજનો બોનસ તમે પહેલેથી ક્લેમ કરી લીધો છે!')),
      );
    }
  }

  void _showWithdrawDialog() {
    int selectedCoins = 100;
    double inrValue = 10.0;
    final upiController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.account_balance, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text('પૈસા ઉપાડો (Withdraw Cash)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('કોઈન્સ પસંદ કરો (100 કોઈન્સ = ₹10.00):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildCoinOption(100, 10.0, selectedCoins, (c, v) {
                        setModalState(() {
                          selectedCoins = c;
                          inrValue = v;
                        });
                      }),
                      _buildCoinOption(200, 20.0, selectedCoins, (c, v) {
                        setModalState(() {
                          selectedCoins = c;
                          inrValue = v;
                        });
                      }),
                      _buildCoinOption(500, 50.0, selectedCoins, (c, v) {
                        setModalState(() {
                          selectedCoins = c;
                          inrValue = v;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('તમને મળશે:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${inrValue.toStringAsFixed(2)} રોકડા', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: upiController,
                    decoration: const InputDecoration(
                      labelText: 'તમારો UPI ID લખો',
                      hintText: 'દા.ત. 9876543210@paytm / user@okhdfcbank',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payment),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('રદ કરો')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final upi = upiController.text.trim();
                  if (upi.isEmpty || !upi.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('કૃપા કરીને સાચો UPI ID લખો!')),
                    );
                    return;
                  }

                  if (_user.coins < selectedCoins) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('તમારી પાસે પૂરતા કોઈન્સ નથી! મિત્રોને રેફર કરીને કમાઓ.')),
                    );
                    return;
                  }

                  Navigator.pop(ctx);
                  _user.requestWithdrawal(
                    coinsToDeduct: selectedCoins,
                    inrAmount: inrValue,
                    upiId: upi,
                  );
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF2E7D32),
                      content: Text('ઉપાડ વિનંતી સબમિટ થઈ ગઈ! એડમિન દ્વારા ₹$inrValue તમારા UPI ($upi) પર મોકલાશે.'),
                    ),
                  );
                },
                child: const Text('ઉપાડ વિનંતી મોકલો', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoinOption(int coins, double inr, int currentSelected, Function(int, double) onSelect) {
    final isSelected = coins == currentSelected;
    return ChoiceChip(
      label: Text('$coins કોઈન્સ (₹${inr.toInt()})'),
      selected: isSelected,
      selectedColor: const Color(0xFF0D253F),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (_) => onSelect(coins, inr),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: const Text(
          'મારું વૉલેટ & કમાણી (Wallet)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gold Wallet Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D253F), Color(0xFF1E3C72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D253F).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'કુલ ઉપલબ્ધ કોઈન્સ (Wallet Balance)',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ValueListenableBuilder<int>(
                          valueListenable: _user.coinsNotifier,
                          builder: (_, currentCoins, __) => Text(
                            'રોકડ મૂલ્ય: ₹${(currentCoins / 10).toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 36, color: Color(0xFFFFC107)),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<int>(
                            valueListenable: _user.coinsNotifier,
                            builder: (_, currentCoins, __) => Text(
                              '$currentCoins',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('કોઈન્સ', style: TextStyle(fontSize: 14, color: Colors.white)),
                        ],
                      ),
                      // Withdraw Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        icon: const Icon(Icons.account_balance, size: 16),
                        label: const Text('પૈસા ઉપાડો', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: _showWithdrawDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '💡 રેફરલ અને ડેઇલી બોનસથી કમાયેલા કોઈન્સ સીધા UPI દ્વારા તમારા બેંક એકાઉન્ટમાં ઉપાડી શકો છો.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Earn Coins Options
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.event_available,
                    title: 'ડેઇલી ચેક-ઇન',
                    subtitle: _user.isDailyBonusClaimed ? 'આજે ક્લેમ કરેલ' : '+15 કોઈન્સ દરરોજ',
                    buttonText: _user.isDailyBonusClaimed ? 'ક્લેમ થયેલ' : 'ક્લેમ કરો',
                    color: const Color(0xFF2E7D32),
                    isEnabled: !_user.isDailyBonusClaimed,
                    onTap: _claimDailyBonus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.play_circle_fill,
                    title: 'વિડિઓ એડ જુઓ',
                    subtitle: '+5 કોઈન્સ પ્રતિ એડ',
                    buttonText: 'એડ જુઓ',
                    color: const Color(0xFFE65100),
                    isEnabled: !_isWatchingAd,
                    onTap: _watchAd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // History / Withdrawals Tabs
            Row(
              children: [
                _buildFilterTab('કોઈન્સ હિસ્ટ્રી', 'History'),
                const SizedBox(width: 8),
                _buildFilterTab('ઉપાડ વિનંતીઓ (Withdrawals)', 'Withdrawals'),
              ],
            ),
            const SizedBox(height: 12),

            if (_activeTab == 'History') ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: _user.coinHistory.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('હજુ સુધી કોઈ કોઈન્સ ટ્રાન્ઝેક્શન થયેલ નથી.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _user.coinHistory.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _user.coinHistory[index];
                    final isCredit = item['isCredit'] as bool;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCredit
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        child: Icon(
                          isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                          color: isCredit ? const Color(0xFF2E7D32) : Colors.red,
                          size: 20,
                        ),
                      ),
                      title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(item['date'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      trailing: Text(
                        item['amount'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isCredit ? const Color(0xFF2E7D32) : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: _user.withdrawalRequests.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('હજુ સુધી કોઈ ઉપાડ વિનંતી કરેલ નથી.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _user.withdrawalRequests.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final wd = _user.withdrawalRequests[index];
                          final isPaid = wd['isSuccess'] == true;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                              child: Icon(
                                isPaid ? Icons.check_circle : Icons.hourglass_top,
                                color: isPaid ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                            ),
                            title: Text('${wd['amount']} (${wd['coins']} કોઈન્સ)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('UPI: ${wd['upi']} • ${wd['date']}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            trailing: Text(
                              wd['status'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isPaid ? Colors.green : Colors.orange,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, String tabKey) {
    final isSelected = _activeTab == tabKey;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tabKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D253F) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF0D253F) : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color color,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: isEnabled ? color : Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isEnabled ? onTap : null,
              child: Text(buttonText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
