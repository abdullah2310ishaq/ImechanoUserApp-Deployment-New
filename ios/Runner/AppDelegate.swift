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
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔑 Firebase registration token: \(String(describing: fcmToken))")
    
    // TestFlight specific logging
    if isTestFlight() {
        print("📱 TestFlight FCM Token: \(fcmToken ?? "nil")")
    }
    
    let dataDict:[String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
  
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    
    print("Will present notification with userInfo: \(userInfo)")
    
    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .badge, .sound]])
    } else {
      completionHandler([[.alert, .badge, .sound]])
    }
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    print("Did receive notification response with userInfo: \(userInfo)")
    
    completionHandler()
  }
}
