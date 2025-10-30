// ignore_for_file: await_only_futures, deprecated_member_use
import 'dart:developer';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:imechano/localization/app_localization.dart';
import 'package:imechano/ui/privacy_disp.dart';
import 'package:imechano/ui/provider/invoice_balance_provider.dart';
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:imechano/ui/provider/theme_provider.dart';
import 'package:imechano/ui/services/notification_service.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/screens/select_car/view/edit_details_screen.dart';
import 'package:imechano/ui/share_preferences/pref_key.dart';
import 'package:imechano/ui/share_preferences/preference.dart';
import 'package:imechano/ui/styling/global.dart';
import 'package:imechano/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:imechano/ui/bloc/booking_list_bloc.dart';
import 'package:imechano/ui/bloc/customer_job_cards_list_bloc.dart';
import 'package:imechano/ui/bloc/pickup_condition_list_bloc.dart';
import 'package:imechano/ui/common/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ui/screens/auth/landing/view/sign_in_sign_up_landing_screen.dart';
import '../ui/screens/auth/sign_in/view/sign_in_screen.dart';
import '../ui/screens/auth/sign_up/view/sign_up_screen.dart';
import '../ui/screens/language/view/language_choose_screen.dart';
import '../ui/screens/on_boarding/view/on_boarding_screen.dart';
import '../ui/screens/select_car/view/select_your_car_screen.dart';
import '../ui/screens/splash/view/splash_screen.dart';
import 'firebase_options.dart';

// iOS notification method channel
const MethodChannel notificationChannel = MethodChannel('notification_channel');

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔔 [BACKGROUND] Handling a background message ${message.messageId}');
  print('🔔 [BACKGROUND] Title: ${message.notification?.title}');
  print('🔔 [BACKGROUND] Body: ${message.notification?.body}');
  print('🔔 [BACKGROUND] Data: ${message.data}');
}

// /// Create a [AndroidNotificationChannel] for heads up notifications
// late AndroidNotificationChannel channel;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

int? initScreen;
// Global navigator key to access provider from FCM callbacks
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Initialize Firebase with options (REQUIRED for Android FCM)
  print('🔔 [MAIN] Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('🔔 [MAIN] Firebase initialized successfully');

  // ✅ Register background message handler (MUST be called in main, before runApp)
  print('🔔 [MAIN] Registering background message handler...');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  print('🔔 [MAIN] Background handler registered');

  // ✅ Set up iOS notification method channel handler EARLY (before runApp)
  print('🔔🔔🔔 [MAIN] === ABOUT TO CHECK PLATFORM ===');
  print('🔔🔔🔔 [MAIN] Checking platform: ${Platform.operatingSystem}');
  print('🔔🔔🔔 [MAIN] Platform.isIOS: ${Platform.isIOS}');
  print('🔔🔔🔔 [MAIN] Platform.isAndroid: ${Platform.isAndroid}');
  
  print('🔔🔔🔔 [MAIN] Platform check complete - about to check if iOS...');
  
  if (Platform.isIOS) {
    log("🔔🔔🔔 [MAIN] ✅✅✅ YES - PLATFORM IS iOS - SETTING UP HANDLER");
    print("🔔🔔🔔 [MAIN] ✅✅✅ YES - PLATFORM IS iOS - SETTING UP HANDLER");
    notificationChannel.setMethodCallHandler((call) async {
      print("🔔 [IOS METHOD CHANNEL - MAIN] ================================================");
      print("🔔 [IOS METHOD CHANNEL - MAIN] Method called: ${call.method}");
      print("🔔 [IOS METHOD CHANNEL - MAIN] Call arguments: ${call.arguments}");
      log("🔔 [IOS METHOD CHANNEL - MAIN] ================================================");
      log("🔔 [IOS METHOD CHANNEL - MAIN] Method called: ${call.method}");
      
      if (call.method == 'notification_tap') {
        print("🔔 [IOS METHOD CHANNEL - MAIN] Notification tap received from iOS!");
        log("🔔 [IOS METHOD CHANNEL - MAIN] Notification tap received from iOS!");
        log("🔔 [IOS METHOD CHANNEL - MAIN] Arguments: ${call.arguments}");
        
        try {
          print("🔔 [IOS METHOD CHANNEL - MAIN] About to parse data...");
          // Safely convert iOS data to Map<String, dynamic>
          final rawData = call.arguments as Map;
          final data = Map<String, dynamic>.from(
            rawData.map((key, value) => MapEntry(key.toString(), value))
          );
          print("🔔 [IOS METHOD CHANNEL - MAIN] Data parsed successfully: $data");
          log("🔔 [IOS METHOD CHANNEL - MAIN] Data parsed: $data");
          
          print("🔔 [IOS METHOD CHANNEL - MAIN] Extracting fields...");
          final title = data['title']?.toString() ?? '';
          final body = data['body']?.toString() ?? '';
          final type = data['type']?.toString() ?? '';
          final jobNo = (data['job_number'] ?? data['jobNo'] ?? data['jobno'])?.toString();
          
          print("🔔 [IOS METHOD CHANNEL - MAIN] Extracted - Title: $title");
          log("🔔 [IOS METHOD CHANNEL - MAIN] Extracted - Title: $title");
          print("🔔 [IOS METHOD CHANNEL - MAIN] Extracted - Body: $body");
          log("🔔 [IOS METHOD CHANNEL - MAIN] Extracted - Body: $body");
          print("🔔 [IOS METHOD CHANNEL - MAIN] Extracted - Type: $type");
          log("🔔 [IOS METHOD CHANNEL - MAIN] Extracted - Type: $type");
          print("🔔 [IOS METHOD CHANNEL - MAIN] Extracted - JobNo: $jobNo");
          log("🔔 [IOS METHOD CHANNEL - MAIN] Extracted - JobNo: $jobNo");
          
          print("🔔 [IOS METHOD CHANNEL - MAIN] Creating RemoteMessage...");
          // Create a fake RemoteMessage with the data
          final fakeMessage = RemoteMessage(data: data);
          print("🔔 [IOS METHOD CHANNEL - MAIN] RemoteMessage created successfully");
          
          print("🔔 [IOS METHOD CHANNEL - MAIN] Waiting 500ms for context...");
          // Wait for context to be available
          await Future.delayed(Duration(milliseconds: 500));
          
          print("🔔 [IOS METHOD CHANNEL - MAIN] Checking for context...");
          final ctx = appNavigatorKey.currentContext;
          print("🔔 [IOS METHOD CHANNEL - MAIN] Context available: ${ctx != null ? 'YES' : 'NO'}");
          if (ctx != null) {
            print("🔔 [IOS METHOD CHANNEL - MAIN] Context available, calling navigation...");
            print("🔔 [IOS METHOD CHANNEL - MAIN] ====== CALLING Utils.handleNotificationNavigation ======");
            print("🔔 [IOS METHOD CHANNEL - MAIN] Parameters - Title: '$title', JobNo: '$jobNo'");
            print("🔔 [IOS METHOD CHANNEL - MAIN] Message data: ${fakeMessage.data}");
            log("🔔 [IOS METHOD CHANNEL - MAIN] Context available, calling navigation...");
            Utils.handleNotificationNavigation(ctx, fakeMessage, title, jobNo);
            print("🔔 [IOS METHOD CHANNEL - MAIN] ====== Utils.handleNotificationNavigation RETURNED ======");
            print("🔔 [IOS METHOD CHANNEL - MAIN] Navigation called successfully");
            log("🔔 [IOS METHOD CHANNEL - MAIN] Navigation called successfully");
            
            // Update notification count
            try {
              Provider.of<NotificationCountProvider>(ctx, listen: false).setNotifications();
              log("🔔 [IOS METHOD CHANNEL - MAIN] Notification count updated");
            } catch (e) {
              log("🔔 [IOS METHOD CHANNEL - MAIN] Failed to update notification count: $e");
            }
          } else {
            log("🔔 [IOS METHOD CHANNEL - MAIN] ⚠️ Context not available yet, will retry...");
            // Retry after app is fully loaded
            Future.delayed(Duration(seconds: 1), () async {
              final retryCtx = appNavigatorKey.currentContext;
              if (retryCtx != null) {
                log("🔔 [IOS METHOD CHANNEL - MAIN] Retry: Context available, calling navigation...");
                Utils.handleNotificationNavigation(retryCtx, fakeMessage, title, jobNo);
              } else {
                log("🔔 [IOS METHOD CHANNEL - MAIN] Retry: Still no context available");
              }
            });
          }
        } catch (e, stackTrace) {
          print("🔔 [IOS METHOD CHANNEL - MAIN] ❌❌❌ ERROR CAUGHT: $e");
          print("🔔 [IOS METHOD CHANNEL - MAIN] ❌❌❌ Stack trace: $stackTrace");
          log("🔔 [IOS METHOD CHANNEL - MAIN] Error handling notification tap: $e");
          log("🔔 [IOS METHOD CHANNEL - MAIN] Stack trace: $stackTrace");
        }
      }
      
      log("🔔 [IOS METHOD CHANNEL - MAIN] ================================================");
      print("🔔 [IOS METHOD CHANNEL - MAIN] ================================================");
    });
    log("🔔🔔🔔 [MAIN] iOS notification handler setup complete ✅✅✅");
    print("🔔🔔🔔 [MAIN] iOS notification handler setup complete ✅✅✅");
  } else {
    print("🔔🔔🔔 [MAIN] ❌❌❌ NOT iOS - Platform is: ${Platform.operatingSystem}");
  }
  
  print("🔔🔔🔔 [MAIN] === PLATFORM SETUP COMPLETE - CONTINUING TO APP INIT ===");

  // Initialize local notifications plugin
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // //===========CRASHLYTICS==========

  // // Pass all uncaught "fatal" errors from the framework to Crashlytics
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // FirebaseCrashlytics.instance.crash();
  FlutterNativeSplash.remove();

  Provider.debugCheckInvalidValueType = null;
  SharedPreferences preferences = await SharedPreferences.getInstance();
  initScreen = await preferences.getInt('initScreen');
  await preferences.setInt('initScreen', 1);

  final Directory appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  await Hive.openBox('imechano').then(
    (value) => runApp(
      ChangeNotifierProvider(
        create: (context) => AppModel(),
        child: IMechanoApp(
          prefs: value,
          appLanguage: "en",
        ),
      ),
    ),
  );
}

Future<void> initialization(BuildContext context) async {
  // No-op: native splash is removed immediately; avoid artificial delays
}

class IMechanoApp extends StatefulWidget {
  final GlobalKey<NavigatorState> key = new GlobalKey<NavigatorState>();

  IMechanoApp({required this.prefs, required this.appLanguage});
  final Box prefs;
  final String appLanguage;
  
  // NOTE: StatefulWidget should NOT have a build method!
  // The build method belongs to the State class (_IMechanoAppState)

  @override
  _IMechanoAppState createState() => _IMechanoAppState(prefs: prefs);
}

class _IMechanoAppState extends State<IMechanoApp> with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  _IMechanoAppState({required this.prefs});
  Box prefs;
  AppModel appModel = new AppModel();
  void notification() async {
    // Initialize local notifications for both platforms
    await _initializeLocalNotifications();

    log("🔔 [NOTIFICATION PERMISSION] ================================================");
    log("🔔 [NOTIFICATION PERMISSION] Requesting notification permissions...");
    log("🔔 [NOTIFICATION PERMISSION] Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");

    // For Android 13+ (API 33+), explicitly request POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      log("🔔 [NOTIFICATION PERMISSION] Android detected - checking notification permission");
      
      // Check current permission status first
      final currentStatus = await Permission.notification.status;
      log("🔔 [NOTIFICATION PERMISSION] Current Android notification status: $currentStatus");
      
      if (!currentStatus.isGranted) {
        log("🔔 [NOTIFICATION PERMISSION] Permission not granted - requesting POST_NOTIFICATIONS permission");
        final status = await Permission.notification.request();
        log("🔔 [NOTIFICATION PERMISSION] Android POST_NOTIFICATIONS request result: $status");
        
        if (status.isDenied) {
          log('🔔 [NOTIFICATION PERMISSION] Android: User denied POST_NOTIFICATIONS permission');
        } else if (status.isGranted) {
          log('🔔 [NOTIFICATION PERMISSION] Android: User granted POST_NOTIFICATIONS permission');
        } else if (status.isPermanentlyDenied) {
          log('🔔 [NOTIFICATION PERMISSION] Android: POST_NOTIFICATIONS permanently denied - open settings');
          // Optionally, guide user to app settings
          // await openAppSettings();
        } else if (status.isRestricted) {
          log('🔔 [NOTIFICATION PERMISSION] Android: POST_NOTIFICATIONS is restricted');
        } else if (status.isLimited) {
          log('🔔 [NOTIFICATION PERMISSION] Android: POST_NOTIFICATIONS is limited');
        }
      } else {
        log("🔔 [NOTIFICATION PERMISSION] Android: POST_NOTIFICATIONS already granted");
      }
    }

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional:
          false, // Set to true for iOS to avoid repeated permission requests
      sound: true,
    );

    log("🔔 [NOTIFICATION PERMISSION] Permission request completed");
    log('🔔 [NOTIFICATION PERMISSION] User granted permission: ${settings.authorizationStatus}');
    log("🔔 [NOTIFICATION PERMISSION] Alert setting: ${settings.alert}");
    log("🔔 [NOTIFICATION PERMISSION] Badge setting: ${settings.badge}");
    log("🔔 [NOTIFICATION PERMISSION] Sound setting: ${settings.sound}");
    log("🔔 [NOTIFICATION PERMISSION] Announcement setting: ${settings.announcement}");
    log("🔔 [NOTIFICATION PERMISSION] CarPlay setting: ${settings.carPlay}");
    log("🔔 [NOTIFICATION PERMISSION] Critical alert setting: ${settings.criticalAlert}");
    log("🔔 [NOTIFICATION PERMISSION] Provisional setting: N/A (not available in this version)");
    log("🔔 [NOTIFICATION PERMISSION] ================================================");

    // Handle different authorization statuses
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('🔔 [NOTIFICATION PERMISSION] User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('🔔 [NOTIFICATION PERMISSION] User denied notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      log('🔔 [NOTIFICATION PERMISSION] User has not yet granted or denied permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('🔔 [NOTIFICATION PERMISSION] User granted provisional notification permission');
    }

    // ✅ Background handler already registered in main() - no need to register again
    print('🔔 [NOTIFICATION] Setup complete - background handler already registered in main()');
  }

  // Initialize local notifications for iOS
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("🔔 [LOCAL NOTIFICATION TAP] ================================================");
        log("🔔 [LOCAL NOTIFICATION TAP] Local notification tapped");
        log("🔔 [LOCAL NOTIFICATION TAP] Response ID: ${response.id}");
        log("🔔 [LOCAL NOTIFICATION TAP] Response Action ID: ${response.actionId}");
        log("🔔 [LOCAL NOTIFICATION TAP] Response Input: ${response.input}");
        log("🔔 [LOCAL NOTIFICATION TAP] Response Payload: ${response.payload}");
        log("🔔 [LOCAL NOTIFICATION TAP] Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");
        log("🔔 [LOCAL NOTIFICATION TAP] ================================================");

        try {
          final ctx = appNavigatorKey.currentContext;
          final payload = response.payload;
          log("🔔 [LOCAL NOTIFICATION TAP] Context available: ${ctx != null ? 'YES' : 'NO'}");
          log("🔔 [LOCAL NOTIFICATION TAP] Payload available: ${payload != null && payload.isNotEmpty ? 'YES' : 'NO'}");

          if (ctx != null && payload != null && payload.isNotEmpty) {
            Map<String, dynamic>? data;
            try {
              log("🔔 [LOCAL NOTIFICATION TAP] Decoding JSON payload...");
              data = jsonDecode(payload) as Map<String, dynamic>;
              log("🔔 [LOCAL NOTIFICATION TAP] JSON decoded successfully: $data");
            } catch (e) {
              log('🔔 [LOCAL NOTIFICATION TAP] Failed to decode notification payload as JSON: $e');
            }

            // Create a RemoteMessage-like object from the payload data
            final title = (data?['title'] ?? '').toString();
            final body = (data?['body'] ?? '').toString();
            final jobNo =
                (data?['job_number'] ?? data?['jobNo'] ?? data?['jobno'])
                    ?.toString();
            log("🔔 [LOCAL NOTIFICATION TAP] Extracted Title: $title");
            log("🔔 [LOCAL NOTIFICATION TAP] Extracted Body: $body");
            log("🔔 [LOCAL NOTIFICATION TAP] Extracted JobNo: $jobNo");
            log("🔔 [LOCAL NOTIFICATION TAP] Extracted Data: $data");
            
            // Create a fake RemoteMessage with the data to pass type info
            final fakeMessage = RemoteMessage(
              data: data ?? {},
            );
            
            log("🔔 [LOCAL NOTIFICATION TAP] Calling Utils.handleNotificationNavigation with message data...");
            Utils.handleNotificationNavigation(ctx, fakeMessage, title, jobNo);
            log("🔔 [LOCAL NOTIFICATION TAP] Utils.handleNotificationNavigation completed");
          } else {
            log("🔔 [LOCAL NOTIFICATION TAP] Skipping navigation - Context or payload missing");
          }
        } catch (e) {
          log('🔔 [LOCAL NOTIFICATION TAP] Error handling notification tap: $e');
        }
      },
    );

    // Bind plugin to NotificationService so app-wide code can trigger local notifications
    NotificationService.bindLocalNotifications(
      flutterLocalNotificationsPlugin,
      channelId: channel.id,
      channelName: 'High Importance Notifications',
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // Show local notification for iOS
  Future<void> _showLocalNotification(RemoteMessage message) async {
    log("🔔 [SHOW LOCAL NOTIFICATION] ================================================");
    log("🔔 [SHOW LOCAL NOTIFICATION] Creating local notification");
    log("🔔 [SHOW LOCAL NOTIFICATION] Message ID: ${message.messageId}");
    log("🔔 [SHOW LOCAL NOTIFICATION] Message Data: ${message.data}");
    log("🔔 [SHOW LOCAL NOTIFICATION] Notification Title: ${message.notification?.title}");
    log("🔔 [SHOW LOCAL NOTIFICATION] Notification Body: ${message.notification?.body}");
    log("🔔 [SHOW LOCAL NOTIFICATION] Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final payload = {
      ...message.data,
      'title': message.notification?.title ?? message.data['title'] ?? '',
      'body': message.notification?.body ?? message.data['body'] ?? '',
    };

    log("🔔 [SHOW LOCAL NOTIFICATION] Payload to encode: $payload");
    final encodedPayload = jsonEncode(payload);
    log("🔔 [SHOW LOCAL NOTIFICATION] Encoded payload: $encodedPayload");

    final notificationId = message.hashCode;
    final notificationTitle = message.notification?.title ?? 'New Notification';
    final notificationBody =
        message.notification?.body ?? 'You have a new message';

    log("🔔 [SHOW LOCAL NOTIFICATION] Notification ID: $notificationId");
    log("🔔 [SHOW LOCAL NOTIFICATION] Notification Title: $notificationTitle");
    log("🔔 [SHOW LOCAL NOTIFICATION] Notification Body: $notificationBody");
    log("🔔 [SHOW LOCAL NOTIFICATION] Showing notification...");

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationBody,
      platformChannelSpecifics,
      payload: encodedPayload,
    );

    log("🔔 [SHOW LOCAL NOTIFICATION] Local notification shown successfully");
    log("🔔 [SHOW LOCAL NOTIFICATION] ================================================");
  }

  @override
  void initState() {
    print("========== INIT STATE CALLED ==========");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAppTheme();
    
    print("========== AFTER INIT THEME ==========");
    log("🔔🔔🔔 [INIT STATE] _IMechanoAppState initState() called!");
    log("🔔🔔🔔 [INIT STATE] About to setup notifications...");

    // ✅ iOS notification method channel handler is already set up in main()
    // No need to set it up again here to avoid conflicts
    log("🔔 [INIT STATE] iOS notification handler already set up in main() function");

    try {
      print("========== ABOUT TO PRINT TOKEN ==========");
      log("Printing TOKEN");
      _firebaseMessaging.getToken().then((value) {
        print("========== FCM TOKEN: $value ==========");
        log(value.toString());
      }).catchError((error) {
        print("========== ERROR GETTING TOKEN: $error ==========");
      });
      print("========== CALLING notification() ==========");
      notification();
      print("========== notification() CALLED SUCCESSFULLY ==========");
    } catch (e, stackTrace) {
      print("========== CRITICAL ERROR IN INIT STATE: $e ==========");
      print("========== STACK TRACE: $stackTrace ==========");
    }

    // Initialize notification count on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final ctx = appNavigatorKey.currentContext;
        if (ctx != null) {
          Provider.of<NotificationCountProvider>(ctx, listen: false)
              .setNotifications();
        }
      } catch (e) {
        log('Failed to initialize notification count: $e');
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      log("🔔 [INITIAL MESSAGE] ================================================");
      log("🔔 [INITIAL MESSAGE] Message received: ${message != null ? 'YES' : 'NO'}");
      if (message != null) {
        log("🔔 [INITIAL MESSAGE] Message ID: ${message.messageId}");
        log("🔔 [INITIAL MESSAGE] Data: ${message.data}");
        log("🔔 [INITIAL MESSAGE] Notification Title: ${message.notification?.title}");
        log("🔔 [INITIAL MESSAGE] Notification Body: ${message.notification?.body}");
        log("🔔 [INITIAL MESSAGE] From: ${message.from}");
        log("🔔 [INITIAL MESSAGE] Sent Time: ${message.sentTime}");
        log("🔔 [INITIAL MESSAGE] TTL: ${message.ttl}");
        log("🔔 [INITIAL MESSAGE] ================================================");

        // Defer navigation to after first frame to ensure navigator is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            final ctx = appNavigatorKey.currentContext ?? context;
            log("🔔 [INITIAL MESSAGE] Context available: YES");
            log("🔔 [INITIAL MESSAGE] App Navigator Key Context: ${appNavigatorKey.currentContext != null ? 'YES' : 'NO'}");
            log("🔔 [INITIAL MESSAGE] Fallback Context: YES");

            final meta = _extractNotificationMeta(message);
            final title = meta['title'];
            final jobNo = meta['jobNo'];
            log("🔔 [INITIAL MESSAGE] Extracted Title: $title");
            log("🔔 [INITIAL MESSAGE] Extracted JobNo: $jobNo");

            log("🔔 [INITIAL MESSAGE] Calling Utils.handleNotificationNavigation...");
            Utils.handleNotificationNavigation(ctx, null, title, jobNo);
            log("🔔 [INITIAL MESSAGE] Utils.handleNotificationNavigation completed");
          } catch (e) {
            log("🔔 [INITIAL MESSAGE] Error in post-frame callback: $e");
            final ctx = appNavigatorKey.currentContext ?? context;
            log("🔔 [INITIAL MESSAGE] Fallback: Calling Utils.handleNotificationNavigation with message...");
            Utils.handleNotificationNavigation(ctx, message, null);
          }
        });
      } else {
        log("🔔 [INITIAL MESSAGE] No initial message found");
      }
    });

    // onMessage: When the app is open and it receives a push notification
    // Ensure iOS shows alerts when app is in foreground
    if (Platform.isIOS) {
      log("🔔 [iOS FOREGROUND] ================================================");
      log("🔔 [iOS FOREGROUND] Setting iOS foreground notification presentation options");
      log("🔔 [iOS FOREGROUND] Alert: true, Badge: true, Sound: true");
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      log("🔔 [iOS FOREGROUND] iOS foreground notification options set successfully");
      log("🔔 [iOS FOREGROUND] ================================================");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("🔔 [ON MESSAGE] ================================================");
      log("🔔 [ON MESSAGE] App is in FOREGROUND - Message received");
      log("🔔 [ON MESSAGE] Message ID: ${message.messageId}");
      log("🔔 [ON MESSAGE] Data: ${message.data}");
      log("🔔 [ON MESSAGE] Notification Title: ${message.notification?.title}");
      log("🔔 [ON MESSAGE] Notification Body: ${message.notification?.body}");
      log("🔔 [ON MESSAGE] From: ${message.from}");
      log("🔔 [ON MESSAGE] Sent Time: ${message.sentTime}");
      log("🔔 [ON MESSAGE] TTL: ${message.ttl}");
      log("🔔 [ON MESSAGE] Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");
      log("🔔 [ON MESSAGE] ================================================");

      // Show local notification for both platforms when app is in foreground
      log("🔔 [ON MESSAGE] Showing local notification...");
      await _showLocalNotification(message);
      log("🔔 [ON MESSAGE] Local notification shown");

      try {
        final ctx = appNavigatorKey.currentContext;
        log("🔔 [ON MESSAGE] Context available for notification count: ${ctx != null ? 'YES' : 'NO'}");
        if (ctx != null) {
          Provider.of<NotificationCountProvider>(ctx, listen: false)
              .setNotifications();
          log("🔔 [ON MESSAGE] Notification count updated");
        }
      } catch (e) {
        log('🔔 [ON MESSAGE] Failed to update notification count: $e');
      }

      try {
        log("🔔 [ON MESSAGE] Refreshing domain data...");
        _refreshDomainData(message);
        log("🔔 [ON MESSAGE] Domain data refreshed");
      } catch (e) {
        log('🔔 [ON MESSAGE] Failed to refresh domain data: $e');
      }

      // ✅ DO NOT auto-navigate when notification is received in foreground
      // Only navigate when user taps the notification (handled by onMessageOpenedApp and local notification tap)
      log("🔔 [ON MESSAGE] Foreground notification handling complete - waiting for user tap");
    });

    // replacement for onResume: When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log("🔔 [ON MESSAGE OPENED APP] ================================================");
      log("🔔 [ON MESSAGE OPENED APP] App opened from BACKGROUND notification");
      log("🔔 [ON MESSAGE OPENED APP] Message ID: ${message.messageId}");
      log("🔔 [ON MESSAGE OPENED APP] Data: ${message.data}");
      log("🔔 [ON MESSAGE OPENED APP] Notification Title: ${message.notification?.title}");
      log("🔔 [ON MESSAGE OPENED APP] Notification Body: ${message.notification?.body}");
      log("🔔 [ON MESSAGE OPENED APP] From: ${message.from}");
      log("🔔 [ON MESSAGE OPENED APP] Sent Time: ${message.sentTime}");
      log("🔔 [ON MESSAGE OPENED APP] TTL: ${message.ttl}");
      log("🔔 [ON MESSAGE OPENED APP] Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");
      log("🔔 [ON MESSAGE OPENED APP] ================================================");

      try {
        final ctx = appNavigatorKey.currentContext;
        log("🔔 [ON MESSAGE OPENED APP] Context available for notification count: ${ctx != null ? 'YES' : 'NO'}");
        if (ctx != null) {
          Provider.of<NotificationCountProvider>(ctx, listen: false)
              .setNotifications();
          log("🔔 [ON MESSAGE OPENED APP] Notification count updated");
        }
      } catch (e) {
        log('🔔 [ON MESSAGE OPENED APP] Failed to update notification count: $e');
      }

      try {
        log("🔔 [ON MESSAGE OPENED APP] Refreshing domain data...");
        _refreshDomainData(message);
        log("🔔 [ON MESSAGE OPENED APP] Domain data refreshed");
      } catch (e) {
        log('🔔 [ON MESSAGE OPENED APP] Failed to refresh domain data: $e');
      }

      try {
        log("🔔 [ON MESSAGE OPENED APP] Extracting notification meta...");
        final meta = _extractNotificationMeta(message);
        final title = meta['title'];
        final jobNo = meta['jobNo'];
        log("🔔 [ON MESSAGE OPENED APP] Extracted Title: $title");
        log("🔔 [ON MESSAGE OPENED APP] Extracted JobNo: $jobNo");

        final navCtx = appNavigatorKey.currentContext ?? context;
        log("🔔 [ON MESSAGE OPENED APP] Navigation context available: YES");
        log("🔔 [ON MESSAGE OPENED APP] Calling Utils.handleNotificationNavigation with message...");
        Utils.handleNotificationNavigation(navCtx, message, title, jobNo);
        log("🔔 [ON MESSAGE OPENED APP] Utils.handleNotificationNavigation completed");
      } catch (e) {
        log("🔔 [ON MESSAGE OPENED APP] Error in main navigation: $e");
        final navCtx = appNavigatorKey.currentContext ?? context;
        log("🔔 [ON MESSAGE OPENED APP] Fallback: Calling Utils.handleNotificationNavigation with message...");
        Utils.handleNotificationNavigation(navCtx, message, null);
        log("🔔 [ON MESSAGE OPENED APP] Fallback navigation completed");
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("🔔 [APP LIFECYCLE] ================================================");
    log("🔔 [APP LIFECYCLE] App lifecycle state changed: $state");
    log("🔔 [APP LIFECYCLE] Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");

    if (state == AppLifecycleState.resumed) {
      log("🔔 [APP LIFECYCLE] App resumed - checking notification count");
      try {
        final ctx = appNavigatorKey.currentContext;
        log("🔔 [APP LIFECYCLE] Context available on resume: ${ctx != null ? 'YES' : 'NO'}");
        if (ctx != null) {
          Provider.of<NotificationCountProvider>(ctx, listen: false)
              .setNotifications();
          log("🔔 [APP LIFECYCLE] Notification count updated on resume");
        }
      } catch (e) {
        log('🔔 [APP LIFECYCLE] Failed to refresh notification count on resume: $e');
      }
    } else if (state == AppLifecycleState.paused) {
      log("🔔 [APP LIFECYCLE] App paused");
    } else if (state == AppLifecycleState.inactive) {
      log("🔔 [APP LIFECYCLE] App inactive");
    } else if (state == AppLifecycleState.detached) {
      log("🔔 [APP LIFECYCLE] App detached");
    }
    log("🔔 [APP LIFECYCLE] ================================================");
  }

  void _initAppTheme() async {
    appModel.darkTheme = await appModel.appPreference.getTheme();
  }

  void _refreshDomainData(RemoteMessage message) {
    try {
      if (PrefObj.preferences!.containsKey(PrefKeys.USER_ID)) {
        final userId = PrefObj.preferences!.get(PrefKeys.USER_ID);
        if (userId != null) {
          // Refresh bookings and job cards lists with current tabs
          bookingListbloc.bookinglistsink(
              userId, globals.currentBookingTab.toString());
          jobcardsListbloc.jobcardslistsink(
              userId, globals.currentJobcardTab.toString());
        }
      }
      // If payload has a job number, refresh pickup conditions for progress
      final data = message.data;
      final jobNo = data['job_number'] ?? data['jobNo'] ?? data['jobno'];
      if (jobNo != null && jobNo.toString().isNotEmpty) {
        pickupConditionsListBloc.pickupConditionsListSink(jobNo.toString());
      }
    } catch (e) {
      log('refreshDomainData error: $e');
    }
  }

  void _maybeAutoOpen(RemoteMessage message) {
    final data = message.data;
    final type =
        (data['type'] ?? data['action'] ?? '').toString().toLowerCase();
    const autoTypes = {
      'pickup_request',
      'job_card',
      'jobcard',
      'delivery_request',
      'progress_update'
    };
    if (autoTypes.contains(type) ||
        data.containsKey('job_number') ||
        data.containsKey('booking_id')) {
      Utils.handleNotificationNavigation(context, message, null);
      return;
    }

    // Fallback: heuristics on title/body for pickup confirmation requests
    final title = (message.notification?.title ?? data['title'] ?? '')
        .toString()
        .toLowerCase();
    final body = (message.notification?.body ?? data['body'] ?? '')
        .toString()
        .toLowerCase();
    final text = '$title $body';
    if (text.contains('pickup') &&
        (text.contains('confirm') || text.contains('request'))) {
      try {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => BottomBarPage(1)),
            (Route<dynamic> route) => false);
      } catch (e) {
        log('Heuristic auto-open to My Bookings failed: $e');
      }
    }
  }

  // Build a readable title/body string and extract job number from incoming message
  Map<String, String> _extractNotificationMeta(RemoteMessage message) {
    final data = message.data;
    final title =
        (message.notification?.title ?? data['title'] ?? '').toString();
    final body = (message.notification?.body ?? data['body'] ?? '').toString();
    final jobNo =
        (data['job_number'] ?? data['jobNo'] ?? data['jobno'] ?? '').toString();
    final readable = (title.isNotEmpty || body.isNotEmpty)
        ? [title, body].where((e) => e.isNotEmpty).join(' - ')
        : data.toString();
    return {
      'title': readable,
      'jobNo': jobNo,
    };
  }

  // Create a stable key per message to prevent duplicate handling across streams
  String _computeMessageKey(RemoteMessage message) {
    final id = message.messageId ?? '';
    final dataStr = message.data.toString();
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    return '${id}::${title}::${body}::${dataStr}'.hashCode.toString();
  }

  // Removed dedupe/throttle helpers

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: true);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          appModel.fetchLocale();

          return ScreenUtilInit(
            designSize: Size(360, 690),
            builder: (context, child) =>
                Consumer<AppModel>(builder: (context, appLang, child) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                      create: (_) => NotificationCountProvider()),
                  ChangeNotifierProvider(
                      create: (_) => InvoiceBalanceProvider())
                ],
                child: Builder(
                  builder: (context) {
                    // Initialize global notification service
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      NotificationService.startGlobalTimer(context);
                    });

                    return GetMaterialApp(
                      title: 'iMechano',
                      navigatorKey: appNavigatorKey,
                      locale: appModel.appLocal,
                      localizationsDelegates: [
                        AppLocalization.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: [
                        const Locale('ar'), // Arabic
                        const Locale('en'), // English
                      ],
                      debugShowCheckedModeBanner: false,
                      home: _dicedeScreen(prefs),
                      theme: appModel.darkTheme
                          ? buildDarkTheme()
                          : buildLightTheme(),
                      // theme: ThemeData(
                      //   //fontFamily: 'Poppins',
                      //   primarySwatch: customBlueSwatch,
                      //   // visualDensity: VisualDensity.adaptivePlatformDensity,
                      // ),
                      getPages: [
                        GetPage(name: '/', page: () => SplashScreen()),
                        GetPage(name: '/sign-in', page: () => SignInScreen()),
                        GetPage(name: '/sign-up', page: () => SignUpScreen()),
                        GetPage(
                            name: '/on-boarding',
                            page: () => OnBoardingScreen()),
                        GetPage(
                            name: '/choose-language',
                            page: () => LanguageChooseScreen()),
                        GetPage(
                            name: '/PrivacyPolicyScreene',
                            // page: () => PrivacyPolicyScreen()),
                            page: () =>
                                PolicyScreen(mdFileName: 'term_privacy.md')),
                        GetPage(
                            name: '/EditDetailsScreene',
                            page: () => EditDetailsScreen(id: '')),
                        GetPage(
                          name: '/sign-in-sign-up-landing',
                          page: () => SignInSignUpLandingScreen(),
                        ),
                        GetPage(
                            name: '/select-your-car',
                            page: () =>
                                SelectYourCarScreen(type: AddCarType.add)),
                      ],
                      routes: {
                        'home': (context) => SignInSignUpLandingScreen(),
                        'onboard': (context) => SplashScreen(),
                      },
                    );
                  },
                ),
              );
            }),
          );
        },
      ),
    );
  }

  ThemeData buildLightTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      cardColor: Colors.white,
      primaryColor: Colors.red,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.red,
        secondary: Colors.redAccent,
      ),
    );
  }

  ThemeData buildDarkTheme() {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      cardColor: Colors.grey[800],
      primaryColor: Colors.blue[900],
      scaffoldBackgroundColor: Colors.grey[900],
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.blue[900]!,
        secondary: Colors.blueAccent,
      ),
    );
  }

  // ThemeData buildLightTheme() {
  //   final ThemeData base = ThemeData.light();
  //   return base.copyWith(
  //     buttonColor: Colors.redAccent,
  //     cardColor: Colors.white,
  //     backgroundColor: Colors.white,
  //     primaryColor: Colors.red,
  //     accentColor: Colors.redAccent,
  //     scaffoldBackgroundColor: Colors.white,
  //   );
  // }

  // ThemeData buildDarkTheme() {
  //   final ThemeData base = ThemeData.dark();
  //   return base.copyWith(
  //     buttonColor: Colors.blueAccent,
  //     cardColor: Colors.grey[800],
  //     backgroundColor: Colors.grey[800],
  //     primaryColor: Colors.blue[900],
  //     accentColor: Colors.blueAccent,
  //     scaffoldBackgroundColor: Colors.grey[900],
  //   );
  // }

  Widget _dicedeScreen(Box prefs) {
    PrefObj.preferences = prefs;
    // ignore: unused_local_variable
    final userStr = prefs.containsKey(PrefKeys.USER_DATA) ? true : false;
    final appStart =
        PrefObj.preferences!.containsKey(PrefKeys.APPSTARTED) ? true : false;
    log("appStart Lgoin");
    log(appStart.toString());
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SplashScreen(),
    );
  }
}
