import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imechano/localization/language_constrants.dart';
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:imechano/ui/share_preferences/pref_key.dart';
import 'package:imechano/ui/share_preferences/preference.dart';
import 'package:imechano/ui/shared/widgets/text_widgets.dart';
import 'package:provider/provider.dart';

import '../../../common/globals.dart';
import 'package:imechano/ui/screens/auth/landing/view/sign_in_sign_up_landing_screen.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import '../../language/view/language_choose_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    Timer(const Duration(seconds: 6), () async {
      log('Inside timer');

      final appStart =
          PrefObj.preferences!.containsKey(PrefKeys.APPSTARTED) ? true : false;
      log("appStart");
      log(appStart.toString());
      log('user str: $userStr');
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
  Widget build(BuildContext context) {
    log('Inside buiild of splash screen');
    var size = MediaQuery.of(context).size;
    setScreenSize(size);
    return ScreenUtilInit(
      designSize: Size(414, 896),
      builder: (context, child) => Scaffold(
        body: Padding(
          padding: EdgeInsets.all(8.w),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 20.h),
                Image(
                    image: AssetImage('assets/icons/splash/logo.png'),
                    width: 120.w,
                    height: 120.h,
                    fit: BoxFit.contain),
                Regular20Black(
                    getTranslated('welcometoiFixcarservice', context)),
                Image(
                  image: AssetImage('assets/icons/splash/splash.png'),
                  width: 0.9.sw,
                  height: 200.h,
                  fit: BoxFit.contain,
                ),
                Image.asset(
                  'assets/meter.gif',
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Image loadGIF() {
    return Image.asset(
      'assets/meter.gif',
      height: 120.h,
      width: 120.w,
    );
  }
}
