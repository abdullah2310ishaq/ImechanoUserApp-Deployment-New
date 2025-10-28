import 'package:flutter/material.dart';
import 'package:imechano/api/notification_api.dart';
import 'package:imechano/ui/modal/notification_count_model.dart';
import 'dart:developer';

class NotificationCountProvider with ChangeNotifier {
  NotificationCountModel _notifications =
      NotificationCountModel(total: 0, totalRead: 0, totalUnread: 0);
  bool _isInitialized = false;
  bool _isFetching = false;
  int _lastEmittedUnread = 0;

  int get notifications => _notifications.totalUnread!;
  bool get isInitialized => _isInitialized;

  Future<void> setNotifications() async {
    if (_isFetching) {
      // Prevent overlapping fetches that cause double rebuilds
      return;
    }
    _isFetching = true;
    try {
      log('Fetching notification count...');
      _notifications = await NotificationApi.getNotificationCount();
      _isInitialized = true;
      final int newUnread = _notifications.totalUnread ?? 0;
      log('Notification count updated: $newUnread unread');
      if (newUnread != _lastEmittedUnread) {
        _lastEmittedUnread = newUnread;
        notifyListeners();
      } else {
        // No visual change; skip notifying to avoid blink
        log('Notification count unchanged; skipping notifyListeners');
      }
    } catch (e) {
      log('Error fetching notification count: $e');
      _isInitialized = false;
    }
    _isFetching = false;
  }

  void clearNotifications() async {
    _notifications =
        NotificationCountModel(total: 0, totalRead: 0, totalUnread: 0);
    _isInitialized = true;
    if (_lastEmittedUnread != 0) {
      _lastEmittedUnread = 0;
      notifyListeners();
    }
  }

  void resetInitialization() {
    _isInitialized = false;
  }
}
