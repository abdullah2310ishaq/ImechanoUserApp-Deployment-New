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
    print("🔔[NAV] ========== UTILS.handleNotificationNavigation CALLED ==========");
    print("🔔[NAV] Start ==========================================");
    log("🔔[NAV] Start ==========================================");
    print("🔔[NAV] Full Message Data: ${message?.data}");
    log("🔔[NAV] Full Message Data: ${message?.data}");
    print("🔔[NAV] Data keys: ${message?.data.keys.toList()}");
    log("🔔[NAV] Data keys: ${message?.data.keys.toList()}");
    print("🔔[NAV] Notification Title: ${message?.notification?.title}");
    log("🔔[NAV] Notification Title: ${message?.notification?.title}");
    print("🔔[NAV] Notification Body: ${message?.notification?.body}");
    log("🔔[NAV] Notification Body: ${message?.notification?.body}");
    print("🔔[NAV] Title param: $title");
    log("🔔[NAV] Title param: $title");
    print("🔔[NAV] JobNo param: $jobNo");
    log("🔔[NAV] JobNo param: $jobNo");

    final data = message?.data ?? <String, dynamic>{};
    final str = title ?? data.toString();
    final type = (data['type'] ?? data['action'] ?? '').toString().toLowerCase();
    // Extract job number from multiple possible fields
    final extractedJob = jobNo ?? 
                        data['job_number']?.toString() ?? 
                        data['booking_id']?.toString() ?? 
                        data['jobNumber']?.toString();
    
    log("🔔[NAV] Extracted Type: '$type'");
    log("🔔[NAV] Extracted JobNo/BookingID: '$extractedJob'");
    log("🔔[NAV] String to check: '$str'");
    log("🔔[NAV] String contains 'Delivery': ${str.contains('Delivery')}");
    log("🔔[NAV] String contains 'Emergency': ${str.contains('Emergency')}");
    log("🔔[NAV] String contains 'Please Confirm': ${str.contains('Please Confirm')}");
    log("🔔[NAV] Will navigate to: ${extractedJob != null && extractedJob.isNotEmpty ? 'ProgressReportActive($extractedJob)' : 'Job Cards Tab'}");

    // Update Notification Count
    try {
      Provider.of<NotificationCountProvider>(context, listen: false)
          .setNotifications();
    } catch (_) {}

    // ------------------- TYPE BASED -------------------
    if (type.isNotEmpty) {
      switch (type) {
        // Job Card Related
        case 'job_card':
        case 'jobcard':
        case 'job_card_ready':
        case 'job_card_approved':
        case 'job_card_completed':
          if (_openJobCard(extractedJob)) return;
          break;

        case 'job_card_cancelled':
          currentJobcardTab = 2; // Cancelled tab
          Get.offAll(() => BottomBarPage(2)); // Job Cards tab
          _refreshBookingsAfterNavigation();
          return;

        // Delivery & Progress Related
        case 'delivery_request':
          // Delivery request should open progress page even without job number
          _openProgressOrJobCards(extractedJob);
          return;
          
        case 'progress_update':
        case 'delivery_rejected':
        case 'reject_delivery':
        case 'rejecte_delivery': // Handle typo variant
        case 'task_completed':
        case 'delivery_scheduled':
          if (_openProgress(extractedJob)) return;
          break;

        // Booking & Pickup Related
        case 'new_booking':
        case 'emergency_booking':
        case 'emergerncy_booking': // Handle typo variant
        case 'car_checkup_booking':
        case 'quick_service_booking':
        case 'car_detailing_booking':
        case 'pickup_request':
        case 'car_pickup_request':
        case 'accept_booking':
        case 'booking_accepted':
        case 'accept booking':
        case 'booking_approved':
        case 'car_pickup_confirmation':
        case 'pickup_confirmation_request':
        case 'accept_pickup_confirmation':
          _openPickupTab();
          return;

        // Rejected/Cancelled Bookings
        case 'cancel_booking':
        case 'reject_booking':
        case 'pickup_confirmation_rejected':
          currentBookingTab = 2; // Rejected/Cancelled tab
          Get.offAll(() => BottomBarPage(1)); // Bookings tab
          _refreshBookingsAfterNavigation();
          return;

        // Invoice Related
        case 'invoice_ready':
        case 'invoice_generated':
          Get.to(() => MyInvoice());
          return;

        // Payment Related
        case 'job_card_payment':
        case 'payment_confirmed':
        case 'payment_confirmation':
          if (_openJobCard(extractedJob)) return;
          break;

        // Admin/Customer Messages - check if it's a delivery request
        case 'send_admin':
        case 'send_customer':
          // Check if this is actually a delivery confirmation request
          if (str.contains('Delivery') || str.contains('Please Confirm') || str.contains('confirm from job progress')) {
            _openProgressOrJobCards(extractedJob);
            return;
          }
          // Otherwise just show notification count
          log("🔔[NAV] Admin/Customer message notification");
          return;
      }
    }

    // ------------------- STRING FALLBACK -------------------
    // Check delivery-related notifications FIRST (higher priority)
    if (str.contains('Delivery') ||
        str.contains('Task Completed') ||
        str.contains('Scheduled') ||
        str.contains('Confirm Delivery') ||
        str.contains('Delivery Request') ||
        str.contains('confirm your delivery') ||
        str.contains('Please Confirm') ||
        str.contains("طلب توصيل") ||
        str.contains("تأكيد التوصيل") ||
        str.contains("مكتمل")) {
      // Use same logic as delivery_request type - navigate even without job number
      _openProgressOrJobCards(extractedJob);
      return;
    }

    if (str.contains('Invoice')) {
      Get.to(() => MyInvoice());
      return;
    }

    if (str.contains('Pickup') ||
        str.contains('Accept Booking') ||
        str.contains('New Booking') ||
        str.contains('Emergency') ||
        str.contains('Checkup') ||
        str.contains('Quick Service') ||
        str.contains('Detailing') ||
        str.contains("قبول الحجز") ||
        str.contains("تأكيد الاستلام") ||
        str.contains("حجز جديد")) {
      _openPickupTab();
      return;
    }

    if (str.contains('Reject Booking') ||
        str.contains('Cancel') ||
        str.contains('Cancelled') ||
        str.contains('Reject') ||
        str.contains("إلغاء") ||
        str.contains("رفض")) {
      currentBookingTab = 2;
      Get.offAll(() => BottomBarPage(1));
      _refreshBookingsAfterNavigation();
      return;
    }

    if (str.contains('Job Card') ||
        str.contains('Job Card Ready') ||
        str.contains('Job card is available') ||
        str.contains('Approved') ||
        str.contains('Completed') ||
        str.contains("بطاقة العمل") ||
        str.contains("اكتمل")) {
      _openJobCard(extractedJob);
      return;
    }

    if (str.contains('Payment Confirmed') ||
        str.contains('Payment Successful') ||
        str.contains('Your payment has been confirmed')) {
      _openJobCard(extractedJob);
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

  static void _openProgressOrJobCards(String? jobNumber) {
    print("🔔[NAV] ========== _openProgressOrJobCards CALLED ==========");
    print("🔔[NAV] _openProgressOrJobCards called with jobNumber: '$jobNumber'");
    log("🔔[NAV] _openProgressOrJobCards called with jobNumber: '$jobNumber'");
    if (jobNumber != null && jobNumber.isNotEmpty) {
      // If we have a job number, open that specific job's progress
      print("🔔[NAV] ✅ Job number found! Opening ProgressReportActive with job_number: $jobNumber");
      log("🔔[NAV] Opening ProgressReportActive with job_number: $jobNumber");
      currentJobcardTab = 3;
      
      print("🔔[NAV] Current route: ${Get.currentRoute}");
      print("🔔[NAV] Checking if already on ProgressReportActive...");
      
      // If already on ProgressReportActive, pop first then push
      if (Get.currentRoute.contains('ProgressReportActive')) {
        print("🔔[NAV] Already on ProgressReportActive - popping first...");
        Get.back();
        // Small delay to ensure page is popped
        Future.delayed(Duration(milliseconds: 100), () {
          print("🔔[NAV] Now pushing fresh ProgressReportActive...");
          Get.to(() => ProgressReportActive(job_number: jobNumber));
        });
      } else {
        print("🔔[NAV] Not on ProgressReportActive - pushing directly...");
        Get.to(() => ProgressReportActive(job_number: jobNumber));
      }
      
      print("🔔[NAV] Navigation command issued");
    } else {
      // If no job number, open Job Cards tab with delivery requests tab
      print("🔔[NAV] ⚠️ No job number provided. Opening Job Cards tab");
      log("🔔[NAV] Opening Job Cards tab (no job number provided)");
      currentJobcardTab = 3;
      Get.offAll(() => BottomBarPage(2)); // Job Cards tab (index 2)
      _refreshBookingsAfterNavigation();
    }
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
