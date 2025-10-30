import UserNotifications
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import GoogleMaps
//import GooglePlaces

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
//      GMSPlacesClient.provideAPIKey("Your key")
      GMSServices.provideAPIKey("AIzaSyDx3BFhusvPEFSbiKdUsLaZUZaU8b0hRLM")
      
      // Debug: Check if running in TestFlight
      #if DEBUG
      print("🔧 DEBUG BUILD")
      #else
      print("🚀 RELEASE BUILD - TestFlight/AppStore")
      #endif
      
      // Check TestFlight environment
      if isTestFlight() {
          print("📱 Running in TestFlight")
      } else {
          print("🏪 Running in App Store or Development")
      }
      
      // Configure notifications for iOS
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { granted, error in
              print("📳 Notification permission granted: \(granted)")
              if let error = error {
                  print("❌ Notification error: \(error)")
              }
          })
      } else {
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }
      
      application.registerForRemoteNotifications()
      Messaging.messaging().delegate = self
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - TestFlight Detection
  private func isTestFlight() -> Bool {
      guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
          return false
      }
      return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
  }
  
  // MARK: - APNs Token Registration (for debugging)
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("🍎 [APNs] Device Token registered successfully!")
    print("🍎 [APNs] Token: \(token)")
    print("🍎 [APNs] Token length: \(token.count) characters")
    
    // Pass to Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    print("🍎 [APNs] Token passed to Firebase Messaging")
  }
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ [APNs] Failed to register for remote notifications!")
    print("❌ [APNs] Error: \(error.localizedDescription)")
    print("❌ [APNs] Full error: \(error)")
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔑 [FCM] ================================================")
    print("🔑 [FCM] Firebase registration token received!")
    print("🔑 [FCM] Token: \(fcmToken ?? "nil")")
    
    if let token = fcmToken {
        print("🔑 [FCM] Token length: \(token.count) characters")
        print("🔑 [FCM] First 20 chars: \(String(token.prefix(20)))...")
    } else {
        print("⚠️ [FCM] WARNING: Token is nil!")
    }
    
    // TestFlight specific logging
    if isTestFlight() {
        print("📱 [FCM] Running in TestFlight environment")
    }
    
    // Check APNs token
    if let apnsToken = Messaging.messaging().apnsToken {
        print("✅ [FCM] APNs token is set in Firebase Messaging")
        let tokenParts = apnsToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("✅ [FCM] APNs Token: \(token)")
    } else {
        print("⚠️ [FCM] WARNING: APNs token is NOT set in Firebase Messaging!")
        print("⚠️ [FCM] This may prevent push notifications from working")
    }
    
    print("🔑 [FCM] ================================================")
    
    let dataDict:[String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate {
  
  // Receive displayed notifications for iOS 10 devices.
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    
    print("📱 [IOS NATIVE] Will present notification")
    print("📱 [IOS NATIVE] User Info: \(userInfo)")
    print("📱 [IOS NATIVE] Sound: \(notification.request.content.sound?.description ?? "none")")
    
    // Show notification even when app is in foreground WITH SOUND
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .badge, .sound]])
    } else {
      completionHandler([[.alert, .badge, .sound]])
    }
  }
  
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    print("📱 [IOS NATIVE] ================================================")
    print("📱 [IOS NATIVE] Notification tapped!")
    print("📱 [IOS NATIVE] User Info: \(userInfo)")
    print("📱 [IOS NATIVE] Response Action ID: \(response.actionIdentifier)")
    print("📱 [IOS NATIVE] Notification Identifier: \(response.notification.request.identifier)")
    
    // Extract type to verify it's present
    if let type = userInfo["type"] as? String {
        print("📱 [IOS NATIVE] Type field found: \(type)")
    } else {
        print("📱 [IOS NATIVE] ⚠️ WARNING: Type field NOT found!")
    }
    
    // Convert userInfo to a format Flutter can receive
    print("📱 [IOS NATIVE] Converting notification data for Flutter...")
    var notificationData: [String: Any] = [:]
    
    // Extract APS data
    if let aps = userInfo["aps"] as? [String: Any] {
        if let alert = aps["alert"] as? [String: Any] {
            notificationData["title"] = alert["title"] as? String ?? ""
            notificationData["body"] = alert["body"] as? String ?? ""
        } else if let alert = aps["alert"] as? String {
            notificationData["body"] = alert
        }
    }
    
    // Extract all other fields (type, job_number, etc.)
    for (key, value) in userInfo {
        if let keyString = key as? String,
           keyString != "aps" && keyString != "gcm.message_id" && !keyString.hasPrefix("google.c.") {
            notificationData[keyString] = value
        }
    }
    
    print("📱 [IOS NATIVE] Notification data prepared: \(notificationData)")
    
    // Get Flutter view controller and send to Flutter via method channel
    if let controller = window?.rootViewController as? FlutterViewController {
        print("📱 [IOS NATIVE] Flutter controller found, invoking notification_tap method...")
        let channel = FlutterMethodChannel(name: "notification_channel", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("notification_tap", arguments: notificationData)
        print("📱 [IOS NATIVE] notification_tap method invoked successfully")
    } else {
        print("📱 [IOS NATIVE] ⚠️ WARNING: Could not get Flutter controller")
    }
    
    print("📱 [IOS NATIVE] ================================================")
    
    completionHandler()
  }
}
