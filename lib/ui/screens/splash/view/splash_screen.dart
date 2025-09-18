import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imechano/localization/language_constrants.dart';
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:imechano/ui/screens/auth/landing/view/sign_in_sign_up_landing_screen.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/share_preferences/pref_key.dart';
import 'package:imechano/ui/share_preferences/preference.dart';
import 'package:provider/provider.dart';

import '../../../common/globals.dart';
import '../../language/view/language_choose_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    final userStr =
        PrefObj.preferences!.containsKey(PrefKeys.USER_DATA) ? true : false;

    //======SET NOTIFICATIONS OF THE USER ON SPLASH SCREEN
    if (userStr) {
      Provider.of<NotificationCountProvider>(context, listen: false)
          .setNotifications();
    }
    // Auto-navigate after 6 seconds based on app state
    _timer = Timer(const Duration(seconds: 6), () async {
      log('Splash timeout, deciding next route');
      final appStart =
          PrefObj.preferences!.containsKey(PrefKeys.APPSTARTED) ? true : false;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => !appStart && !userStr
              ? LanguageChooseScreen()
              : !userStr
                  ? SignInSignUpLandingScreen()
                  : BottomBarPage(2),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('Inside buiild of splash screen');
    var size = MediaQuery.of(context).size;
    setScreenSize(size);
    return ScreenUtilInit(
      builder: (context, child) => Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.10),
                Theme.of(context).colorScheme.secondary.withOpacity(0.10),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 720),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo with subtle elevation effect
                      Container(
                        width: 110.w,
                        height: 110.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 22,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 92.w,
                            height: 92.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(16.w),
                            child: Image.asset(
                              'assets/icons/splash/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      // Welcome text, themed and centered
                      Text(
                        getTranslated('welcometoiFixcarservice', context),
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 0.2,
                                ),
                      ),
                      SizedBox(height: 26.h),
                      // Illustration scaled by screen width
                      SizedBox(
                        width: 0.70.sw,
                        child: Image.asset(
                          'assets/icons/splash/splash.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 36.h),
                      // Loading indicator (animated gif)
                      SizedBox(
                        width: 60.w,
                        height: 60.w,
                        child: Image.asset(
                          'assets/meter.gif',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Image loadGIF() {
    return Image.asset(
      'assets/meter.gif',
      height: 120,
      width: 120,
    );
  }
}
