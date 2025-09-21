import 'package:flutter/material.dart';
import 'package:imechano/api/notification_api.dart';
import 'package:imechano/ui/modal/notification_count_model.dart';
import 'dart:developer';

class NotificationCountProvider with ChangeNotifier {
  NotificationCountModel _notifications =
      NotificationCountModel(total: 0, totalRead: 0, totalUnread: 0);
  bool _isInitialized = false;

  int get notifications => _notifications.totalUnread!;
  bool get isInitialized => _isInitialized;

  Future<void> setNotifications() async {
    try {
      log('Fetching notification count...');
      _notifications = await NotificationApi.getNotificationCount();
      _isInitialized = true;
      log('Notification count updated: ${_notifications.totalUnread} unread');
      notifyListeners();
    } catch (e) {
      log('Error fetching notification count: $e');
      _isInitialized = false;
    }
  }

  void clearNotifications() async {
    _notifications =
        NotificationCountModel(total: 0, totalRead: 0, totalUnread: 0);
    _isInitialized = true;
    notifyListeners();
  }

  void resetInitialization() {
    _isInitialized = false;
  }
}
