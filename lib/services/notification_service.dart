import 'dart:async';
import 'package:flutter/material.dart';
import 'firebase_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'exam', 'test', 'alert', 'reward'
  final DateTime date;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    this.isRead = false,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _loadInitialNotifications();
  }

  final List<AppNotification> _notifications = [];
  final StreamController<List<AppNotification>> _streamController =
      StreamController<List<AppNotification>>.broadcast();

  Stream<List<AppNotification>> get notificationsStream => _streamController.stream;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _loadInitialNotifications() async {
    // 1. Fetch from Firebase
    final remote = await FirebaseService().fetchNotifications();
    _notifications.clear();
    for (final item in remote) {
      _notifications.add(
        AppNotification(
          id: item['id']?.toString() ?? 'n_${DateTime.now().millisecondsSinceEpoch}',
          title: item['title']?.toString() ?? 'PSI Mock Test સૂચના',
          message: item['message']?.toString() ?? '',
          type: item['type']?.toString() ?? 'alert',
          date: item['created_at'] != null
              ? DateTime.tryParse(item['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          isRead: false,
        ),
      );
    }
    _streamController.add(_notifications);
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    _streamController.add(_notifications);
  }

  void markAsRead(String id) {
    final n = _notifications.firstWhere((element) => element.id == id, orElse: () => _notifications.first);
    n.isRead = true;
    _streamController.add(_notifications);
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    final newNotif = AppNotification(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      date: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, newNotif);
    _streamController.add(_notifications);
  }

  /// Show a system-like Heads-Up Notification Banner on top of mobile screen
  static void showSystemAlert(BuildContext context, {required String title, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
        backgroundColor: const Color(0xFF0D253F),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3C72),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active, color: Color(0xFFFFC107), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
