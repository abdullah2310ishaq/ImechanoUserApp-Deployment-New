// ignore_for_file: must_be_immutable, unnecessary_brace_in_string_interps

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imechano/ui/common/globals.dart' as globals;
import 'package:imechano/ui/provider/notification_count_provider.dart';
import 'package:imechano/ui/provider/theme_provider.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/screens/my_account/Notification.dart';
import 'package:imechano/ui/styling/colors.dart';
import 'package:provider/provider.dart';

class WidgetAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Color? textIconColor;
  final String? imageicon;
  final String? title;
  final double? height;
  final String? menuItem;
  final String? home;
  final String? action;
  final String? action2;
  final bool flag;

  WidgetAppBar({
    this.backgroundColor = logoBlue,
    this.textIconColor = white,
    this.imageicon,
    this.title = '',
    this.menuItem,
    this.home,
    this.height = kToolbarHeight,
    this.action,
    this.action2,
    this.flag = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height!);

  @override
  _WidgetAppBarState createState() => _WidgetAppBarState();
}

class _WidgetAppBarState extends State<WidgetAppBar> {
  dynamic appModelTheme;
  int count = 1;
  int _lastNotifiedCount = -1;
  bool _isInitialized = false;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    appModelTheme = appModel;
    return ScreenUtilInit(
      designSize: Size(414, 896),
      builder: (context, child) => AppBar(
        key: _key,
        toolbarHeight: 60.h,
        leadingWidth: 120.w,
        iconTheme: IconThemeData(
          color: widget.textIconColor,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  print("I M RRR");
                  if (widget.menuItem!
                      .contains('assets/svg/Arrow_alt_left.svg')) {
                    // Back button - navigate back
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context);
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => BottomBarPage(2)),
                          (Route<dynamic> route) => false);
                    }
                  } else {
                    // Menu button - open drawer
                    Scaffold.of(context).openDrawer();
                  }
                },
                child: Container(
                    width: 50.w,
                    height: 50.h,
                    padding: EdgeInsets.all(12.w),
                    child: SvgPicture.asset(
                      '${widget.menuItem}',
                      width: 24.w,
                      height: 24.h,
                    )),
              ),
              InkWell(
                splashColor: Color(0xFF2A7AD5), // Customizing the splash color
                onTap: () {
                  if (widget.imageicon != null) {
                    print("Shoaib Pressed Back button from App Bar");
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context);
                    } else {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => BottomBarPage(2)),
                          (Route<dynamic> route) => false);
                    }
                  }
                },
                child: Container(
                    width: 50.w,
                    height: 50.h,
                    padding: EdgeInsets.all(12.w),
                    child: SvgPicture.asset(
                      '${widget.imageicon}',
                      width: 24.w,
                      height: 24.h,
                    )),
              ),
            ],
          ),
        ),
        actions: [
          widget.home != null
              ? GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => BottomBarPage(2)),
                        (Route<dynamic> route) => false);
                  },
                  child: Container(
                      width: 50.w,
                      height: 50.h,
                      padding: EdgeInsets.all(12.w),
                      child: SvgPicture.asset(
                        "${widget.home}",
                        width: 24.w,
                        height: 24.h,
                        color: Colors.white,
                      )),
                )
              : Text(''),
          if (widget.action2 != null)
            GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return NotificationScreen();
                    },
                  ));
                  globals.screenstack++;
                },
                child: Selector<NotificationCountProvider, int>(
                    selector: (context, provider) => provider.notifications,
                    builder: (context, count, child) {
                      // Debounce mechanism to prevent double blink
                      if (!_isInitialized) {
                        _lastNotifiedCount = count;
                        _isInitialized = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() {});
                        });
                      }

                      final hasNotifications = count > 0;
                      final shouldShow =
                          count != _lastNotifiedCount || hasNotifications;

                      if (shouldShow) {
                        _lastNotifiedCount = count;
                      }

                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: hasNotifications
                            ? Container(
                                key: ValueKey('badge_$count'),
                                width: 50.w,
                                height: 50.h,
                                alignment: Alignment.center,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Bell icon centered
                                    Align(
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        "${widget.action2}",
                                        width: 24.w,
                                        height: 24.h,
                                      ),
                                    ),
                                    // Badge pinned to top-right of the icon area
                                    Positioned(
                                      top: 6,
                                      right: 8,
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
                              )
                            : Container(
                                key: ValueKey('no_badge'),
                                width: 50.w,
                                height: 50.h,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "${widget.action2}",
                                  width: 24.w,
                                  height: 24.h,
                                ),
                              ),
                      );
                    })),
          //   Container(
          //       padding:
          //           EdgeInsets.only(top: 15, right: 17, bottom: 15, left: 13),
          //       child: SvgPicture.asset(
          //         "${action2}",
          //       )),
          // ),
        ],
        title: Text(
          widget.title!,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Poppins1',
            color: widget.textIconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor:
            appModelTheme.darkTheme ? black : widget.backgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
