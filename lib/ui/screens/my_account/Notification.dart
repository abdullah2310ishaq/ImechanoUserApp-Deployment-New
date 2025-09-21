// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:imechano/api/notification_api.dart';
import 'package:imechano/localization/language_constrants.dart';
import 'package:imechano/ui/bloc/customer_notification_list_bloc.dart';
import 'package:imechano/ui/modal/customer_notification_list_model.dart';
import 'package:imechano/ui/provider/theme_provider.dart';

import 'package:imechano/ui/shared/widgets/appbar/custom_appbar_widget.dart';
import 'package:imechano/ui/shared/widgets/appbar/custom_drawer_widget.dart';
import 'package:imechano/ui/shared/widgets/confirmation_dialog.dart';

import 'package:imechano/ui/styling/colors.dart';
import 'package:imechano/ui/styling/global.dart';
import 'package:imechano/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/notification_count_provider.dart';
import '../../share_preferences/pref_key.dart';
import '../../share_preferences/preference.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isSwitch = true;
  dynamic appModelTheme;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print("Notification page");
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await Provider.of<NotificationCountProvider>(context, listen: false)
          .setNotifications();
      if (PrefObj.preferences!.containsKey(PrefKeys.USER_ID)) {
        await customerNotificationListBloc
            .notificationListSinck(PrefObj.preferences!.get(PrefKeys.USER_ID));
      }
    } catch (e) {
      log('Error loading notifications: $e');
      setState(() {
        errorMessage = 'Failed to load notifications';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    appModelTheme = appModel;
    return Scaffold(
        appBar: WidgetAppBar(
          title: getTranslated('notification', context),
          menuItem: 'assets/svg/Menu.svg',
          imageicon: 'assets/svg/Arrow_alt_left.svg',
          action: 'assets/svg/shopping-cart.svg',
          home: 'assets/svg/homeicon.svg',
        ),
        drawer: drawerpage(),
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
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      color: appModelTheme.darkTheme
                          ? Color(0xff252525)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25.0),
                          topLeft: Radius.circular(25.0))),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 15.h),
                        notificationSwitch(),
                        SizedBox(height: 5.h),
                        StreamBuilder<CustomerNotificationListModel>(
                            stream: customerNotificationListBloc
                                .notificationListStream,
                            builder: (context,
                                AsyncSnapshot<CustomerNotificationListModel>
                                    notificationListSnapshot) {
                              if (isLoading) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(logoBlue),
                                  ),
                                );
                              }

                              if (errorMessage != null) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 50,
                                        color: red,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        errorMessage!,
                                        style: TextStyle(
                                          color: appModelTheme.darkTheme
                                              ? white
                                              : black,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadNotifications,
                                        child: Text('Retry'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: logoBlue,
                                          foregroundColor: white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (notificationListSnapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 50,
                                        color: red,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Error loading notifications',
                                        style: TextStyle(
                                          color: appModelTheme.darkTheme
                                              ? white
                                              : black,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadNotifications,
                                        child: Text('Retry'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: logoBlue,
                                          foregroundColor: white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (!notificationListSnapshot.hasData ||
                                  notificationListSnapshot.data!.data == null ||
                                  notificationListSnapshot
                                      .data!.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.notifications_none,
                                        size: 50,
                                        color: appModelTheme.darkTheme
                                            ? greycolo
                                            : Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No notifications yet',
                                        style: TextStyle(
                                          color: appModelTheme.darkTheme
                                              ? white
                                              : black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return ListView.separated(
                                scrollDirection: Axis.vertical,
                                physics: BouncingScrollPhysics(),
                                itemCount:
                                    notificationListSnapshot.data!.data!.length,
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color: appModelTheme.darkTheme
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                                    height: 1,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: appModelTheme.darkTheme
                                        ? (notificationListSnapshot.data!
                                                    .data![index].status ==
                                                '1'
                                            ? Color(0xff2a2a2a)
                                            : Color(0xff1e1e1e))
                                        : (notificationListSnapshot.data!
                                                    .data![index].status ==
                                                '1'
                                            ? grayE6E6E5
                                            : greycolo.withOpacity(0.5)),
                                    child: ListTile(
                                      isThreeLine: true,
                                      onTap: () async {
                                        try {
                                          if (notificationListSnapshot
                                                  .data!.data![index].status ==
                                              '0') {
                                            bool response =
                                                await NotificationApi
                                                    .updateNotificationStatus(
                                                        notificationListSnapshot
                                                            .data!
                                                            .data![index]);
                                            log('Notification status updated: $response');
                                          }

                                          String? str = notificationListSnapshot
                                              .data!.data![index].title!;
                                          String? jobNo =
                                              notificationListSnapshot
                                                  .data!.data![index].jobNo;
                                          Utils.handleNotificationNavigation(
                                              context, null, str, jobNo);
                                        } catch (e) {
                                          log('Error handling notification tap: $e');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('Error occurred'),
                                              backgroundColor: red,
                                            ),
                                          );
                                        }
                                      },
                                      title: Row(
                                        children: [
                                          Text(
                                            getTranslated(
                                                notificationListSnapshot
                                                    .data!
                                                    .data![index]
                                                    .title!
                                                    .removeAllWhitespace,
                                                context),
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'Poppins3',
                                                color: appModelTheme.darkTheme
                                                    ? white
                                                    : black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Flexible(
                                              fit: FlexFit.tight,
                                              child: SizedBox()),
                                          Text(
                                            DateFormat('hh:mm a dd-MM-yy')
                                                .format(DateTime.parse(
                                                    notificationListSnapshot
                                                        .data!
                                                        .data![index]
                                                        .updatedAt!)),
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontFamily: 'Poppins3',
                                                color: appModelTheme.darkTheme
                                                    ? Colors.grey[300]
                                                    : Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        getTranslated(
                                            notificationListSnapshot
                                                .data!
                                                .data![index]
                                                .message!
                                                .removeAllWhitespace,
                                            context),
                                        style: TextStyle(
                                          color: appModelTheme.darkTheme
                                              ? Colors.grey[200]
                                              : Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                      leading: Image(
                                          height: 10,
                                          image: notificationListSnapshot.data!
                                                      .data![index].status ==
                                                  '1'
                                              ? AssetImage(
                                                  "assets/icons/My Account/Ellipse 27.png")
                                              : AssetImage(
                                                  "assets/icons/My Account/Ellipse 27-1.png")),
                                    ),
                                  );
                                },
                              );
                            }),
                      ],
                    ),
                  ),
                )),
              ]),
            ),
          ),
        ));
  }

  Widget notificationSwitch() {
    return Row(
      children: [
        Container(
          height: 20.h,
          child: Image(
            height: 25.h,
            image: AssetImage(
                "assets/icons/My Account/notifications_black_24dp.png"),
          ),
          margin: EdgeInsets.only(left: 20.w, right: 20.w),
        ),
        Expanded(
          child: Text(
            getTranslated("notification", context),
            style: TextStyle(
              fontSize: 17.sp,
              color: appModelTheme.darkTheme ? white : black,
            ),
          ),
        ),
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return ConfirmationDialog(
                        message: 'delete all notifications?',
                        onYesPressed: () async {
                          try {
                            Loader().showLoader(context);
                            bool response =
                                await NotificationApi.deleteAllNotifications();
                            if (response) {
                              await Provider.of<NotificationCountProvider>(
                                      context,
                                      listen: false)
                                  .setNotifications();
                              if (PrefObj.preferences!
                                  .containsKey(PrefKeys.USER_ID)) {
                                await customerNotificationListBloc
                                    .notificationListSinck(PrefObj.preferences!
                                        .get(PrefKeys.USER_ID));
                                setState(() {});
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Notifications deleted successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to delete notifications'),
                                  backgroundColor: red,
                                ),
                              );
                            }
                          } catch (e) {
                            log('Error deleting notifications: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error occurred'),
                                backgroundColor: red,
                              ),
                            );
                          } finally {
                            Loader().hideLoader(context);
                            Navigator.pop(context);
                          }
                        });
                  });
            },
            icon: Icon(Icons.delete, color: red)),
        Switch(
          activeColor: logoBlue,
          activeTrackColor: logoBlue.withOpacity(0.3),
          inactiveThumbColor:
              appModelTheme.darkTheme ? greycolo : Colors.grey[400],
          inactiveTrackColor: appModelTheme.darkTheme
              ? greycolo.withOpacity(0.3)
              : Colors.grey[300],
          value: isSwitch,
          onChanged: (value) {
            setState(() {
              isSwitch = value;
            });
          },
        )
      ],
    );
  }
}
