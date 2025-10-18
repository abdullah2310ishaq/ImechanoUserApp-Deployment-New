# iOS Push Notification Navigation Fix Guide

## Problem Overview

Push notifications are working fine on **Android** but not on **iOS**. The main issues are:

1. **iOS notifications only open the app** but don't navigate to the intended screen
2. **Android notifications correctly navigate** to specific pages based on notification content
3. **"Job Card" notifications** don't lead anywhere and need proper navigation setup
4. **Payload structure** may not be iOS-compatible for proper navigation

## Root Cause Analysis

After analyzing the codebase, the issue is in how iOS handles notification payloads vs Android:

### Current Android Behavior ✅
- Notifications automatically trigger navigation via `Utils.handleNotificationNavigation()`
- The navigation logic works through foreground message handling
- Payload data is properly extracted and processed

### Current iOS Behavior ❌
- iOS `AppDelegate.swift` only logs notification receipt but doesn't pass payload to Flutter
- The payload is not being forwarded to the Flutter layer for navigation processing
- iOS notification handling is incomplete in the native layer

## Technical Analysis

### Current Implementation Issues

1. **iOS AppDelegate Missing Payload Forwarding**
   ```swift
   // Current iOS implementation only logs but doesn't forward to Flutter
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
     let userInfo = response.notification.request.content.userInfo
     print("Did receive notification response with userInfo: \(userInfo)")
     completionHandler() // ❌ Missing Flutter channel communication
   }
   ```

2. **Navigation Logic Only Works Through Firebase Messaging**
   - Current navigation happens only through `FirebaseMessaging.onMessage` and `onMessageOpenedApp`
   - iOS tapped notifications bypass this flow

3. **Inconsistent Payload Structure**
   - The app expects specific payload fields: `type`, `job_number`, `title`
   - Backend may not be sending iOS-compatible payloads

## Required Backend Changes

### 1. iOS Notification Payload Structure

The backend must send notifications with **both** `notification` and `data` sections for iOS:

```json
{
  "to": "iOS_FCM_TOKEN",
  "notification": {
    "title": "Job Card Ready",
    "body": "Your vehicle job card is now available"
  },
  "data": {
    "type": "job_card",
    "job_number": "JOB123456",
    "action": "job_card",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "apns": {
    "payload": {
      "aps": {
        "alert": {
          "title": "Job Card Ready",
          "body": "Your vehicle job card is now available"
        },
        "sound": "default",
        "badge": 1
      }
    }
  }
}
```

### 2. Notification Types That Need Fixes

Based on the app code, these notification types need proper backend implementation:

| Notification Type | Current Backend Title | Required `type` Field | Required `data` Fields |
|------------------|----------------------|---------------------|----------------------|
| Job Card Ready | "Job Card" | `job_card` | `job_number` |
| Progress Update | "Task Completed" | `progress_update` | `job_number` |
| Delivery Request | "Please Confirm Delivery" | `delivery_request` | `job_number` |
| Pickup Request | "Pickup Confirmation Request" | `pickup_request` | `job_number` |
| Booking Accepted | "Accept Booking" | `accept_booking` | `job_number` |
| Invoice Ready | "Invoice is Ready!" | `invoice_ready` | `job_number` |

### 3. Recommended Payload Template

For **ALL** notification types, use this structure:

```json
{
  "to": "FCM_TOKEN",
  "notification": {
    "title": "Notification Title",
    "body": "Notification Body"
  },
  "data": {
    "type": "notification_type",
    "job_number": "JOB123456",
    "action": "notification_type",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "android": {
    "notification": {
      "channel_id": "high_importance_channel",
      "priority": "high"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "alert": {
          "title": "Notification Title",
          "body": "Notification Body"
        },
        "sound": "default",
        "badge": 1,
        "content-available": 1
      }
    }
  }
}
```

## Required iOS Native Code Changes

### Update AppDelegate.swift

Replace the current `didReceive` method with this implementation:

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
  let userInfo = response.notification.request.content.userInfo
  
  print("Did receive notification response with userInfo: \(userInfo)")
  
  // Forward notification data to Flutter
  if let flutterViewController = window?.rootViewController as? FlutterViewController {
    let channel = FlutterMethodChannel(name: "notification_channel", 
                                       binaryMessenger: flutterViewController.binaryMessenger)
    
    // Convert userInfo to Flutter-compatible format
    var flutterData: [String: Any] = [:]
    for (key, value) in userInfo {
      flutterData[key as! String] = value
    }
    
    // Send to Flutter
    channel.invokeMethod("onNotificationTapped", arguments: flutterData)
  }
  
  completionHandler()
}
```

## Required Flutter Code Changes

### 1. Add Method Channel Handler in main.dart

Add this to the `_IMechanoAppState` class:

```dart
static const platform = MethodChannel('notification_channel');

@override
void initState() {
  super.initState();
  
  // Existing code...
  
  // Handle iOS notification taps
  platform.setMethodCallHandler(_handleNotificationMethod);
}

Future<void> _handleNotificationMethod(MethodCall call) async {
  if (call.method == 'onNotificationTapped') {
    final data = Map<String, dynamic>.from(call.arguments);
    
    // Create a RemoteMessage-like object for iOS notifications
    final ctx = appNavigatorKey.currentContext;
    if (ctx != null) {
      final title = data['title'] ?? data['alert']?['title'] ?? '';
      final jobNo = data['job_number'] ?? data['jobNo'] ?? '';
      Utils.handleNotificationNavigation(ctx, null, title, jobNo);
    }
  }
}
```

## Specific Notification Issues & Fixes

### 1. "Job Card Updated" Notifications

**Problem**: These notifications don't navigate anywhere

**Solution**: 
- Backend should send `type: "job_card"` in payload
- Include `job_number` in data
- Use consistent title format

**Backend Payload Example**:
```json
{
  "notification": {
    "title": "Job Card Updated",
    "body": "Your vehicle job card has been updated"
  },
  "data": {
    "type": "job_card",
    "job_number": "JOB123456"
  }
}
```

### 2. Progress Update Notifications

**Current Issue**: Inconsistent naming and navigation

**Recommended Renaming**:
- Old: "Task Completed" → New: "Service Progress Update"
- Old: "Please Confirm Delivery" → New: "Delivery Confirmation Required"

## Testing Checklist

### Backend Developer Testing

1. **Send test notifications with proper payload structure**
2. **Verify both Android and iOS receive identical data fields**
3. **Test each notification type individually**
4. **Confirm `type` and `job_number` fields are always included**

### Flutter Developer Testing

1. **Test notification navigation on iOS**
2. **Verify foreground notifications show properly**
3. **Test background/killed app notification handling**
4. **Confirm notification count updates correctly**

## Implementation Priority

### Phase 1 (Critical) - Fix iOS Navigation
1. Update iOS AppDelegate.swift
2. Add Method Channel handler in Flutter
3. Test basic navigation working

### Phase 2 (Important) - Backend Payload Standardization  
1. Standardize all notification payloads
2. Ensure consistent `type` and `job_number` fields
3. Test all notification types

### Phase 3 (Nice to Have) - Notification Content Improvements
1. Rename confusing notification titles
2. Improve notification body content
3. Add localization support

## Summary

The main issue is that **iOS notifications are not forwarding payload data to Flutter** for navigation processing. The backend also needs to ensure **consistent payload structure** with proper `type` and `job_number` fields for all notifications.

**Key Action Items for Backend Developer**:
1. ✅ Add `type` field to ALL notification payloads
2. ✅ Add `job_number` field when applicable  
3. ✅ Use the standardized payload structure provided above
4. ✅ Test both Android and iOS receive identical data

**Key Action Items for iOS Developer**:
1. ✅ Update AppDelegate.swift to forward notification data to Flutter
2. ✅ Add Method Channel handler in main.dart
3. ✅ Test notification navigation on iOS devices