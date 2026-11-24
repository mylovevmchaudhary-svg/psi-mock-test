import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();

  IconData _getIconForType(String type) {
    switch (type) {
      case 'exam':
        return Icons.campaign_rounded;
      case 'test':
        return Icons.assignment_turned_in_rounded;
      case 'reward':
        return Icons.monetization_on_rounded;
      case 'alert':
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'exam':
        return const Color(0xFFD32F2F); // Red
      case 'test':
        return const Color(0xFF1976D2); // Blue
      case 'reward':
        return const Color(0xFF388E3C); // Green
      case 'alert':
      default:
        return const Color(0xFFFFA000); // Amber
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} મિનિટ પહેલા';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} કલાક પહેલા';
    } else {
      return '${diff.inDays} દિવસ પહેલા';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _service.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D253F),
        title: const Text(
          'નોટિફિકેશન & એલર્ટ્સ 🔔',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton.icon(
              icon: const Icon(Icons.done_all, color: Color(0xFFFFC107), size: 18),
              label: const Text(
                'બધા વાંચો',
                style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: () {
                setState(() {
                  _service.markAllAsRead();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('તમામ નોટિફિકેશન વાંચેલા તરીકે માર્ક કરવામાં આવ્યા છે.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'હાલ કોઈ નવી નોટિફિકેશન નથી',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'પરીક્ષા અને મોક ટેસ્ટની તમામ અપડેટ્સ અહીં દેખાશે.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final iconColor = _getColorForType(notif.type);

                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      notif.isRead = true;
                    });
                  },
                  child: Card(
                    elevation: notif.isRead ? 0.5 : 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: notif.isRead ? Colors.transparent : iconColor.withOpacity(0.5),
                        width: 1.2,
                      ),
                    ),
                    color: notif.isRead ? Colors.white : const Color(0xFFFDFDFD),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          notif.isRead = true;
                        });
                        _showDetailSheet(notif);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: iconColor.withOpacity(0.12),
                              child: Icon(_getIconForType(notif.type), color: iconColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: TextStyle(
                                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                            fontSize: 13.5,
                                            color: const Color(0xFF0D253F),
                                          ),
                                        ),
                                      ),
                                      if (!notif.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: iconColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatTime(notif.date),
                                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D253F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.send_to_mobile, color: Color(0xFFFFC107)),
        label: const Text('ટેસ્ટ નોટિફિકેશન મોકલો', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        onPressed: () {
          NotificationService.showSystemAlert(
            context,
            title: '🚨 ગુજરાત પોલીસ મિશન ખાખી 2026',
            message: 'નવી મોક ટેસ્ટ સીરીઝ લાઈવ થઈ ગઈ છે! હમણાં જ ટેસ્ટ આપી તમારી તૈયારી ચકાસો.',
          );
        },
      ),
    );
  }

  void _showDetailSheet(AppNotification notif) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getColorForType(notif.type).withOpacity(0.15),
                  child: Icon(_getIconForType(notif.type), color: _getColorForType(notif.type)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notif.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              notif.message,
              style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              'તારીખ: ${_formatTime(notif.date)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D253F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('સમજાયું'),
            ),
          ],
        ),
      ),
    );
  }
}
