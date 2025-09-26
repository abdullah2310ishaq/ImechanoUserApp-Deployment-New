// ignore_for_file: camel_case_types, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:imechano/localization/language_constrants.dart';
import 'package:imechano/ui/common/globals.dart';
import 'package:imechano/ui/privacy_disp.dart';
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:imechano/ui/provider/theme_provider.dart';
import 'package:imechano/ui/screens/auth/sign_in/view/sign_in_screen.dart';
import 'package:imechano/ui/screens/bottombar/My_Bookings_Page.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/screens/bottombar/my%20invoice.dart';
import 'package:imechano/ui/screens/bottombar/my_job_card.dart';
import 'package:imechano/ui/screens/bottombar/profile.dart';
import 'package:imechano/ui/screens/choose_language.dart';
import 'package:imechano/ui/screens/location/location_map.dart';
import 'package:imechano/ui/screens/my_account/Notification.dart';
import 'package:imechano/ui/screens/my_account/faq.dart';
import 'package:imechano/ui/screens/my_account/home.dart';

import 'package:imechano/ui/screens/select_car/view/my_vehical_screen.dart';
import 'package:imechano/ui/share_preferences/pref_key.dart';
import 'package:imechano/ui/share_preferences/preference.dart';
import 'package:imechano/ui/styling/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../styling/config.dart';

class drawerpage extends StatefulWidget {
  @override
  State<drawerpage> createState() => _drawerpageState();
}

class _drawerpageState extends State<drawerpage> {
  List drawerGuestIcon = [];
  List drawerTitle = [];
  var userStr;

  var profileData;
  var profilename = "James";
  var userphoneno = "0000";
  var profileurl = "";
  bool isSwitch = false;
  var address;
  var dataLoad;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  void getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      address = prefs.getString('address') ?? 'Select your address';

      dataLoad = true;

      print(address);
    });
  }

  List pageDrawer = [
    HomeScreen(),
    Myvehicalscreen(),
    MyBookingsPage(),
    MapLocation(
      callBackFunction: (mainAddress) {},
    ),
    MyInvoice(),
    MyJobCard(),
    NotificationScreen(),
    // PrivacyPolicyScreen(),
    PolicyScreen(
      mdFileName: 'term_privacy.md',
    )

    // AccordionPage(),
  ];

  List pageMyAccount = [
    BottomBarPage(2),
    ProfilePage(),
    BottomBarPage(0), //Myvehicalscreen(),
    // ProgressreportInactive(),
    BottomBarPage(1), //MyBookingsPage(),
    MapLocation(),
    MyInvoice(),
    BottomBarPage(3),
    NotificationScreen(),
    FAQsPage(),
    // AccordionPage(),
    PolicyScreen(mdFileName: 'term_privacy.md'),
    ChooseLanguage()
  ];

  Locale selectedLocale = Locale('en');

  @override
  void initState() {
    super.initState();
    userStr =
        PrefObj.preferences!.containsKey(PrefKeys.USER_DATA) ? true : false;
    if (userStr) {
      profileData =
          json.decode(PrefObj.preferences!.get(PrefKeys.PROFILE_DATA));
      profilename = profileData['name'].toString();
      userphoneno = profileData['mobile_number'].toString();
      // Build profile image URL from stored profile path and cache it for global use
      final String profilePath = profileData['profile']?.toString() ?? '';
      if (profilePath.isNotEmpty && !profilePath.contains('null')) {
        profileurl = profilePath.startsWith('http')
            ? profilePath
            : (Config.profileurl + profilePath);
        // Ensure drawer can show image without needing to open profile screen first
        PrefObj.preferences!.put(PrefKeys.PROFILE_IMG, profileurl);
      } else {
        profileurl = '';
      }

      drawerTitle = [
        "Home",
        "My Profile",
        "My Vehicle",
        "My Bookings",
        "My Location",
        "My Invoices",
        "job card",
        "Notification",
        "FAQs",
        "Privacy Policy",
        "Change Language",
        "Dark Theme",
        "Logout",
      ];
      drawerGuestIcon = [
        "assets/icons/My Account/noun_Home_4334361.png",
        "assets/icons/My Account/person_black_24dp.png",
        "assets/icons/My Account/Path 8567.png",
        "assets/icons/My Account/noun_calender_2189968.png",
        "assets/icons/My Account/location.png",
        "assets/icons/My Account/file-text.png",
        "assets/icons/My Account/Desk_alt_fill.png",
        "assets/icons/My Account/notifications_black_24dp.png",
        "assets/icons/My Account/Desk_alt_fill.png",
        "assets/icons/My Account/Chield_check_fill.png",
        "assets/icons/My Account/language.png",
        "assets/icons/My Account/Path 131.png",
        "assets/icons/My Account/Sign_in.png",
      ];
    } else {
      // Guest mode: Only show Home, FAQs, Privacy Policy, Change Language, Dark Theme
      drawerTitle = [
        "Home",
        "FAQs",
        "Privacy Policy",
        "Dark Theme",
      ];

      drawerGuestIcon = [
        "assets/icons/My Account/noun_Home_4334361.png",
        "assets/icons/My Account/Desk_alt_fill.png",
        "assets/icons/My Account/Chield_check_fill.png",
        "assets/icons/My Account/Path 131.png",
      ];

      // Align navigation targets with the guest list (last two are switches, no navigation)
      pageDrawer = [
        HomeScreen(),
        FAQsPage(),
        PolicyScreen(mdFileName: 'term_privacy.md'),
        null,
        null,
      ];
    }
  }

  dynamic appModelTheme;
  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    appModelTheme = appModel;

    return ScreenUtilInit(
      designSize: Size(414, 896),
      builder: (context, child) => Drawer(
        key: _key,
        child: Column(
          children: [
            userStr
                ? Container(
                    height: 186.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: logoBlue,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Builder(builder: (context) {
                            final bool hasPrefImg = PrefObj.preferences!
                                .containsKey(PrefKeys.PROFILE_IMG);
                            final String? cachedUrl = hasPrefImg
                                ? PrefObj.preferences!.get(PrefKeys.PROFILE_IMG)
                                : null;
                            final String? derivedUrl =
                                (profileurl.isNotEmpty) ? profileurl : null;
                            final String? url = cachedUrl ?? derivedUrl;
                            return Center(
                              child: CircleAvatar(
                                radius: 55.h,
                                backgroundImage:
                                    url != null ? NetworkImage(url) : null,
                                child: url == null
                                    ? Icon(Icons.person, size: 50.sp)
                                    : null,
                              ),
                            );
                          }),
                          SizedBox(
                            width: 20.w,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profilename.toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Montserrat3  ",
                                    color: Colors.white,
                                    fontSize: 18.sp),
                              ),
                              Text(
                                userphoneno,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13.sp),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: 186.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: logoBlue,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage("assets/icons/splash/logo.png"),
                          height: 50.h,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.04,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: MaterialButton(
                            child: Text("Login"),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return SignInScreen();
                                },
                              ));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
            Expanded(
              child: Container(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // //todo drawer if login

                      ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            // Compute actual indices for special rows
                            final int changeLangIndex =
                                drawerTitle.indexOf("Change Language");
                            final int darkThemeIndex =
                                drawerTitle.indexOf("Dark Theme");
                            return GestureDetector(
                              onTap: () {
                                // Logged-in: handle logout item safely
                                if (userStr &&
                                    index == drawerGuestIcon.length - 1) {
                                  logOutDialog();
                                  return;
                                }

                                // Language or Dark Theme rows: no navigation
                                if (index == changeLangIndex ||
                                    index == darkThemeIndex) {
                                  return;
                                }

                                // Navigate if target exists
                                final list =
                                    userStr ? pageMyAccount : pageDrawer;
                                final target =
                                    (index >= 0 && index < list.length)
                                        ? list[index]
                                        : null;
                                if (target != null) {
                                  // Always replace stack with the selected target
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => target),
                                      (Route<dynamic> route) => false);
                                }
                              },
                              child: index == changeLangIndex
                                  ? ListTile(
                                      trailing: Switch(
                                        value: langSwitch,
                                        activeColor: Colors.black,
                                        activeTrackColor: Color(0xFF9AF3EE),
                                        onChanged: (value) {
                                          setState(() {
                                            if (langSwitch) {
                                              changeLocale(
                                                  profileData['id'], 'en');
                                              selectedLocale = Locale('en');
                                              appModel.changeLanguage(
                                                  selectedLocale);

                                              langSwitch = false;
                                            } else {
                                              changeLocale(
                                                  profileData['id'], 'ar');
                                              selectedLocale = Locale('ar');
                                              appModel.changeLanguage(
                                                  selectedLocale);
                                              langSwitch = true;
                                            }
                                          });
                                        },
                                      ),
                                      contentPadding:
                                          EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                                      leading: SizedBox(
                                        height: 25.h,
                                        child: Image(
                                            image: AssetImage(
                                                drawerGuestIcon[index])),
                                      ),
                                      title: Text(
                                        getTranslated(
                                            drawerTitle[index]
                                                .toString()
                                                .removeAllWhitespace
                                                .toLowerCase(),
                                            context),
                                        style: TextStyle(
                                            fontFamily: "Poppins1",
                                            fontSize: 15),
                                      ),
                                    )
                                  : ListTile(
                                      trailing: (index == darkThemeIndex)
                                          ? switchButton()
                                          : Text(""),
                                      contentPadding:
                                          EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                                      leading: SizedBox(
                                        height: 25.h,
                                        child: Image(
                                            image: AssetImage(
                                                drawerGuestIcon[index])),
                                      ),
                                      title: Text(
                                        getTranslated(
                                            drawerTitle[index]
                                                .toString()
                                                .removeAllWhitespace
                                                .toLowerCase(),
                                            context),
                                        style: TextStyle(
                                            fontFamily: "Poppins1",
                                            fontSize: 15),
                                      ),
                                    ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Container(height: 0, child: Divider());
                          },
                          itemCount: drawerGuestIcon.length),
                    ],
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget languageSwitch() {
    return Switch(
      value: appModelTheme.darkTheme,
      activeColor: Color(0xFF40E0D0),
      activeTrackColor: Color(0xFF9AF3EE),
      onChanged: (value) {
        setState(() {
          appModelTheme.darkTheme = !appModelTheme.darkTheme;

          //isSwitch = value;
          isSwitch
              ? ThemeData(
                  brightness: Brightness.dark,
                  /* light theme settings */
                )
              : ThemeData(
                  brightness: Brightness.light,
                  /* dark theme settings */
                );
          isSwitch = value;
        });
      },
    );
  }

  Widget switchButton() {
    return Switch(
      value: appModelTheme.darkTheme,
      activeColor: Colors.black,
      activeTrackColor: Color(0xFF9AF3EE),
      onChanged: (value) {
        setState(() {
          appModelTheme.darkTheme = !appModelTheme.darkTheme;

          //isSwitch = value;
          isSwitch
              ? ThemeData(
                  brightness: Brightness.dark,
                  /* light theme settings */
                )
              : ThemeData(
                  brightness: Brightness.light,
                  /* dark theme settings */
                );
          isSwitch = value;
        });
      },
    );
  }

  // Widget switchLangButton() {
  //   return Switch(
  //     value: appModelTheme.darkTheme,
  //     onChanged: (value) {
  //       setState(() {
  //         if (isSwitch) {
  //           selectedLocale = Locale('en');
  //           appModel.changeLanguage(selectedLocale);
  //         }
  //         isSwitch = value;
  //         print(isSwitch);
  //       });
  //     },
  //   );
  // }

  void logOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Column(
            children: [
              Text(
                getTranslated("logout", context) + " ?",
                style: TextStyle(fontFamily: "Poppins2"),
              ),
              SizedBox(height: 15.h),
              Text(
                getTranslated("Areyousureyouwanttologout?", context),
                style: TextStyle(fontSize: 15.sp, fontFamily: "Poppins1"),
              )
            ],
          )),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    // textColor: Colors.black,
                    child: Text(
                      getTranslated("cancel", context),
                      style: TextStyle(color: logoBlue, fontFamily: "Poppins1"),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                TextButton(
                    child: Text(getTranslated('logout', context),
                        style: TextStyle(
                            color: Colors.redAccent, fontFamily: "Poppins1")),
                    onPressed: () {
                      Provider.of<NotificationCountProvider>(context,
                              listen: false)
                          .clearNotifications();
                      changeLocale(PrefKeys.USER_ID, "en");
                      PrefObj.preferences?.clear();
                      PrefObj.preferences?.put(PrefKeys.APPSTARTED, true);

                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/sign-in-sign-up-landing', (Route route) => false);
                    })
              ],
            ),
          ],
        );
      },
    );
  }
}
