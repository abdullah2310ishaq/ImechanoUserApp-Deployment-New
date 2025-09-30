import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:imechano/localization/language_constrants.dart';
import 'package:imechano/ui/bloc/categories_bloc.dart';
import 'package:imechano/ui/bloc/item_list_bloc.dart';
import 'package:imechano/ui/bloc/oil%20change%20bloc.dart';
import 'package:imechano/ui/common/globals.dart' as globals;
import 'package:imechano/ui/modal/categoriesModelClass.dart';
import 'package:imechano/ui/modal/item_list_model.dart';

import 'package:imechano/ui/modal/oilchange_model.dart';
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:imechano/ui/provider/theme_provider.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/screens/bottombar/car_check_Up_page.dart';
import 'package:imechano/ui/screens/bottombar/floating_chat_button.dart';
import 'package:imechano/ui/screens/bottombar/quick_service.dart';
import 'package:imechano/ui/screens/location/location_map.dart';
import 'package:imechano/ui/screens/my_account/Notification.dart';
import 'package:imechano/ui/screens/my_account/more_servicies%20.dart';
import 'package:imechano/ui/screens/my_account/oil_change.dart';
import 'package:imechano/ui/share_preferences/pref_key.dart';
import 'package:imechano/ui/share_preferences/preference.dart';
import 'package:imechano/ui/shared/widgets/appbar/custom_drawer_widget.dart';
import 'package:imechano/ui/styling/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/globals.dart';
import '../bottombar/Car_detailing.dart';
import '../bottombar/emergency_page.dart';
import '../bottombar/homeSearch.dart';

class HomeScreen extends StatefulWidget {
  final int? currentCount;
  const HomeScreen({Key? key, this.currentCount});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userStr;
  var address;
  var dataLoad;
  bool checkExpansionTile = false;
  bool isCarAdded = false;
  var profileData;
  Timer? _notificationTimer;

  testfunc() async {
    var prefs = await SharedPreferences.getInstance();
    print("We are a");
    print(prefs.getString('language_code'));
  }

  getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      address = prefs.getString('address') ??
          getTranslated("Selectyouraddress", context);

      dataLoad = true;

      print(address);
    });
  }

  // ignore: unused_field
  List<Marker> _markers = <Marker>[];

  String? enteredKeyword = "";
  String emergency = "emergency";
  String checkup = "checkup";
  String quick = "quick";
  String detailing = "detailing";

  void _runFilter(String enteredKeyword) {
    print("Search keyword");
    print(enteredKeyword);
    if (enteredKeyword.length < 2) {
      if (PrefObj.preferences!.containsKey(PrefKeys.USER_ID)) {
        categoriesListBloc.categoriesSinck("null");
      }
    } else {
      if (PrefObj.preferences!.containsKey(PrefKeys.USER_ID)) {
        categoriesListBloc.categoriesSinck(enteredKeyword);
      }
    }

    // Refresh the UI
    setState(() {});
  }

  int? categorylength;
  @override
  void initState() {
    print("initializing");
    // ignore: todo
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize notification count provider early
      try {
        Provider.of<NotificationCountProvider>(context, listen: false)
            .setNotifications();
      } catch (e) {
        log('Failed to initialize notification count in home: $e');
      }

      // Avoid double prompts on iOS: request directly via FirebaseMessaging
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          announcement: false,
          criticalAlert: false,
          provisional: false,
          carPlay: false,
        );
      } else {
        Future.delayed(Duration(seconds: 2), () {
          showNotificationPermissionDialog(context);
        });
      }
    });

    getAddress();
    userStr =
        PrefObj.preferences!.containsKey(PrefKeys.USER_DATA) ? true : false;
    isCarAdded =
        PrefObj.preferences!.containsKey(PrefKeys.CARNAME) ? true : false;
    categoriesListBloc.categoriesSinck("null");
    oilchnageListBloc.oilChnageSinck('1');

    // Ensure real-time updates via local timer on Home as a backup
    _startNotificationTimer();
  }

  void _startNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && userStr == true) {
        try {
          Provider.of<NotificationCountProvider>(context, listen: false)
              .setNotifications();
        } catch (e) {
          log('Failed to refresh notification count: $e');
        }
      }
    });
  }

  void refreshCarStatus() {
    setState(() {
      isCarAdded =
          PrefObj.preferences!.containsKey(PrefKeys.CARNAME) ? true : false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh car status when screen comes back into focus
    refreshCarStatus();
  }

  @override
  void dispose() {
    print("disposing");
    _notificationTimer?.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!!"); // Do some stuff.
    print(ModalRoute.of(context)?.isActive);
    print(ModalRoute.of(context)?.isCurrent);
    print(ModalRoute.of(context)?.isFirst);
    print(info);
    print(stopDefaultButtonEvent);
    if (info.toString() == "2") {
      MaterialPageRoute(
        builder: (context) => BottomBarPage(2),
      );
    }
    // var route = ModalRoute.of(context);
    print('route');

    print(globals.screenstack);
    showDialog(
      builder: (_) => AlertDialog(
        title: Text(getTranslated('exitapp', context)),
        content: Text(getTranslated('doyouwanttoexitanapp', context)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(_).pop(false),
            //return false when click on "NO"
            child: Text(getTranslated('no', context)),
          ),
          ElevatedButton(
            onPressed: () {
              if (Platform.isAndroid) {
                PrefObj.preferences!.put(PrefKeys.APPSTARTED, true);

                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                PrefObj.preferences!.put(PrefKeys.APPSTARTED, true);

                exit(0);
              }
            },
            //return true when click on "Yes"
            child: Text(getTranslated('yes', context)),
          ),
        ],
      ),
      context: context,
    );
    return true;
  }

  Future<bool> showExitPopup() async {
    // print("Back button pressed");
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: Text(getTranslated('exitapp', context)),
            content: Text(getTranslated('doyouwanttoexitanapp', context)),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: Text(getTranslated('no', context)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    PrefObj.preferences!.put(PrefKeys.APPSTARTED, true);

                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    PrefObj.preferences!.put(PrefKeys.APPSTARTED, true);

                    exit(0);
                  }
                },
                //return true when click on "Yes"
                child: Text(getTranslated('yes', context)),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

  List drawerTitle = [];

  dynamic appModelTheme;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  int selectedindex = 0;
  bool isselected = false;

  List page = [CarCheckupPage(), CarCheckupPage(), CarCheckupPage()];

  List<Color> colorOne = [
    Color(0xffeeeeee),
    Color(0xffdae2ef),
    Color(0xfff8f1df),
    Color(0xffdceeff),
    Color(0xffedeaf0),
    Color(0xffffebec)
  ];

  bool status = false;
  bool isSwitch = false;

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    final appStart =
        PrefObj.preferences!.containsKey(PrefKeys.APPSTARTED) ? true : false;
    log("appStart Lgoin");
    testfunc();
    log(appStart.toString());
    appModelTheme = appModel;

    return Scaffold(
      key: _key,
      drawer: drawerpage(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          disabledElevation: 0.0,
          splashColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          child: Image.asset("assets/images/chat.png"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen()),
            );
          }),
      backgroundColor: appModelTheme.darkTheme ? black : Color(0xff70bdf1),
      body: ScreenUtilInit(
        designSize: Size(414, 896),
        builder: (context, child) =>
            NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowIndicator();
            return true;
          },
          child: SafeArea(
            child: Column(children: [
              appBarWidget(),
              SizedBox(height: 20.h),
              // ElevatedButton(
              //     onPressed: () {
              //       Navigator.push(context,
              //           MaterialPageRoute(builder: (_) => CheckOut(choice: 4)));
              //     },
              //     child: Text('Check out')),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.only(top: 9.h),
                      decoration: BoxDecoration(
                          color: appModelTheme.darkTheme
                              ? Color(0xff252525)
                              : white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(23.0),
                              topLeft: Radius.circular(23.0))),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
                              decoration: BoxDecoration(
                                  color: appModelTheme.darkTheme
                                      ? Color(0xff252525)
                                      : null,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(23.0),
                                      topLeft: Radius.circular(23.0))),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 7, right: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 7, right: 10),
                                          child: Row(
                                            children: [
                                              emergency.contains(
                                                          enteredKeyword!) ||
                                                      enteredKeyword == ""
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedindex = 0;
                                                          print(
                                                              "selectedIndex0");
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 7.sp),
                                                        height: 220.h,
                                                        width: 155.w,
                                                        child: card(
                                                            getTranslated(
                                                                'Emergency',
                                                                context),
                                                            getTranslated(
                                                                'CallNow',
                                                                context),
                                                            getTranslated(
                                                                'IsitEmergency',
                                                                context),
                                                            appModelTheme
                                                                    .darkTheme
                                                                ? darkmodeColor
                                                                : Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        0,
                                                                        0),
                                                            Colors.black,
                                                            Colors.white,
                                                            Colors.white,
                                                            Colors.white,
                                                            selectedindex == 0
                                                                ? true
                                                                : false,
                                                            0,
                                                            "assets/images/emergency1.png"),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 5.h,
                                                      width: 1.w,
                                                    ),
                                              SizedBox(width: 10.w),
                                              checkup.contains(
                                                          enteredKeyword!) ||
                                                      enteredKeyword == ""
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedindex = 1;
                                                          print(
                                                              "selectedIndex0");
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 7.sp),
                                                        height: 220.h,
                                                        width: 155.w,
                                                        child: card(
                                                            getTranslated(
                                                                'Dontknowwhat',
                                                                context),
                                                            getTranslated(
                                                                'BookaCarCheckup',
                                                                context),
                                                            getTranslated(
                                                                'Problemyourcarhas',
                                                                context),
                                                            appModelTheme
                                                                    .darkTheme
                                                                ? darkmodeColor
                                                                : Color
                                                                    .fromARGB(
                                                                        255,
                                                                        127,
                                                                        180,
                                                                        1),
                                                            Colors.black,
                                                            Colors.white,
                                                            Colors.white,
                                                            Colors.white,
                                                            selectedindex == 1
                                                                ? true
                                                                : false,
                                                            1,
                                                            "assets/images/know.png"),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 5.h,
                                                      width: 1.w,
                                                    ),
                                              SizedBox(width: 10.w),
                                              quick.contains(enteredKeyword!) ||
                                                      enteredKeyword == ""
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedindex = 2;
                                                          print(
                                                              "selectedIndex1");
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 7.sp),
                                                        height: 220.h,
                                                        width: 155.w,
                                                        child: card(
                                                            getTranslated(
                                                                "Quickservice",
                                                                context),
                                                            getTranslated(
                                                                "Quickservice",
                                                                context),
                                                            getTranslated(
                                                                "Fixedyourqueryinjustsec",
                                                                context),
                                                            appModelTheme
                                                                    .darkTheme
                                                                ? darkmodeColor
                                                                : Color(
                                                                    0xff3b5999),
                                                            Colors.black,
                                                            Colors.white,
                                                            Colors.white,
                                                            Colors.white,
                                                            selectedindex == 2
                                                                ? true
                                                                : false,
                                                            2,
                                                            "assets/images/quicktime.png"),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 5.h,
                                                      width: 1.w,
                                                    ),
                                              SizedBox(width: 10.w),
                                              detailing.contains(
                                                          enteredKeyword!) ||
                                                      enteredKeyword == ""
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedindex = 3;
                                                          print(
                                                              "selectedIndex2");
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 7.sp),
                                                        height: 220.h,
                                                        width: 155.w,
                                                        child: card(
                                                            getTranslated(
                                                                "upholstery",
                                                                context),
                                                            getTranslated(
                                                                "BookingNow",
                                                                context),
                                                            getTranslated(
                                                                "Improvecarperformance",
                                                                context),
                                                            appModelTheme
                                                                    .darkTheme
                                                                ? darkmodeColor
                                                                : Colors.orange,
                                                            Colors.black,
                                                            Colors.white,
                                                            Colors.white,
                                                            Colors.white,
                                                            selectedindex == 3
                                                                ? true
                                                                : false,
                                                            3,
                                                            "assets/icons/home/upholstery.png"),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 5.h,
                                                      width: 1.w,
                                                    ),
                                              if (!(detailing.contains(
                                                      enteredKeyword!) ||
                                                  quick.contains(
                                                      enteredKeyword!) ||
                                                  emergency.contains(
                                                      enteredKeyword!) ||
                                                  checkup.contains(
                                                      enteredKeyword!))) ...[
                                                SizedBox(
                                                  height: 180.h,
                                                  width: 200.w,
                                                  child: Center(
                                                      child: Text(
                                                          "No Booking Found")),
                                                )
                                              ],
                                              SizedBox(width: 10.w),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // TextButton(
                                      //     onPressed: () {
                                      //       Navigator.push(
                                      //           context,
                                      //           MaterialPageRoute(
                                      //               builder: (context) =>
                                      //                   CheckOut()));
                                      //     },
                                      //     child: Text("Checkout")),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 17.w,
                                            top: 2.sp,
                                            right: 25.sp),
                                        child: Text(
                                          getTranslated('OurServices', context),
                                          style: TextStyle(
                                              fontFamily: "Poppins1",
                                              fontSize: 15.sp),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      StreamBuilder<CategoriesModelClass>(
                                          stream: categoriesListBloc
                                              .CategoryListStream,
                                          builder: (context,
                                              AsyncSnapshot<
                                                      CategoriesModelClass>
                                                  categoriesSnapshot) {
                                            log('Catogories Snapshots');

                                            if (!categoriesSnapshot.hasData) {
                                              return CircularProgressIndicator();
                                            }
                                            if (categoriesSnapshot
                                                    .data!.data!.length ==
                                                0) {
                                              return Container(
                                                  height: 280.h,
                                                  alignment: Alignment.center,
                                                  child:
                                                      Text("No Service Found"));
                                            }

                                            return Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(width: 10.w),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          height: 110.h,
                                                          // color: Colors.red,
                                                          child: ourServiceCard(
                                                              categoriesSnapshot,
                                                              0),
                                                        )),
                                                    SizedBox(width: 14.w),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          height: 110.h,
                                                          // color: Colors.red,
                                                          child: ourServiceCard(
                                                              categoriesSnapshot,
                                                              1),
                                                        )),
                                                    SizedBox(width: 10.w),
                                                  ],
                                                ),
                                                SizedBox(height: 14.h),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      containerCard(
                                                          categoriesSnapshot),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                      SizedBox(height: 19.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [photoBanner()],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget appBarWidget() {
    log('Screen Size: ${screenSize?.height}');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _key.currentState!.openDrawer();
                    globals.screenstack++;
                  });
                },
                child: Container(
                    margin: appModelTheme.appLocal == Locale("en")
                        ? EdgeInsets.only(left: 1.w)
                        : EdgeInsets.only(right: 1.w),
                    // decoration:
                    //     BoxDecoration(border: Border.all(color: Colors.black)),
                    color: Colors.transparent,
                    child: SvgPicture.asset(
                      "assets/svg/Menu.svg",
                      height: 18.h,
                      width: 18.w,
                    )),
              ),
              // Shorter search field with fixed max width for consistent feel
              Flexible(
                child: Container(
                  height: 40.h,
                  constraints: BoxConstraints(maxWidth: 0.72.sw),
                  margin: appModelTheme.appLocal == Locale("en")
                      ? EdgeInsets.only(left: 15.w, right: 2.w)
                      : EdgeInsets.only(left: 2.w, right: 15.w),
                  child: TextField(
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    onTap: () {
                      setState(() {});

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Jobs(),
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          "assets/svg/serch.svg",
                        ),
                      ),
                      hintText: getTranslated('Searchservice', context),
                      hintStyle: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins3',
                          color: appModelTheme.darkTheme
                              ? Color(0xff252525)
                              : Color(0xff031320)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    ),
                  ),
                ),
              ),
              // Bell icon aligned and consistent with shared app bar
              GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return NotificationScreen();
                      },
                    ));
                  },
                  child: Selector<NotificationCountProvider, int>(
                      selector: (context, provider) => provider.notifications,
                      builder: (context, count, child) {
                        final hasNotifications = count > 0;
                        return Container(
                          width: 50.w,
                          height: 50.h,
                          alignment: Alignment.center,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/svg/ball.svg",
                                  width: 24.w,
                                  height: 24.h,
                                ),
                              ),
                              if (hasNotifications)
                                PositionedDirectional(
                                  top: 6,
                                  end: 8,
                                  child: badges.Badge(
                                    position: badges.BadgePosition.topEnd(
                                        top: 0, end: 0),
                                    badgeStyle: badges.BadgeStyle(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      elevation: 0,
                                    ),
                                    badgeContent: Text(
                                      count > 99 ? '99+' : '$count',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 9),
                                    ),
                                    child: SizedBox(width: 0, height: 0),
                                  ),
                                ),
                            ],
                          ),
                        );
                      })),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(15.w, 0, 5.w, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4), // Shadow color
                      spreadRadius: 4, // Spread radius
                      blurRadius: 0, // Blur radius
                      offset: Offset(
                          0, 3), // Offset for horizontal and vertical position
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(
                            bottom: 9.h, left: 5.w, top: 14.h, right: 10.w),
                        child: SvgPicture.asset(
                          "assets/svg/Places.svg",
                          height: 20.h,
                          width: 20.w,
                        )),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return MapLocation(
                              callBackFunction: (mainAddress) {
                                _markers = <Marker>[];
                                getAddress();

                                setState(() {});
                              },
                            );
                          },
                        ));
                      },
                      child: Container(
                          alignment: Alignment.centerLeft,
                          width: 200.w,
                          height: 40.h,
                          margin:
                              EdgeInsets.only(left: 5.w, top: 5.h, right: 5.w),
                          child: PrefObj.preferences!
                                  .containsKey(PrefKeys.USER_DATA)
                              ? dataLoad == true
                                  ? Text(
                                      '$address',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontFamily: 'Poppins3'),
                                    )
                                  : Text(
                                      "No Location Found",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontFamily: 'Poppins3'),
                                    )
                              : Text(
                                  "No Location Found",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontFamily: 'Poppins3'),
                                )),
                    ),
                  ],
                ),
              ),
              // Spacer(),
              Flexible(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomBarPage(0),
                          //  SelectYourCarScreen(
                          //     type: AddCarType.home)
                        ));
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 37.h,
                    margin: appModelTheme.appLocal == Locale("en")
                        ? EdgeInsets.only(left: 15.w)
                        : EdgeInsets.only(right: 15.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent
                              .withOpacity(0.4), // Shadow color
                          spreadRadius: 8, // Spread radius
                          blurRadius: 0, // Blur radius
                          offset: Offset(0,
                              3), // Offset for horizontal and vertical position
                        ),
                      ],
                    ),
                    child: isCarAdded &&
                            PrefObj.preferences!
                                    .get(PrefKeys.CARNAME)
                                    .toString()
                                    .length >
                                1
                        ? Center(
                            child: Text(
                              '${PrefObj.preferences!.get(PrefKeys.CARNAME)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins1",
                                  fontSize: 13.sp),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 40.h,
                                margin: EdgeInsets.only(
                                    left: 5.w, top: 5.h, right: 5.w),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                                  child: Text(
                                    getTranslated('AddCar', context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins1",
                                        fontSize: 12.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget card(txt, button, sub, Color color, Color colors, colorr, subcolor,
      buttoncolor, bool isselected, int selectedindex, String imageUrl) {
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black45,
        elevation: 2,
        color: color,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 33.sp,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage(imageUrl),
                      height: imageUrl.contains('upholstery') ? 36.sp : 42.sp,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            txt,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: "Poppins1",
                                color: colorr,
                                fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          sub,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                              color: subcolor,
                              fontSize: 10.sp,
                              fontFamily: "poppins3"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 17.h,
                ),
                Container(
                  height: 37.h,
                  width: 129.w,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            appModelTheme.darkTheme
                                ? Color(0xff3e9ee0)
                                : buttoncolor),
                        alignment: Alignment.center,
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ))),
                    // textColor: Colors.white,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        button,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 10.8.sp,
                            color: appModelTheme.darkTheme ? white : colors),
                      ),
                    ),
                    // color:
                    //     appModelTheme.darkTheme ? Color(0xff3e9ee0) : buttoncolor,
                    onPressed: () {
                      print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                      print("press");
                      print(selectedindex);
                      if (selectedindex == 0)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmergencyPage()));

                      if (selectedindex == 1)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CarCheckupPage()));
                      if (selectedindex == 2)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuickServices()));
                      if (selectedindex == 3)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CarDetailing()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget ourServiceCard(
      AsyncSnapshot<CategoriesModelClass> categoriesSnapshot, int i) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          log("pressed General  service");
          globals.screenstack++;
          print('globals.screenstack I m on my screen');
          print(globals.screenstack);
          if (!isCarAdded ||
              PrefObj.preferences!.get(PrefKeys.CARNAME).toString().length <
                  2) {
            globals.screenstack--;
            log("car not added");
            showSelectCarDialog();
            Fluttertoast.showToast(
                msg: "Please Select A Car",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black12,
                textColor: Colors.black,
                fontSize: 16.0);
          } else {
            oilchnageListBloc
                .oilChnageSinck(categoriesSnapshot.data!.data![i].id!);

            showMaterialModalBottomSheet(
              isDismissible: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              context: context,
              builder: (context) => Container(
                height: MediaQuery.of(context).size.height / 1.4,
                padding: EdgeInsets.only(top: 5),
                child: StreamBuilder<OilChangeModel>(
                    stream: oilchnageListBloc.OilchnageListStream,
                    builder:
                        (context, AsyncSnapshot<OilChangeModel> listSnapshot) {
                      if (!listSnapshot.hasData) {
                        return SizedBox(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return NotificationListener<
                          OverscrollIndicatorNotification>(
                        onNotification: (notification) {
                          notification.disallowIndicator();
                          return true;
                        },
                        child: StatefulBuilder(
                          builder: (BuildContext context,
                              StateSetter setState /*You can rename this!*/) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 25, right: 25, top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                            onTap: () {
                                              log('Pressed SubCatogory');
                                              globals.screenstack = 0;

                                              Navigator.pop(context);
                                            },
                                            child: Icon(
                                              Icons
                                                  .keyboard_double_arrow_down_outlined,
                                              size: 30,
                                              color: Colors.blue[300],
                                            )),
                                      ],
                                    ),
                                    Text(
                                      //translation
                                      getTranslated(
                                              categoriesSnapshot
                                                  .data!.data![i].categoryName!
                                                  .split(" ")[0],
                                              context) +
                                          " " +
                                          getTranslated(
                                              categoriesSnapshot
                                                  .data!.data![i].categoryName!
                                                  .split(" ")[1],
                                              context),
                                      style: TextStyle(
                                          fontFamily: "Poppins1", fontSize: 18),
                                    ),
                                    SizedBox(height: 10),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding:
                                              MediaQuery.of(context).viewInsets,
                                          child: Column(
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount: listSnapshot
                                                    .data!.data!.length,
                                                itemBuilder: (context, index) {
                                                  if (listSnapshot
                                                      .data!.data![index].id!
                                                      .contains("9999")) {
                                                    return Container();
                                                  } else
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0),

                                                      //Section to be Viewed for Others
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          globals.screenstack++;
                                                          log("Pressed SubCatogory");

                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                            builder: (context) {
                                                              return oil_Change(
                                                                mainCatogory:
                                                                    categoriesSnapshot
                                                                        .data!
                                                                        .data![
                                                                            i]
                                                                        .categoryName!,
                                                                id: listSnapshot
                                                                    .data!
                                                                    .data![
                                                                        index]
                                                                    .id!,
                                                                categoryId:
                                                                    categoriesSnapshot
                                                                        .data!
                                                                        .data![
                                                                            i]
                                                                        .id!,
                                                                categoryName:
                                                                    listSnapshot
                                                                        .data!
                                                                        .data![
                                                                            index]
                                                                        .name!,
                                                                data: listSnapshot
                                                                        .data!
                                                                        .data![
                                                                    index],
                                                                selected:
                                                                    listSnapshot
                                                                        .data!
                                                                        .data![
                                                                            index]
                                                                        .selected,
                                                                selectedServices:
                                                                    globals
                                                                        .selectedService,
                                                              );
                                                            },
                                                          ));
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.072,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: appModelTheme
                                                                    .darkTheme
                                                                ? darkmodeColor
                                                                : Color(
                                                                    0xfff4f5f7),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10.0,
                                                                    right: 10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  getTranslated(
                                                                      listSnapshot
                                                                          .data!
                                                                          .data![
                                                                              index]
                                                                          .name!
                                                                          .removeAllWhitespace,
                                                                      context),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17),
                                                                ),
                                                                StreamBuilder<
                                                                        ItemListModel>(
                                                                    stream: ItemListBloc()
                                                                        .ItemListStream,
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                10,
                                                                                10,
                                                                                10,
                                                                                10), //apply padding to LTRB, L:Left, T:Top, R:Right, B:Bottom
                                                                            child:
                                                                                Text(""),
                                                                            // child: Text( listSnapshot.data!.data![index].counter.toString()), // Services Counters
                                                                          ),
                                                                          Icon(
                                                                              Icons.arrow_forward_ios_outlined,
                                                                              size: 16),
                                                                        ],
                                                                      );
                                                                    })
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                },
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: appModelTheme.darkTheme
                                                      ? darkmodeColor
                                                      : Color(0xfff4f5f7),
                                                ),
                                              ),
                                              SizedBox(height: 10.h),
                                              Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    checkExpansionTile == true
                                        ? InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          oil_Change(
                                                            mainCatogory:
                                                                categoriesSnapshot
                                                                    .data!
                                                                    .data![i]
                                                                    .categoryName!,
                                                            id: listSnapshot
                                                                .data!
                                                                .data![0]
                                                                .id!,
                                                            categoryId:
                                                                categoriesSnapshot
                                                                    .data!
                                                                    .data![i]
                                                                    .id!,
                                                            categoryName:
                                                                listSnapshot
                                                                    .data!
                                                                    .data![0]
                                                                    .name!,
                                                            data: listSnapshot
                                                                .data!.data![0],
                                                          )));
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.only(
                                                        top: 15, bottom: 15),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xff70bdf1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    child: Text(
                                                      "View Selection",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Poppins2'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 10.h,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: appModelTheme.darkTheme
                  ? darkmodeColor
                  : i == 0
                      ? Color(0xfffee9d8)
                      : Color(0xffF0EFEA),
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(
                          categoriesSnapshot.data!.data![i].categoryName!
                              .split(' ')[0],
                          context),
                      style: TextStyle(fontFamily: 'Poppins1', fontSize: 11),
                    ),
                    Text(
                      getTranslated(
                          categoriesSnapshot.data!.data![i].categoryName!
                              .split(' ')[1],
                          context),
                      style: TextStyle(fontFamily: 'Poppins1', fontSize: 11),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 7.w, left: 7.w),
                child: Image(
                  image:
                      NetworkImage("${categoriesSnapshot.data!.data![i].icon}"),
                  height: 80.h,
                  width: 75.w,
                ),
              ),
              SizedBox(
                height: 10.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget containerCard(AsyncSnapshot<CategoriesModelClass> categoriesSnapshot) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: (118.w / 118.h),
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 14.h),
        itemCount: categoriesSnapshot.data!.data!.length - 2,
        itemBuilder: (BuildContext context, int index) {
          // log(categoriesSnapshot.data!.data![index].categoryName.toString());
          // log(categoriesSnapshot
          //     .data!.data![index + 2].categoryName!.removeAllWhitespace
          //     .toLowerCase()
          //     .toString());
          return index != 5
              ? GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: appModelTheme.darkTheme
                          ? darkmodeColor
                          : Color(0xfff4f5f7),
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          (() {
                            final String catKey = categoriesSnapshot
                                .data!
                                .data![index + 2]
                                .categoryName!
                                .removeAllWhitespace
                                .toLowerCase();
                            final String localized =
                                getTranslated(catKey, context);
                            if (catKey == 'checkbytestdrive') {
                              final parts = localized.split(' ');
                              if (parts.length > 2) {
                                final firstLine = parts.sublist(0, 2).join(' ');
                                final secondLine = parts.sublist(2).join(' ');
                                return '$firstLine\n$secondLine';
                              }
                              return localized.replaceFirst(' ', '\n');
                            }
                            return localized;
                          })(),
                          style: TextStyle(
                              fontSize: 12.sp, fontFamily: 'Poppins1'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        Image(
                          // fit: BoxFit.contain,
                          image: NetworkImage(
                              "${categoriesSnapshot.data!.data![index + 2].icon}"),
                          height: 50.h,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    log("onTap 1101");
                    if (!isCarAdded ||
                        PrefObj.preferences!
                                .get(PrefKeys.CARNAME)
                                .toString()
                                .length <
                            2) {
                      log("car not added");
                      showSelectCarDialog();
                      Fluttertoast.showToast(
                          msg: getTranslated('pleaseselectacar', context),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black12,
                          textColor: Colors.black,
                          fontSize: 16.0);
                    } else {
                      oilchnageListBloc.oilChnageSinck(
                          categoriesSnapshot.data!.data![index + 2].id!);
                      showMaterialModalBottomSheet(
                        isDismissible: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                        context: context,
                        builder: (context) => StatefulBuilder(
                          builder: (context, setState) => Container(
                            height: MediaQuery.of(context).size.height / 1.5,
                            padding: EdgeInsets.only(top: 5),
                            child: StreamBuilder<OilChangeModel>(
                                stream: oilchnageListBloc.OilchnageListStream,
                                builder: (context,
                                    AsyncSnapshot<OilChangeModel>
                                        listSnapshot) {
                                  if (!listSnapshot.hasData) {
                                    return SizedBox(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  return NotificationListener<
                                      OverscrollIndicatorNotification>(
                                    onNotification: (notification) {
                                      notification.disallowIndicator();
                                      return true;
                                    },
                                    child: SingleChildScrollView(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 25, right: 25, top: 5),
                                        child: Column(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .keyboard_double_arrow_down_outlined,
                                                          size: 30,
                                                          color:
                                                              Colors.blue[200],
                                                        )),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      getTranslated(
                                                          categoriesSnapshot
                                                              .data!
                                                              .data![index + 2]
                                                              .categoryName!
                                                              .removeAllWhitespace,
                                                          context),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "Poppins1",
                                                          fontSize: 18.sp),
                                                    ),
                                                    //Shoaib do work here
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  itemCount: listSnapshot
                                                      .data!.data!.length,
                                                  itemBuilder: (context, i) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0),
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: appModelTheme
                                                                    .darkTheme
                                                                ? Color(
                                                                    0xff373737)
                                                                : Color(
                                                                    0xfff4f5f7),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: ListTile(
                                                            onTap: () {
                                                              log('Going to oil change screen');
                                                              log('Main Category: ${categoriesSnapshot.data!.data![index + 2].categoryName!}');
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (_) =>
                                                                          oil_Change(
                                                                            mainCatogory:
                                                                                categoriesSnapshot.data!.data![index + 2].categoryName!,
                                                                            id: listSnapshot.data!.data![i].id!,
                                                                            categoryId:
                                                                                categoriesSnapshot.data!.data![i].id!,
                                                                            categoryName:
                                                                                listSnapshot.data!.data![i].name!,
                                                                            data:
                                                                                listSnapshot.data!.data![i],
                                                                          )));
                                                            },
                                                            trailing: Icon(
                                                                Icons
                                                                    .arrow_forward_ios_outlined,
                                                                size: 16),
                                                            title: Text(
                                                              (() {
                                                                final raw =
                                                                    listSnapshot
                                                                        .data!
                                                                        .data![
                                                                            i]
                                                                        .name!;
                                                                final key = raw
                                                                    .trim()
                                                                    .replaceAll(
                                                                        ' ', '')
                                                                    .toLowerCase();
                                                                final localized =
                                                                    getTranslated(
                                                                        key,
                                                                        context);
                                                                // If translation returns the key back, show backend text
                                                                return (localized ==
                                                                        key)
                                                                    ? raw.replaceAll(
                                                                        'BookaTestDrive',
                                                                        'Book a Test Drive')
                                                                    : localized;
                                                              })(),
                                                            ),
                                                          )),
                                                    );
                                                  },
                                                ),
                                                SizedBox(height: 10.h),
                                                Container(),
                                                SizedBox(height: 10.h),
                                                checkExpansionTile == true
                                                    ? InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      oil_Change(
                                                                        id: listSnapshot
                                                                            .data!
                                                                            .data![0]
                                                                            .id!,
                                                                        categoryId: categoriesSnapshot
                                                                            .data!
                                                                            .data![index]
                                                                            .id!,
                                                                        categoryName: listSnapshot
                                                                            .data!
                                                                            .data![0]
                                                                            .name!,
                                                                        data: listSnapshot
                                                                            .data!
                                                                            .data![0],
                                                                      )));
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 15,
                                                                        bottom:
                                                                            15),
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xff70bdf1),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(10))),
                                                                child: Text(
                                                                  "View Selection",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontFamily:
                                                                          'Poppins2'),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      );
                    }
                  })
              : GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: appModelTheme.darkTheme
                          ? darkmodeColor
                          : Color(0xfff4f5f7),
                      // color: colorOne[index],
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated('otherservices', context),
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 12.sp, fontFamily: 'Poppins1'),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (!isCarAdded ||
                        PrefObj.preferences!
                                .get(PrefKeys.CARNAME)
                                .toString()
                                .length <
                            2) {
                      log("car not added");
                      showSelectCarDialog();
                      Fluttertoast.showToast(
                          msg: getTranslated('pleaseselectacar', context),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black12,
                          textColor: Colors.black,
                          fontSize: 16.0);
                    } else {
                      oilchnageListBloc.oilChnageSinck(
                          categoriesSnapshot.data!.data![index + 2].id!);
                      showMaterialModalBottomSheet(
                        isDismissible: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                        context: context,
                        builder: (context) => StatefulBuilder(
                          builder: (context, setState) => Container(
                            height: MediaQuery.of(context).size.height / 1.5,
                            padding: EdgeInsets.only(top: 5),
                            child: StreamBuilder<OilChangeModel>(
                                stream: oilchnageListBloc.OilchnageListStream,
                                builder: (context,
                                    AsyncSnapshot<OilChangeModel>
                                        listSnapshot) {
                                  if (!listSnapshot.hasData) {
                                    return SizedBox(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return NotificationListener<
                                      OverscrollIndicatorNotification>(
                                    onNotification: (notification) {
                                      notification.disallowIndicator();
                                      return true;
                                    },
                                    child: SingleChildScrollView(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 25, right: 25, top: 5),
                                        child: Column(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .keyboard_double_arrow_down_outlined,
                                                          size: 30,
                                                          color:
                                                              Colors.blue[200],
                                                        )),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      getTranslated(
                                                          categoriesSnapshot
                                                              .data!
                                                              .data![index + 2]
                                                              .categoryName!
                                                              .removeAllWhitespace
                                                              .toLowerCase(),
                                                          context),
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "Poppins1",
                                                          fontSize: 18.sp),
                                                    ),
                                                    //Shoaib do work here
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  itemCount: listSnapshot
                                                      .data!.data!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0),
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: appModelTheme
                                                                    .darkTheme
                                                                ? Color(
                                                                    0xff373737)
                                                                : Color(
                                                                    0xfff4f5f7),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: ListTile(
                                                            onTap: () {
                                                              Get.off(MoreServicies(
                                                                  listSnapshot
                                                                      .data!
                                                                      .data![
                                                                          index]
                                                                      .id!));
                                                            },
                                                            trailing: Icon(
                                                                Icons
                                                                    .arrow_forward_ios_outlined,
                                                                size: 16),
                                                            title: Text(getTranslated(
                                                                listSnapshot
                                                                    .data!
                                                                    .data![
                                                                        index]
                                                                    .name!
                                                                    .removeAllWhitespace
                                                                    .toLowerCase(),
                                                                context)),
                                                          )),
                                                    );
                                                  },
                                                ),
                                                SizedBox(height: 10.h),
                                                Container(),
                                                SizedBox(height: 10.h),
                                                checkExpansionTile == true
                                                    ? InkWell(
                                                        onTap: () {},
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 15,
                                                                        bottom:
                                                                            15),
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xff70bdf1),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(10))),
                                                                child: Text(
                                                                  "View Selection",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontFamily:
                                                                          'Poppins2'),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      );
                    }
                  },
                );
        });
  }

  Widget photoBanner() {
    return Container(
      // margin: EdgeInsets.only(left: 10.w, right: 10.w),
      height: 102.h,
      width: MediaQuery.of(context).size.width * 0.92,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: AssetImage("assets/icons/home/Group 9251.png")),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 20.w, top: 15.h),
            child: Text(
              "Find Auto Service Near You",
              style: TextStyle(
                  color: Colors.white, fontFamily: "Poppins5", fontSize: 16.sp),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.w, top: 2.h),
            child: Text(
              "Free Pick-up and delivery fees to the location specify",
              style: TextStyle(
                  color: Colors.white, fontSize: 10.sp, fontFamily: "Poppins3"),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 20.w, top: 6.h),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xff1840db)),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h)),
                      minimumSize: MaterialStateProperty.all<Size>(Size(0, 0)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(color: Colors.white)))),
                  onPressed: () {},
                  child: Text(
                    "Get 30% OFF",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget alertBox() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            decoration: BoxDecoration(
                color: appModelTheme.darkTheme
                    ? Color(0xff252525)
                    : Color(0xffa2bdd1),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0))),
            child: Row(
              children: [
                SizedBox(width: 10),
                Image(
                    image: AssetImage("assets/icons/My Account/Group 8349.png"),
                    height: 30),
                SizedBox(width: 10),
                Text(
                  "IMechano Notification",
                  style: TextStyle(
                    color: Color(0xfffff9f9),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    "22m ago",
                    style: TextStyle(
                      color: Color(0xfffff9f9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color:
                    appModelTheme.darkTheme ? darkmodeColor : Color(0xffa5a8aa),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Hey lorriy this remander that one oil change",
                        style: TextStyle(color: Color(0xffdbddde)),
                      ),
                      Text(
                        "services request through Imachano make",
                        style: TextStyle(color: Color(0xffdbddde)),
                      ),
                      Text(
                        "sure you tune in on17 july. 6 pm check \nthe service hope understand",
                        style: TextStyle(color: Color(0xffdbddde)),
                      ),
                    ],
                  ),
                ),
                Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                    child: Text(
                      "Press for More",
                      style: TextStyle(
                          color: Color(0xffece8e8),
                          fontFamily: "Poppins2",
                          fontSize: 15),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showSelectCarDialog() {
    showDialog(
      builder: (_) => AlertDialog(
        title: Text(getTranslated("Nocarselected!", context)),
        content: Text(getTranslated('Pleaseselectacartoproceed', context)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(_).pop(false),
            //return false when click on "NO"
            child: Text(getTranslated('close', context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BottomBarPage(0),
                    //  SelectYourCarScreen(
                    //     type: AddCarType.home)
                  ));
            },
            //return true when click on "Yes"
            child: Text(getTranslated('Select', context)),
          ),
        ],
      ),
      context: context,
    );
  }
}

void showNotificationPermissionDialog(BuildContext context) async {
  // Show custom dialog
  PermissionStatus status = await Permission.notification.status;
  if (!status.isGranted) {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Notifications'),
        content: Text(
            'We use notifications to keep you updated. Would you like to enable notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No, thanks'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Enable'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Ask for notification permissions
      await requestNotificationPermission();
    } else {
      Get.snackbar('Info', 'You can enable notifications later in settings.',
          backgroundColor: Colors.blue, colorText: Colors.white);
    }
  }
}

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    // Check POST_NOTIFICATIONS permission on Android
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      // Request permission
      PermissionStatus newStatus = await Permission.notification.request();

      if (newStatus.isDenied) {
        Get.snackbar(
          'Warning!',
          'Notification permissions are denied.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else if (newStatus.isPermanentlyDenied) {
        Get.snackbar(
          'Error!',
          'Notification permissions are permanently denied. Please enable them from settings.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await openAppSettings();
      } else {
        Get.snackbar(
          'Success!',
          'Notification permissions granted.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } else if (status.isPermanentlyDenied) {
      // If already permanently denied, open app settings
      Get.snackbar(
        'Error!',
        'Notification permissions are permanently denied. Please enable them from settings.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      await openAppSettings();
    } else {
      Get.snackbar(
        'Info!',
        'Notification permissions are already granted.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  } else if (Platform.isIOS) {
    // Use Firebase Messaging on iOS to avoid duplicate prompts
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      criticalAlert: false,
      provisional: false,
      carPlay: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      Get.snackbar(
        'Warning!',
        'Notification permissions are denied on iOS.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      await openAppSettings();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      Get.snackbar(
        'Info',
        'Notifications enabled provisionally on iOS.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Success!',
        'Notification permissions granted on iOS.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
