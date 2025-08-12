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
  bool isEnglish =
      true; // Track current language (true = English, false = Arabic)
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
    ChooseLanguage(),
    null, // Dark Theme - handled with switch
    null, // Delete Account - handled with dialog
    null // Logout - handled with dialog
  ];

  Locale selectedLocale = Locale('en');

  @override
  void initState() {
    super.initState();
    // Initialize language state from provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appModel = Provider.of<AppModel>(context, listen: false);
      await appModel.fetchLocale();
      await appModel.fetchTheme();
      if (mounted) {
        setState(() {
          isEnglish = appModel.appLocal.languageCode == 'en';
        });
      }
    });

    userStr =
        PrefObj.preferences!.containsKey(PrefKeys.USER_DATA) ? true : false;
    if (userStr) {
      profileData =
          json.decode(PrefObj.preferences!.get(PrefKeys.PROFILE_DATA));
      profilename = profileData['name'].toString();
      userphoneno = profileData['mobile_number'].toString();
      profileurl = Config.profileurl + profileData['profile'].toString();

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
        "Delete Account",
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
        "assets/icons/My Account/person_black_24dp.png",
        "assets/icons/My Account/Sign_in.png",
      ];
    } else {
      drawerTitle = [
        "Home",
        "My Vehicle",
        "My Bookings",
        "My Location",
        "My Invoices",
        "Notification",
        "FAQs",
        "Privacy Policy",
        "Change Language",
        "Dark Theme"
      ];

      drawerGuestIcon = [
        "assets/icons/My Account/noun_Home_4334361.png",
        "assets/icons/My Account/Path 8567.png",
        "assets/icons/My Account/noun_calender_2189968.png",
        "assets/icons/My Account/location.png",
        "assets/icons/My Account/file-text.png",
        "assets/icons/My Account/notifications_black_24dp.png",
        "assets/icons/My Account/Desk_alt_fill.png",
        "assets/icons/My Account/Chield_check_fill.png",
        "assets/icons/My Account/language.png",
        "assets/icons/My Account/Path 131.png"
      ];
    }
  }

  dynamic appModelTheme;
  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, appModel, child) {
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
                              PrefObj.preferences!
                                      .containsKey(PrefKeys.PROFILE_IMG)
                                  ? Center(
                                      child: CircleAvatar(
                                        radius: 55.h,
                                        backgroundImage: NetworkImage(PrefObj
                                            .preferences!
                                            .get(PrefKeys.PROFILE_IMG)),
                                      ),
                                    )
                                  : Center(
                                      child: CircleAvatar(
                                        radius: 55.h,
                                        child: Icon(Icons.person, size: 50.sp),
                                      ),
                                    ),
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
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
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
                                return GestureDetector(
                                  onTap: () {
                                    if (userStr) {
                                      // For authenticated users
                                      if (index == 10) {
                                        // Change Language - navigate to language screen
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChooseLanguage()));
                                      } else if (index == 11) {
                                        // Dark Theme toggle - handled by switch
                                        print("Dark Theme toggle tapped");
                                      } else if (index == 12) {
                                        // Delete Account
                                        _showDeleteAccountDialog();
                                      } else if (index == 13) {
                                        // Logout
                                        logOutDialog();
                                      } else if (index < pageMyAccount.length) {
                                        // Navigate to other pages
                                        if (pageMyAccount[index] != null) {
                                          if (index == 0) {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            pageMyAccount[
                                                                index]),
                                                    (Route<dynamic> route) =>
                                                        false);
                                          } else {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        pageMyAccount[index]));
                                          }
                                        }
                                      }
                                    } else {
                                      // For guest users
                                      if (index == 8) {
                                        // Change Language - navigate to language screen
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChooseLanguage()));
                                      } else if (index == 9) {
                                        // Dark Theme toggle for guest
                                        print("Dark Theme toggle tapped");
                                      } else if (index < pageDrawer.length) {
                                        // Navigate to other pages for guest
                                        if (index == 0) {
                                          Navigator.of(
                                                  context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          pageDrawer[index]),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        } else {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      pageDrawer[index]));
                                        }
                                      }
                                    }
                                  },
                                  child: userStr
                                      ? (index == 10
                                          ? ListTile(
                                              trailing: languageSwitch(),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30.w, 0, 30.w, 0),
                                              leading: SizedBox(
                                                height: 25.h,
                                                child: Image(
                                                    image: AssetImage(
                                                        drawerGuestIcon[
                                                            index])),
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
                                          : index == 11
                                              ? ListTile(
                                                  trailing: switchButton(),
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          30.w, 0, 30.w, 0),
                                                  leading: SizedBox(
                                                    height: 25.h,
                                                    child: Image(
                                                        image: AssetImage(
                                                            drawerGuestIcon[
                                                                index])),
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
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          30.w, 0, 30.w, 0),
                                                  leading: SizedBox(
                                                    height: 25.h,
                                                    child: Image(
                                                        image: AssetImage(
                                                            drawerGuestIcon[
                                                                index])),
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
                                                        fontSize: 15,
                                                        color: index == 12
                                                            ? Colors.redAccent
                                                            : null),
                                                  ),
                                                ))
                                      : (index == 8
                                          ? ListTile(
                                              trailing: languageSwitch(),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30.w, 0, 30.w, 0),
                                              leading: SizedBox(
                                                height: 25.h,
                                                child: Image(
                                                    image: AssetImage(
                                                        drawerGuestIcon[
                                                            index])),
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
                                          : index == 9
                                              ? ListTile(
                                                  trailing: switchButton(),
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          30.w, 0, 30.w, 0),
                                                  leading: SizedBox(
                                                    height: 25.h,
                                                    child: Image(
                                                        image: AssetImage(
                                                            drawerGuestIcon[
                                                                index])),
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
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          30.w, 0, 30.w, 0),
                                                  leading: SizedBox(
                                                    height: 25.h,
                                                    child: Image(
                                                        image: AssetImage(
                                                            drawerGuestIcon[
                                                                index])),
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
                                                )),
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
      },
    );
  }

  Widget languageSwitch() {
    return Switch(
      value: isEnglish,
      onChanged: (value) {
        setState(() {
          isEnglish = value;
        });

        String newLang = isEnglish ? 'en' : 'ar';

        // Save language preference using both methods for consistency
        PrefObj.preferences!.put(PrefKeys.LANGUAGE_CODE, newLang);

        // Update locale through provider
        Locale newLocale = Locale(newLang);
        Provider.of<AppModel>(context, listen: false).changeLanguage(newLocale);

        // Update selected locale
        selectedLocale = newLocale;

        // Force rebuild to apply language changes
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget switchButton() {
    return Switch(
      value: appModelTheme.darkTheme,
      onChanged: (value) {
        setState(() {
          // Use the provider to change theme
          Provider.of<AppModel>(context, listen: false).darkTheme = value;
        });

        // Force rebuild to apply theme changes
        if (mounted) {
          setState(() {});
        }
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

  void _showDeleteAccountDialog() {
    // Check if account deletion is already requested
    bool isDeletionRequested =
        PrefObj.preferences!.containsKey(PrefKeys.ACCOUNT_DELETION_REQUESTED);

    if (isDeletionRequested) {
      _showDeletionStatusDialog();
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 50),
                SizedBox(height: 10.h),
                Text(
                  "Delete Account",
                  style: TextStyle(fontFamily: "Poppins2", color: Colors.red),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure you want to delete your account?",
                style: TextStyle(fontSize: 16.sp, fontFamily: "Poppins1"),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                "This action will schedule your account for permanent deletion in 7 days.",
                style: TextStyle(
                    fontSize: 14.sp, fontFamily: "Poppins1", color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                "You can cancel this request anytime within 7 days by logging in again.",
                style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: "Poppins1",
                    color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: logoBlue, fontFamily: "Poppins1"),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    "Delete Account",
                    style: TextStyle(
                        color: Colors.red,
                        fontFamily: "Poppins1",
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _confirmAccountDeletion();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _confirmAccountDeletion() {
    // Close the first dialog
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Final Confirmation",
            style: TextStyle(fontFamily: "Poppins2", color: Colors.red),
          ),
          content: Text(
            "Type 'DELETE' to confirm account deletion:",
            style: TextStyle(fontSize: 14.sp, fontFamily: "Poppins1"),
          ),
          actions: <Widget>[
            TextField(
              onChanged: (value) {
                // You can add validation here
              },
              decoration: InputDecoration(
                hintText: "Type DELETE here",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: logoBlue, fontFamily: "Poppins1"),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    "Confirm Delete",
                    style: TextStyle(
                        color: Colors.red,
                        fontFamily: "Poppins1",
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _processAccountDeletion();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _processAccountDeletion() {
    // Schedule account for deletion in 7 days
    DateTime deletionDate = DateTime.now().add(Duration(days: 7));

    PrefObj.preferences!.put(PrefKeys.ACCOUNT_DELETION_REQUESTED, true);
    PrefObj.preferences!.put(
        PrefKeys.ACCOUNT_DELETION_DATE, deletionDate.millisecondsSinceEpoch);

    Navigator.of(context).pop(); // Close dialog

    // Show success message
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                Icon(Icons.schedule, color: Colors.orange, size: 50),
                SizedBox(height: 10.h),
                Text(
                  "Account Deletion Scheduled",
                  style: TextStyle(fontFamily: "Poppins2"),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your account will be permanently deleted on ${deletionDate.day}/${deletionDate.month}/${deletionDate.year}.",
                style: TextStyle(fontSize: 14.sp, fontFamily: "Poppins1"),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                "You can cancel this request by logging in again before that date.",
                style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: "Poppins1",
                    color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: logoBlue, fontFamily: "Poppins1"),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Keep user logged in but with deletion scheduled

                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/sign-in-sign-up-landing', (Route route) => false);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeletionStatusDialog() {
    if (!PrefObj.preferences!.containsKey(PrefKeys.ACCOUNT_DELETION_DATE))
      return;

    int deletionTimestamp =
        PrefObj.preferences!.get(PrefKeys.ACCOUNT_DELETION_DATE);
    DateTime deletionDate =
        DateTime.fromMillisecondsSinceEpoch(deletionTimestamp);
    DateTime now = DateTime.now();
    int daysLeft = deletionDate.difference(now).inDays;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                Icon(Icons.schedule, color: Colors.orange, size: 50),
                SizedBox(height: 10.h),
                Text(
                  "Account Deletion Scheduled",
                  style: TextStyle(fontFamily: "Poppins2"),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                daysLeft > 0
                    ? "Your account will be deleted in $daysLeft days."
                    : "Your account deletion is overdue and will be processed soon.",
                style: TextStyle(fontSize: 16.sp, fontFamily: "Poppins1"),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                "Deletion Date: ${deletionDate.day}/${deletionDate.month}/${deletionDate.year}",
                style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: "Poppins1",
                    color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text(
                    "Cancel Deletion",
                    style:
                        TextStyle(color: Colors.green, fontFamily: "Poppins1"),
                  ),
                  onPressed: () {
                    _cancelAccountDeletion();
                  },
                ),
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: logoBlue, fontFamily: "Poppins1"),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _cancelAccountDeletion() {
    PrefObj.preferences!.delete(PrefKeys.ACCOUNT_DELETION_REQUESTED);
    PrefObj.preferences!.delete(PrefKeys.ACCOUNT_DELETION_DATE);

    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50),
                SizedBox(height: 10.h),
                Text(
                  "Deletion Cancelled",
                  style: TextStyle(fontFamily: "Poppins2", color: Colors.green),
                ),
              ],
            ),
          ),
          content: Text(
            "Your account deletion has been cancelled. Your account is safe!",
            style: TextStyle(fontSize: 14.sp, fontFamily: "Poppins1"),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: logoBlue, fontFamily: "Poppins1"),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
