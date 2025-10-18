# Notification Naming & Handling Improvements

## Current Notification Issues

Based on the code analysis, here are the notification-related issues that need to be addressed:

### 1. "Job Card Updated" Notifications

**Current Problem**: 
- The notification appears to use title "Job Card" but doesn't have proper navigation
- No specific handling for "updated" vs "ready" job cards

**Current Code Logic**:
```dart
} else if (str.contains('Job Card') ||
    str.contains("تم تحميل بطاقة العمل")) {
  String? jobNumber = extractedJob ?? message!.data['job_number'];
  if (jobNumber == null) return;
  print("show Job Card Page");
  currentJobcardTab = 0;
  screenstack++;
  Get.to(() => MyJobCardDetails(job_number: jobNumber));
}
```

**Recommended Changes**:

#### Backend Notification Names:
- Old: "Job Card" 
- New: "Job Card Ready" (for new job cards)
- New: "Job Card Updated" (for updates to existing job cards)

#### Payload Structure:
```json
{
  "notification": {
    "title": "Job Card Ready", // or "Job Card Updated"
    "body": "Your vehicle job card is now available for review"
  },
  "data": {
    "type": "job_card",
    "job_number": "JOB123456",
    "status": "ready" // or "updated"
  }
}
```

#### Updated Flutter Logic:
```dart
// Enhanced job card handling
if (type == 'job_card' || type == 'jobcard' || 
    str.contains('Job Card Ready') || str.contains('Job Card Updated')) {
  final jobNumber = extractedJob;
  if (jobNumber == null || jobNumber.isEmpty) {
    log('job_card: missing job_number in payload');
    return;
  }
  
  // Always navigate to job card details
  currentJobcardTab = 0;
  screenstack++;
  Get.to(() => MyJobCardDetails(job_number: jobNumber));
  return;
}
```

### 2. Progress Update Notifications

**Current Issues**:
- Multiple similar notification types with different names
- Confusing titles like "Task Completed" and "Please Confirm Delivery"

**Current Problematic Names**:
- "Task Completed"
- "Please Confirm Delivery" 
- "Delivery Request"

**Recommended Renaming**:

| Current Title | Recommended Title | User-Friendly Description |
|---------------|------------------|---------------------------|
| "Task Completed" | "Service Progress Update" | "Your vehicle service has new updates" |
| "Please Confirm Delivery" | "Delivery Confirmation Required" | "Please confirm you received your vehicle" |
| "Delivery Request" | "Vehicle Ready for Pickup" | "Your vehicle is ready for collection" |

### 3. Booking Status Notifications

**Current Issues**:
- Mixed language support
- Inconsistent navigation behavior

**Current Names & Issues**:
```dart
// Current problematic logic
if (str.contains('Pickup') && str.contains('Accept') ||
    (str.contains('Pickup Confirmation Request')) ||
    (str.contains('Accept Booking')) ||
    str.contains("قبول الحجز") ||
    str.contains("ب تأكيد الاستلام")) {
```

**Recommended Standardization**:

| Notification Type | English Title | Arabic Title | Navigation Action |
|------------------|---------------|--------------|------------------|
| Booking Accepted | "Booking Confirmed" | "تم تأكيد الحجز" | Go to Approved Bookings |
| Pickup Request | "Pickup Confirmation Required" | "تأكيد الاستلام مطلوب" | Go to Approved Bookings |
| Booking Rejected | "Booking Declined" | "تم رفض الحجز" | Go to Rejected Bookings |

## Recommended Implementation Changes

### 1. Add Specific Notification Types

Update the Utils.dart to handle more specific types:

```dart
static void handleNotificationNavigation(BuildContext context,
    [RemoteMessage? message, String? title, String? jobNo]) {
  try {
    var str = title ?? message!.data.toString();
    final data = message?.data ?? <String, dynamic>{};
    final type = (data['type'] ?? data['action'] ?? '').toString().toLowerCase();
    final extractedJob = jobNo ?? data['job_number']?.toString();
    
    log('Notification route check => type: $type, title/body: $str, jobNo: $extractedJob, data: $data');

    // Update notification count
    try {
      Provider.of<NotificationCountProvider>(context, listen: false)
          .setNotifications();
    } catch (e) {
      log('Failed to update notification count: $e');
    }

    // Enhanced type-based navigation
    switch (type) {
      case 'job_card':
      case 'job_card_ready':
      case 'job_card_updated':
        _navigateToJobCard(extractedJob);
        break;
        
      case 'service_progress':
      case 'progress_update':
      case 'delivery_confirmation':
        _navigateToProgressReport(extractedJob);
        break;
        
      case 'pickup_request':
      case 'pickup_confirmation':
        _navigateToPickupConfirmation();
        break;
        
      case 'booking_accepted':
      case 'booking_confirmed':
        _navigateToApprovedBookings();
        break;
        
      case 'booking_rejected':
      case 'booking_declined':
        _navigateToRejectedBookings();
        break;
        
      case 'invoice_ready':
        _navigateToInvoice(extractedJob);
        break;
        
      default:
        _handleLegacyNotification(str, extractedJob);
        break;
    }
  } catch (e) {
    log('Exception in handleNotificationNavigation: $e');
  }
}

// Helper methods for cleaner navigation
static void _navigateToJobCard(String? jobNumber) {
  if (jobNumber == null || jobNumber.isEmpty) {
    log('job_card: missing job_number in payload');
    return;
  }
  currentJobcardTab = 0;
  screenstack++;
  Get.to(() => MyJobCardDetails(job_number: jobNumber));
}

static void _navigateToProgressReport(String? jobNumber) {
  if (jobNumber == null || jobNumber.isEmpty) {
    log('progress_update: missing job_number in payload');
    return;
  }
  currentJobcardTab = 3;
  screenstack++;
  Get.to(() => ProgressReportActive(job_number: jobNumber));
}

static void _navigateToPickupConfirmation() {
  currentBookingTab = 3;
  screenstack++;
  Get.offAll(() => BottomBarPage(1));
  _refreshBookingsAfterNavigation(forceTab: 3);
}

static void _navigateToApprovedBookings() {
  currentBookingTab = 3;
  screenstack++;
  Get.offAll(() => BottomBarPage(1));
  _refreshBookingsAfterNavigation();
}

static void _navigateToRejectedBookings() {
  currentBookingTab = 2;
  screenstack++;
  Get.offAll(() => BottomBarPage(1));
  _refreshBookingsAfterNavigation();
}

static void _navigateToInvoice(String? jobNumber) {
  Get.to(() => MyInvoice());
}

// Keep existing logic for backward compatibility
static void _handleLegacyNotification(String str, String? extractedJob) {
  // Current string-based logic as fallback
  if (str.contains('Invoice is Ready!')) {
    Get.to(() => MyInvoice());
  }
  // ... rest of existing logic
}
```

### 2. Backend Notification Type Mapping

Here's what the backend should send for each notification:

```json
// Job Card Ready
{
  "notification": {
    "title": "Job Card Ready",
    "body": "Your vehicle service details are now available"
  },
  "data": {
    "type": "job_card_ready",
    "job_number": "JOB123456"
  }
}

// Job Card Updated  
{
  "notification": {
    "title": "Job Card Updated", 
    "body": "Your vehicle service details have been updated"
  },
  "data": {
    "type": "job_card_updated",
    "job_number": "JOB123456"
  }
}

// Service Progress Update
{
  "notification": {
    "title": "Service Progress Update",
    "body": "Your vehicle service has new updates"
  },
  "data": {
    "type": "service_progress",
    "job_number": "JOB123456"
  }
}

// Delivery Confirmation Required
{
  "notification": {
    "title": "Delivery Confirmation Required",
    "body": "Please confirm you received your vehicle"
  },
  "data": {
    "type": "delivery_confirmation", 
    "job_number": "JOB123456"
  }
}

// Pickup Confirmation Required
{
  "notification": {
    "title": "Pickup Confirmation Required",
    "body": "Please confirm your vehicle pickup appointment"
  },
  "data": {
    "type": "pickup_confirmation",
    "job_number": "JOB123456"
  }
}
```

## Migration Strategy

### Phase 1: Add New Type Handling
1. Update Utils.dart with new type-based switch statement
2. Keep existing string-based logic as fallback
3. Test with current notification formats

### Phase 2: Backend Updates
1. Update backend to send new notification types
2. Ensure backward compatibility during transition
3. Test both old and new formats work

### Phase 3: Clean Up
1. Remove legacy string-based notification handling
2. Standardize all notification content
3. Add proper localization support

## Testing Requirements

### For Each Notification Type:
1. ✅ **Foreground**: App open, notification appears and navigates correctly
2. ✅ **Background**: App in background, tapping notification navigates correctly  
3. ✅ **Killed**: App closed, tapping notification opens app and navigates correctly
4. ✅ **iOS**: All scenarios work on iOS devices
5. ✅ **Android**: All scenarios continue working on Android

### Test Cases:
- Job Card Ready notification → Opens Job Card Details
- Job Card Updated notification → Opens Job Card Details  
- Service Progress notification → Opens Progress Report
- Delivery Confirmation notification → Opens Progress Report
- Pickup Confirmation notification → Opens Approved Bookings
- Invoice Ready notification → Opens Invoice

This approach will make notifications much clearer for users and easier to maintain for developers.