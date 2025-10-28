import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static Timer? _globalTimer;
  static bool _isInitialized = false;
  static FlutterLocalNotificationsPlugin? _plugin;
  static String _channelId = 'high_importance_channel';
  static String _channelName = 'High Importance Notifications';

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

  /// Bind the FlutterLocalNotificationsPlugin and channel info from main initialization
  static void bindLocalNotifications(FlutterLocalNotificationsPlugin plugin,
      {String? channelId, String? channelName}) {
    _plugin = plugin;
    if (channelId != null && channelId.isNotEmpty) _channelId = channelId;
    if (channelName != null && channelName.isNotEmpty) {
      _channelName = channelName;
    }
  }

  /// Trigger a local notification with a JSON payload that can be parsed on tap
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final plugin = _plugin;
    if (plugin == null) {
      log('Local notifications plugin not bound. Call bindLocalNotifications first.');
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payloadMap = <String, dynamic>{
      ...(data ?? <String, dynamic>{}),
      'title': title,
      'body': body,
    };

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1000000),
      title,
      body,
      details,
      payload: jsonEncode(payloadMap),
    );
  }
}
