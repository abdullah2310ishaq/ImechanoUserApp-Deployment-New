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
    try {
      var str = title ?? message!.data.toString();
      final data = message?.data ?? <String, dynamic>{};
      final type =
          (data['type'] ?? data['action'] ?? '').toString().toLowerCase();
      final extractedJob = jobNo ?? data['job_number']?.toString();
      log('Notification route check => type: $type, title/body: $str, jobNo: $extractedJob, data: $data');

      // Use the provided context instead of Get.context
      try {
        Provider.of<NotificationCountProvider>(context, listen: false)
            .setNotifications();
      } catch (e) {
        log('Failed to update notification count in handleNotificationNavigation: $e');
      }
      // Prefer explicit type when available
      if (type.isNotEmpty) {
        if (type == 'job_card' || type == 'jobcard') {
          final jobNumber = extractedJob;
          if (jobNumber == null || jobNumber.isEmpty) {
            log('job_card: missing job_number in payload');
            return;
          }
          currentJobcardTab = 0;
          screenstack++;
          Get.to(() => MyJobCardDetails(job_number: jobNumber));
          return;
        }
        if (type == 'delivery_request' || type == 'progress_update') {
          final jobNumber = extractedJob;
          if (jobNumber == null || jobNumber.isEmpty) {
            log('delivery/progress: missing job_number in payload');
            return;
          }
          currentJobcardTab = 3;
          screenstack++;
          Get.to(() => ProgressReportActive(job_number: jobNumber));
          return;
        }
        if (type == 'pickup_request') {
          // Move to Approved tab and ensure UI shows green confirm state
          currentBookingTab = 3;
          screenstack++;
          Get.offAll(() => BottomBarPage(1));
          _refreshBookingsAfterNavigation(forceTab: 3);
          return;
        }
        if (type == 'accept_booking' || type == 'booking_accepted') {
          currentBookingTab = 3;
          screenstack++;
          Get.offAll(() => BottomBarPage(1));
          _refreshBookingsAfterNavigation();
          return;
        }
      }

      if (str.contains('Invoice is Ready!')) {
        Get.to(() => MyInvoice());
      }
      if (str.contains('Pickup') && str.contains('Accept') ||
          (str.contains('Pickup Confirmation Request')) ||
          (str.contains('Accept Booking')) ||
          str.contains("قبول الحجز") ||
          str.contains("ب تأكيد الاستلام")) {
        currentBookingTab = 3;
        screenstack++;
        Get.offAll(() => BottomBarPage(1));
        _refreshBookingsAfterNavigation();
      } else if (str.contains('Reject Booking')) {
        currentBookingTab = 2;
        screenstack++;
        Get.offAll(() => BottomBarPage(1));
        _refreshBookingsAfterNavigation();
      } else if (str.contains('Job Card') ||
          str.contains("تم تحميل بطاقة العمل")) {
        String? jobNumber = extractedJob ?? message!.data['job_number'];
        if (jobNumber == null) return;
        print("show Job Card Page");
        currentJobcardTab = 0;
        screenstack++;

        Get.to(() => MyJobCardDetails(job_number: jobNumber));
      } else if (str.contains('Task Completed') ||
          str.contains("تمت المهمة") ||
          str.contains('Please Confirm Delivery') ||
          str.contains('Delivery Request') ||
          str.contains("طلب توصيل")) {
        String? jobNumber = extractedJob ?? message!.data['job_number'];
        log('jobNumber $jobNumber');
        log('Before job number == null');
        if (jobNumber == null) return;
        log('After job number == null');
        currentJobcardTab = 3;
        screenstack++;
        log('Navigate now');
        Get.to(() => ProgressReportActive(job_number: jobNumber));
      }
    } on Exception catch (e) {
      log('Expection caught in handle notification navigation: $e');
    } catch (e) {
      log('Expection caught in handle notification navigation: $e');
    }
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
