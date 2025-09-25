import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:imechano/localization/language_constrants.dart';
import 'package:imechano/ui/provider/theme_provider.dart';
import 'package:imechano/ui/screens/auth/sign_in/view/sign_in_screen.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/screens/privacy_policy/terms_of_use.dart';
import 'package:imechano/ui/shared/widgets/buttons/custom_button.dart';
import 'package:imechano/ui/styling/colors.dart';
import 'package:provider/provider.dart';

import '../../../language/view/language_choose_screen.dart';

class SignInSignUpLandingScreen extends StatefulWidget {
  const SignInSignUpLandingScreen({Key? key}) : super(key: key);

  @override
  State<SignInSignUpLandingScreen> createState() =>
      _SignInSignUpLandingScreenState();
}

class _SignInSignUpLandingScreenState extends State<SignInSignUpLandingScreen> {
  dynamic appModelTheme;

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    appModelTheme = appModel;
    // Clamp text scaling so small iPhones don't blow up fonts
    final mq = MediaQuery.of(context);
    return MediaQuery(
        data: mq.copyWith(textScaleFactor: mq.textScaleFactor.clamp(0.9, 1.0)),
        child: PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageChooseScreen()),
              );
            },
            child: Scaffold(
              backgroundColor:
                  appModelTheme.darkTheme ? Color(0xff252525) : white,
              body: ScreenUtilInit(
                designSize: Size(414, 896),
                builder: (context, child) => SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Center(
                                      child: Image(
                                          image: AssetImage(
                                              'assets/icons/splash/logo.png'),
                                          width: 180.w,
                                          height: 60.h,
                                          fit: BoxFit.contain,
                                          color: appModelTheme.darkTheme
                                              ? white
                                              : null),
                                    ),
                                    SizedBox(height: 24.h),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, right: 30),
                                      child: Center(
                                        child: Text(
                                          getTranslated("welcomemsg", context),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            height: 1.35,
                                            fontFamily: 'Poppins3',
                                            color: appModelTheme.darkTheme
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Image(
                                        height: 350.h,
                                        width: 0.99.sw,
                                        fit: BoxFit.contain,
                                        image: AssetImage(
                                            'assets/icons/auth/landing.png'),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                buttonsSection(),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                CustomButton(
                                  title: Text(
                                    getTranslated("guest", context),
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontFamily: 'Poppins1',
                                        color: Colors.white),
                                  ),
                                  width: 0.8,
                                  callBackFunction: () {
                                    // setState(() {
                                    //   appModelTheme.checkCon = true;
                                    // });
                                    //bool checkConditionDrawer = true;
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return BottomBarPage(2);
                                      },
                                    ));
                                  },
                                  bgColor: logoBlue,
                                  borderColor: logoBlue,
                                ),
                                SizedBox(height: 40.h),
                                TermsOfUse(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )));
  }

  Row buttonsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          title: Text(
            getTranslated('signin', context),
            style: TextStyle(
                fontSize: 16.sp, fontFamily: 'Poppins1', color: Colors.white),
          ),
          width: 0.35,
          callBackFunction: () {
            setState(() {
              appModelTheme.checkCon = false;
            });
            // bool checkCondition = false;
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return SignInScreen();
              },
            ));
          },
          bgColor: buttonNaviBlue162e3f,
          borderColor: buttonNaviBlue162e3f,
        ),
        orDividerSection(),
        CustomButton(
          title: Text(
            getTranslated('Signup', context),
            style: TextStyle(
                fontSize: 16.sp, fontFamily: 'Poppins1', color: Colors.white),
          ),
          width: 0.35,
          callBackFunction: () {
            setState(() {
              appModelTheme.checkCon = false;
            });
            Get.toNamed('/sign-up');
          },
          bgColor: buttonBlue3b5999,
          borderColor: buttonBlue3b5999,
        ),
      ],
    );
  }

  Padding orDividerSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 9, right: 9),
      child: Column(
        children: [
          Container(
            height: 15.h,
            child: VerticalDivider(
              width: 10,
              color: appModelTheme.darkTheme ? white : Color(0xff374049),
              thickness: 1.5,
            ),
          ),
          Text(
            getTranslated("OR", context),
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Poppins1',
              color: appModelTheme.darkTheme ? white : Color(0xff374049),
            ),
          ),
          Container(
            height: 15.h,
            child: VerticalDivider(
              width: 10,
              color: appModelTheme.darkTheme ? white : Color(0xff374049),
              thickness: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
