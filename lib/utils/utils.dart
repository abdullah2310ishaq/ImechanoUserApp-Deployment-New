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
    log("🔔 [NOTIFICATION NAVIGATION] ================================================");
    log("🔔 [NOTIFICATION NAVIGATION] Starting notification navigation");
    log("🔔 [NOTIFICATION NAVIGATION] Context provided: YES");
    log("🔔 [NOTIFICATION NAVIGATION] Message provided: ${message != null ? 'YES' : 'NO'}");
    log("🔔 [NOTIFICATION NAVIGATION] Title provided: ${title ?? 'NULL'}");
    log("🔔 [NOTIFICATION NAVIGATION] JobNo provided: ${jobNo ?? 'NULL'}");

    try {
      var str = title ?? message!.data.toString();
      final data = message?.data ?? <String, dynamic>{};
      final type =
          (data['type'] ?? data['action'] ?? '').toString().toLowerCase();
      final extractedJob = jobNo ?? data['job_number']?.toString();

      log("🔔 [NOTIFICATION NAVIGATION] Extracted string: $str");
      log("🔔 [NOTIFICATION NAVIGATION] Message data: $data");
      log("🔔 [NOTIFICATION NAVIGATION] Extracted type: $type");
      log("🔔 [NOTIFICATION NAVIGATION] Extracted job number: $extractedJob");
      log("🔔 [NOTIFICATION NAVIGATION] Full data object: $data");

      // Use the provided context instead of Get.context
      try {
        log("🔔 [NOTIFICATION NAVIGATION] Updating notification count...");
        Provider.of<NotificationCountProvider>(context, listen: false)
            .setNotifications();
        log("🔔 [NOTIFICATION NAVIGATION] Notification count updated successfully");
      } catch (e) {
        log('🔔 [NOTIFICATION NAVIGATION] Failed to update notification count: $e');
      }

      // Prefer explicit type when available
      log("🔔 [NOTIFICATION NAVIGATION] Checking notification type: $type");
      if (type.isNotEmpty) {
        log("🔔 [NOTIFICATION NAVIGATION] Type is not empty, processing type-based navigation...");
        if (type == 'job_card' ||
            type == 'jobcard' ||
            type == 'job_card_ready') {
          log("🔔 [NOTIFICATION NAVIGATION] Processing job_card type notification");
          final jobNumber = extractedJob;
          log("🔔 [NOTIFICATION NAVIGATION] Job number for job_card: $jobNumber");
          if (jobNumber == null || jobNumber.isEmpty) {
            log('🔔 [NOTIFICATION NAVIGATION] job_card: missing job_number in payload');
            return;
          }
          log("🔔 [NOTIFICATION NAVIGATION] Setting currentJobcardTab to 0");
          currentJobcardTab = 0;
          screenstack++;
          log("🔔 [NOTIFICATION NAVIGATION] Navigating to MyJobCardDetails with job_number: $jobNumber");
          Get.to(() => MyJobCardDetails(job_number: jobNumber));
          log("🔔 [NOTIFICATION NAVIGATION] Navigation to MyJobCardDetails completed");
          return;
        }
        if (type == 'delivery_request' || type == 'progress_update') {
          log("🔔 [NOTIFICATION NAVIGATION] Processing delivery_request/progress_update type notification");
          final jobNumber = extractedJob;
          log("🔔 [NOTIFICATION NAVIGATION] Job number for delivery/progress: $jobNumber");
          if (jobNumber == null || jobNumber.isEmpty) {
            log('🔔 [NOTIFICATION NAVIGATION] delivery/progress: missing job_number in payload');
            return;
          }
          log("🔔 [NOTIFICATION NAVIGATION] Setting currentJobcardTab to 3");
          currentJobcardTab = 3;
          screenstack++;
          log("🔔 [NOTIFICATION NAVIGATION] Navigating to ProgressReportActive with job_number: $jobNumber");
          Get.to(() => ProgressReportActive(job_number: jobNumber));
          log("🔔 [NOTIFICATION NAVIGATION] Navigation to ProgressReportActive completed");
          return;
        }
        if (type == 'pickup_request') {
          log("🔔 [NOTIFICATION NAVIGATION] Processing pickup_request type notification");
          // Move to Approved tab and ensure UI shows green confirm state
          log("🔔 [NOTIFICATION NAVIGATION] Setting currentBookingTab to 3");
          currentBookingTab = 3;
          screenstack++;
          log("🔔 [NOTIFICATION NAVIGATION] Navigating to BottomBarPage(1) with offAll");
          Get.offAll(() => BottomBarPage(1));
          log("🔔 [NOTIFICATION NAVIGATION] Refreshing bookings after navigation");
          _refreshBookingsAfterNavigation(forceTab: 3);
          log("🔔 [NOTIFICATION NAVIGATION] Navigation to BottomBarPage completed");
          return;
        }
        if (type == 'accept_booking' ||
            type == 'booking_accepted' ||
            type == 'accept booking' ||
            type == 'booking_approved') {
          log("🔔 [NOTIFICATION NAVIGATION] Processing accept_booking type notification");
          log("🔔 [NOTIFICATION NAVIGATION] Setting currentBookingTab to 3");
          currentBookingTab = 3;
          screenstack++;
          log("🔔 [NOTIFICATION NAVIGATION] Navigating to BottomBarPage(1) with offAll");
          Get.offAll(() => BottomBarPage(1));
          log("🔔 [NOTIFICATION NAVIGATION] Refreshing bookings after navigation");
          _refreshBookingsAfterNavigation();
          log("🔔 [NOTIFICATION NAVIGATION] Navigation to BottomBarPage completed");
          return;
        }
        if (type == 'invoice_ready' || type == 'invoice_generated') {
          log("🔔 [NOTIFICATION NAVIGATION] Processing invoice_ready type notification");
          log("🔔 [NOTIFICATION NAVIGATION] Navigating to MyInvoice");
          Get.to(() => MyInvoice());
          log("🔔 [NOTIFICATION NAVIGATION] Navigation to MyInvoice completed");
          return;
        }
        if (type == 'job_card_payment' || type == 'payment_confirmed') {
          log("🔔 [NOTIFICATION NAVIGATION] Processing job_card_payment type notification");
          // Navigate to job card details after payment
          final jobNumber = extractedJob;
          log("🔔 [NOTIFICATION NAVIGATION] Job number for payment: $jobNumber");
          if (jobNumber != null && jobNumber.isNotEmpty) {
            log("🔔 [NOTIFICATION NAVIGATION] Setting currentJobcardTab to 0");
            currentJobcardTab = 0;
            screenstack++;
            log("🔔 [NOTIFICATION NAVIGATION] Navigating to MyJobCardDetails with job_number: $jobNumber");
            Get.to(() => MyJobCardDetails(job_number: jobNumber));
            log("🔔 [NOTIFICATION NAVIGATION] Navigation to MyJobCardDetails completed");
          } else {
            log("🔔 [NOTIFICATION NAVIGATION] Job number is null or empty, skipping navigation");
          }
          return;
        }
      }

      log("🔔 [NOTIFICATION NAVIGATION] Type-based navigation completed, checking string-based fallback...");
      log("🔔 [NOTIFICATION NAVIGATION] Checking string content: $str");

      if (str.contains('Invoice is Ready!') ||
          str.contains('Invoice Ready') ||
          str.contains('Your invoice is ready') ||
          str.contains('Invoice Generated')) {
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Processing invoice notification");
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigating to MyInvoice");
        Get.to(() => MyInvoice());
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigation to MyInvoice completed");
      }
      if (str.contains('Pickup') && str.contains('Accept') ||
          (str.contains('Pickup Confirmation Request')) ||
          (str.contains('Accept Booking')) ||
          str.contains("قبول الحجز") ||
          str.contains("ب تأكيد الاستلام")) {
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Processing pickup/accept notification");
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Setting currentBookingTab to 3");
        currentBookingTab = 3;
        screenstack++;
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigating to BottomBarPage(1) with offAll");
        Get.offAll(() => BottomBarPage(1));
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Refreshing bookings after navigation");
        _refreshBookingsAfterNavigation();
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigation to BottomBarPage completed");
      } else if (str.contains('Reject Booking')) {
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Processing reject booking notification");
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Setting currentBookingTab to 2");
        currentBookingTab = 2;
        screenstack++;
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigating to BottomBarPage(1) with offAll");
        Get.offAll(() => BottomBarPage(1));
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Refreshing bookings after navigation");
        _refreshBookingsAfterNavigation();
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigation to BottomBarPage completed");
      } else if (str.contains('Job Card') ||
          str.contains('Job Card Ready') ||
          str.contains('Your job card is ready') ||
          str.contains('Job card is available') ||
          str.contains("تم تحميل بطاقة العمل")) {
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Processing job card notification");
        String? jobNumber = extractedJob ?? message!.data['job_number'];
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Job number for job card: $jobNumber");
        if (jobNumber == null) {
          log("🔔 [NOTIFICATION NAVIGATION] String-based: Job number is null, returning");
          return;
        }
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Setting currentJobcardTab to 0");
        currentJobcardTab = 0;
        screenstack++;
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigating to MyJobCardDetails with job_number: $jobNumber");
        Get.to(() => MyJobCardDetails(job_number: jobNumber));
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigation to MyJobCardDetails completed");
      } else if (str.contains('Payment Confirmed') ||
          str.contains('Payment Successful') ||
          str.contains('Payment Received') ||
          str.contains('Your payment has been confirmed')) {
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Processing payment confirmation notification");
        // Navigate to job card after payment confirmation
        String? jobNumber = extractedJob ?? message!.data['job_number'];
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Job number for payment: $jobNumber");
        if (jobNumber != null && jobNumber.isNotEmpty) {
          log("🔔 [NOTIFICATION NAVIGATION] String-based: Setting currentJobcardTab to 0");
          currentJobcardTab = 0;
          screenstack++;
          log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigating to MyJobCardDetails with job_number: $jobNumber");
          Get.to(() => MyJobCardDetails(job_number: jobNumber));
          log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigation to MyJobCardDetails completed");
        } else {
          log("🔔 [NOTIFICATION NAVIGATION] String-based: Job number is null or empty, skipping navigation");
        }
      } else if (str.contains('Task Completed') ||
          str.contains("تمت المهمة") ||
          str.contains('Please Confirm Delivery') ||
          str.contains('Delivery Request') ||
          str.contains("طلب توصيل")) {
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Processing task completed/delivery notification");
        String? jobNumber = extractedJob ?? message!.data['job_number'];
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Job number for delivery: $jobNumber");
        if (jobNumber == null) {
          log("🔔 [NOTIFICATION NAVIGATION] String-based: Job number is null, returning");
          return;
        }
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Setting currentJobcardTab to 3");
        currentJobcardTab = 3;
        screenstack++;
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigating to ProgressReportActive with job_number: $jobNumber");
        Get.to(() => ProgressReportActive(job_number: jobNumber));
        log("🔔 [NOTIFICATION NAVIGATION] String-based: Navigation to ProgressReportActive completed");
      }
    } on Exception catch (e) {
      log('🔔 [NOTIFICATION NAVIGATION] Exception caught in handle notification navigation: $e');
      log('🔔 [NOTIFICATION NAVIGATION] Exception type: ${e.runtimeType}');
      log('🔔 [NOTIFICATION NAVIGATION] Exception stack trace: ${StackTrace.current}');
    } catch (e) {
      log('🔔 [NOTIFICATION NAVIGATION] General exception caught in handle notification navigation: $e');
      log('🔔 [NOTIFICATION NAVIGATION] Exception type: ${e.runtimeType}');
      log('🔔 [NOTIFICATION NAVIGATION] Exception stack trace: ${StackTrace.current}');
    }

    log("🔔 [NOTIFICATION NAVIGATION] ================================================");
    log("🔔 [NOTIFICATION NAVIGATION] Notification navigation completed");
  }

  /// Refresh bookings list for the current tab after navigation completes
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
      } catch (e) {
        log('Failed to refresh bookings after navigation: $e');
      }
    }

    // Immediate refresh
    Future.delayed(const Duration(milliseconds: 150), refreshOnce);
    // Follow-up refresh to catch backend state propagation
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
        fontSize: 16.0);
  }
}
