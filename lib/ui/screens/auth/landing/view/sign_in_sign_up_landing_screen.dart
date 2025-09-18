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
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LanguageChooseScreen()),
          );
          return false; // Prevents default back button behavior
        },
        child: Scaffold(
          backgroundColor: appModelTheme.darkTheme ? Color(0xff252525) : white,
          body: ScreenUtilInit(
            designSize: Size(414, 896),
            builder: (context, child) => SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Smaller logo
                                    Center(
                                      child: Image(
                                          height: 80.h, // Much smaller logo
                                          image: AssetImage(
                                              'assets/icons/splash/logo.png'),
                                          color: appModelTheme.darkTheme
                                              ? white
                                              : null),
                                    ),
                                    SizedBox(height: 20.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Center(
                                        child: Text(
                                            getTranslated(
                                                "welcomemsg", context),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14.sp)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                child: Center(
                                  child: Image(
                                      height: 250.h, // Responsive image height
                                      image: AssetImage(
                                          'assets/icons/auth/landing.png')),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    buttonsSection(),
                                    SizedBox(height: 12),
                                    CustomButton(
                                      title: Text(
                                        getTranslated("guest", context),
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: 'Poppins1',
                                            color: Colors.white),
                                      ),
                                      width: 0.85,
                                      height: 44,
                                      callBackFunction: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return BottomBarPage(2);
                                          },
                                        ));
                                      },
                                      bgColor: logoBlue,
                                      borderColor: logoBlue,
                                    ),
                                    SizedBox(height: 8),
                                    FittedBox(child: TermsOfUse()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ));
  }

  Row buttonsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: CustomButton(
              title: Text(
                getTranslated('signin', context),
                style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins1',
                    color: Colors.white),
              ),
              width: 1.0, // Use full width of expanded
              callBackFunction: () {
                setState(() {
                  appModelTheme.checkCon = false;
                });
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return SignInScreen();
                  },
                ));
              },
              bgColor: buttonNaviBlue162e3f,
              borderColor: buttonNaviBlue162e3f,
            ),
          ),
        ),
        orDividerSection(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: CustomButton(
              title: Text(
                getTranslated('Signup', context),
                style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins1',
                    color: Colors.white),
              ),
              width: 1.0, // Use full width of expanded
              callBackFunction: () {
                setState(() {
                  appModelTheme.checkCon = false;
                });
                Get.toNamed('/sign-up');
              },
              bgColor: buttonBlue3b5999,
              borderColor: buttonBlue3b5999,
            ),
          ),
        ),
      ],
    );
  }

  Widget orDividerSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 12.h,
            child: VerticalDivider(
              width: 10,
              color: appModelTheme.darkTheme ? white : Color(0xff374049),
              thickness: 1.5,
            ),
          ),
          Text(
            getTranslated("OR", context),
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Poppins1',
              color: appModelTheme.darkTheme ? white : Color(0xff374049),
            ),
          ),
          Container(
            height: 12.h,
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
