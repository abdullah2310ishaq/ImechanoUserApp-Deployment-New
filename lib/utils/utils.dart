import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:imechano/ui/common/globals.dart';
import 'package:imechano/ui/bloc/booking_list_bloc.dart';
import 'package:imechano/ui/share_preferences/pref_key.dart';
import 'package:imechano/ui/share_preferences/preference.dart';
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/screens/bottombar/job_card_details.dart';
import 'package:imechano/ui/screens/bottombar/my%20invoice.dart';
import 'package:imechano/ui/screens/my_account/progress_report_active.dart';
import 'package:provider/provider.dart';

class Utils {
  static void handleNotificationNavigation(BuildContext context,
      [RemoteMessage? message, String? title, String? jobNo]) {
    log("🔔[NAV] Start ==========================================");
    log("🔔[NAV] Message: ${message?.data}");
    log("🔔[NAV] Title: $title");
    log("🔔[NAV] JobNo: $jobNo");

    final data = message?.data ?? <String, dynamic>{};
    final str = title ?? data.toString();
    final type = (data['type'] ?? data['action'] ?? '').toString().toLowerCase();
    final extractedJob = jobNo ?? data['job_number']?.toString();
    
    log("🔔[NAV] Extracted Type: '$type'");
    log("🔔[NAV] Extracted JobNo: '$extractedJob'");
    log("🔔[NAV] String to check: '$str'");

    // Update Notification Count
    try {
      Provider.of<NotificationCountProvider>(context, listen: false)
          .setNotifications();
    } catch (_) {}

    // ------------------- TYPE BASED -------------------
    if (type.isNotEmpty) {
      switch (type) {
        case 'job_card':
        case 'jobcard':
        case 'job_card_ready':
          if (_openJobCard(extractedJob)) return;
          break;

        case 'delivery_request':
        case 'progress_update':
          if (_openProgress(extractedJob)) return;
          break;

        case 'pickup_request':
        case 'accept_booking':
        case 'booking_accepted':
        case 'accept booking':
        case 'booking_approved':
          _openPickupTab();
          return;

        case 'invoice_ready':
        case 'invoice_generated':
          Get.to(() => MyInvoice());
          return;

        case 'job_card_payment':
        case 'payment_confirmed':
          if (_openJobCard(extractedJob)) return;
          break;
      }
    }

    // ------------------- STRING FALLBACK -------------------
    if (str.contains('Invoice')) {
      Get.to(() => MyInvoice());
      return;
    }

    if (str.contains('Pickup') ||
        str.contains('Accept Booking') ||
        str.contains("قبول الحجز") ||
        str.contains("تأكيد الاستلام")) {
      _openPickupTab();
      return;
    }

    if (str.contains('Reject Booking')) {
      currentBookingTab = 2;
      Get.offAll(() => BottomBarPage(1));
      _refreshBookingsAfterNavigation();
      return;
    }

    if (str.contains('Job Card') ||
        str.contains('Job Card Ready') ||
        str.contains('Job card is available') ||
        str.contains("بطاقة العمل")) {
      _openJobCard(extractedJob);
      return;
    }

    if (str.contains('Payment Confirmed') ||
        str.contains('Payment Successful') ||
        str.contains('Your payment has been confirmed')) {
      _openJobCard(extractedJob);
      return;
    }

    if (str.contains('Delivery') ||
        str.contains('Task Completed') ||
        str.contains("طلب توصيل")) {
      _openProgress(extractedJob);
      return;
    }

    log("🔔[NAV] End (No navigation matched)");
  }

  // ------------------- HELPERS -------------------

  static bool _openJobCard(String? jobNumber) {
    if (jobNumber == null || jobNumber.isEmpty) return false;
    currentJobcardTab = 0;
    Get.to(() => MyJobCardDetails(job_number: jobNumber));
    return true;
  }

  static bool _openProgress(String? jobNumber) {
    if (jobNumber == null || jobNumber.isEmpty) return false;
    currentJobcardTab = 3;
    Get.to(() => ProgressReportActive(job_number: jobNumber));
    return true;
  }

  static void _openPickupTab() {
    currentBookingTab = 3;
    Get.offAll(() => BottomBarPage(1));
    _refreshBookingsAfterNavigation(forceTab: 3);
  }

  static void _refreshBookingsAfterNavigation({int? forceTab}) {
    void refreshOnce() {
      try {
        if (PrefObj.preferences?.containsKey(PrefKeys.USER_ID) == true) {
          final userId = PrefObj.preferences!.get(PrefKeys.USER_ID);
          if (userId != null) {
            final tabToLoad = (forceTab ?? currentBookingTab).toString();
            bookingListbloc.bookinglistsink(userId, tabToLoad);
          }
        }
      } catch (_) {}
    }

    Future.delayed(const Duration(milliseconds: 150), refreshOnce);
    Future.delayed(const Duration(seconds: 2), refreshOnce);
  }

  static void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
