import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static Timer? _globalTimer;
  static bool _isInitialized = false;

  /// Start global notification refresh timer
  static void startGlobalTimer(BuildContext context) {
    if (_isInitialized) return;

    _isInitialized = true;
    _globalTimer?.cancel();

    _globalTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      try {
        // Use the provided app-level context (has providers) so it works globally
        Provider.of<NotificationCountProvider>(context, listen: false)
            .setNotifications();
      } catch (e) {
        log('Failed to refresh notification count globally: $e');
      }
    });

    log('Global notification timer started');
  }

  /// Stop global notification refresh timer
  static void stopGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = null;
    _isInitialized = false;
    log('Global notification timer stopped');
  }

  /// Manually refresh notifications
  static void refreshNotifications(BuildContext context) {
    try {
      Provider.of<NotificationCountProvider>(context, listen: false)
          .setNotifications();
    } catch (e) {
      log('Failed to manually refresh notifications: $e');
    }
  }

  /// Check if timer is running
  static bool get isRunning => _isInitialized && _globalTimer != null;
}
