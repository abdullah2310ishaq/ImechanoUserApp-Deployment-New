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

class WidgetAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  dynamic appModelTheme;
  int count = 1;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Size get preferredSize => Size.fromHeight(height!);

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
          color: textIconColor,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  print("I M RRR");
                  if (menuItem!.contains('assets/svg/Arrow_alt_left.svg')) {
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
                      '${menuItem}',
                      width: 24.w,
                      height: 24.h,
                    )),
              ),
              InkWell(
                splashColor: Color(0xFF2A7AD5), // Customizing the splash color
                onTap: () {
                  if (imageicon != null) {
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
                      '${imageicon}',
                      width: 24.w,
                      height: 24.h,
                    )),
              ),
            ],
          ),
        ),
        actions: [
          home != null
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
                        "${home}",
                        width: 24.w,
                        height: 24.h,
                        color: Colors.white,
                      )),
                )
              : Text(''),
          if (action2 != null)
            GestureDetector(onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return NotificationScreen();
                },
              ));
              globals.screenstack++;
            }, child: Consumer<NotificationCountProvider>(
                builder: (context, value, child) {
              return value.notifications == 0
                  ? Container(
                      width: 50.w,
                      height: 50.h,
                      padding: EdgeInsets.all(12.w),
                      child: SvgPicture.asset(
                        "${action2}",
                        width: 24.w,
                        height: 24.h,
                      ),
                    )
                  : badges.Badge(
                      // toAnimate: false,
                      badgeContent: Text(
                        value.notifications > 99
                            ? '99+'
                            : '${value.notifications}',
                        style: TextStyle(color: Colors.white),
                      ),
                      position: badges.BadgePosition.topEnd(top: 5, end: 10),
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        padding: EdgeInsets.all(12.w),
                        child: SvgPicture.asset(
                          "${action2}",
                          width: 24.w,
                          height: 24.h,
                        ),
                      ));
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
          title!,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Poppins1',
            color: textIconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: appModelTheme.darkTheme ? black : logoBlue,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
