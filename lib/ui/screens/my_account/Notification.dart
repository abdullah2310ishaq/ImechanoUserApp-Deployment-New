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
  AppModel? appModelTheme;
  bool isLoading = false;
  String? errorMessage;
  bool _isDisposed = false;

  DateTime _parseToLocal(String? raw) {
    try {
      if (raw == null) return DateTime.now();
      final trimmed = raw.trim();
      // Epoch seconds or milliseconds
      final isNumeric = RegExp(r'^\d{10,13}$').hasMatch(trimmed);
      if (isNumeric) {
        final intVal = int.tryParse(trimmed) ?? 0;
        // Heuristic: 13 digits = ms, 10 = s
        final millis = trimmed.length >= 13 ? intVal : intVal * 1000;
        return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true)
            .toLocal();
      }
      // ISO-8601
      return DateTime.parse(trimmed).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  void initState() {
    super.initState();
    log("Notification page");
    _loadNotifications();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (_isDisposed) return;

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      await Provider.of<NotificationCountProvider>(context, listen: false)
          .setNotifications();

      if (PrefObj.preferences?.containsKey(PrefKeys.USER_ID) == true) {
        final userId = PrefObj.preferences!.get(PrefKeys.USER_ID);
        if (userId != null) {
          await customerNotificationListBloc.notificationListSinck(userId);
        }
      }
    } catch (e) {
      log('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load notifications. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
        backgroundColor:
            appModelTheme?.darkTheme == true ? black : const Color(0xff70bdf1),
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
                      color: appModelTheme?.darkTheme == true
                          ? const Color(0xff252525)
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
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
                                      const SizedBox(height: 16),
                                      Text(
                                        errorMessage!,
                                        style: TextStyle(
                                          color:
                                              appModelTheme?.darkTheme == true
                                                  ? white
                                                  : black,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadNotifications,
                                        child: const Text('Retry'),
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
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error loading notifications',
                                        style: TextStyle(
                                          color:
                                              appModelTheme?.darkTheme == true
                                                  ? white
                                                  : black,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadNotifications,
                                        child: const Text('Retry'),
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
                                  notificationListSnapshot.data?.data == null ||
                                  notificationListSnapshot
                                      .data!.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.notifications_none,
                                        size: 50,
                                        color: appModelTheme?.darkTheme == true
                                            ? greycolo
                                            : Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No notifications yet',
                                        style: TextStyle(
                                          color:
                                              appModelTheme?.darkTheme == true
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
                                physics: const BouncingScrollPhysics(),
                                itemCount:
                                    notificationListSnapshot.data!.data!.length,
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color: appModelTheme?.darkTheme == true
                                        ? Colors.grey[700]
                                        : Colors.grey[400],
                                    thickness: 1.0,
                                    height: 1.0,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  final notification = notificationListSnapshot
                                      .data!.data![index];
                                  final isRead = notification.status == '1';

                                  return Container(
                                    color: appModelTheme?.darkTheme == true
                                        ? (isRead
                                            ? const Color(0xff1e1e1e)
                                            : const Color(0xff2a2a2a))
                                        : (isRead
                                            ? Colors.white
                                            : const Color(0xFFE6E6E5)),
                                    child: ListTile(
                                      isThreeLine: true,
                                      onTap: () async {
                                        try {
                                          if (!isRead) {
                                            bool response =
                                                await NotificationApi
                                                    .updateNotificationStatus(
                                                        notification);
                                            log('Notification status updated: $response');
                                          }

                                          final title = notification.title;
                                          final jobNo = notification.jobNo;
                                          Utils.handleNotificationNavigation(
                                              context, null, title, jobNo);
                                        } catch (e) {
                                          log('Error handling notification tap: $e');
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Error occurred'),
                                                backgroundColor: red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              getTranslated(
                                                  notification.title ?? '',
                                                  context),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontFamily: 'Poppins3',
                                                  color: appModelTheme
                                                              ?.darkTheme ==
                                                          true
                                                      ? white
                                                      : black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(
                                            DateFormat('hh:mm a dd-MM-yy')
                                                .format(_parseToLocal(
                                                    notification.updatedAt)),
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontFamily: 'Poppins3',
                                                color:
                                                    appModelTheme?.darkTheme ==
                                                            true
                                                        ? Colors.grey[300]
                                                        : Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        getTranslated(
                                            notification.message ?? '',
                                            context),
                                        style: TextStyle(
                                          color:
                                              appModelTheme?.darkTheme == true
                                                  ? Colors.grey[200]
                                                  : Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                      leading: Image(
                                          height: 10,
                                          image: isRead
                                              ? const AssetImage(
                                                  "assets/icons/My Account/Ellipse 27.png")
                                              : const AssetImage(
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
            image: const AssetImage(
                "assets/icons/My Account/notifications_black_24dp.png"),
          ),
          margin: EdgeInsets.only(left: 20.w, right: 20.w),
        ),
        Expanded(
          child: Text(
            getTranslated("notification", context),
            style: TextStyle(
              fontSize: 17.sp,
              color: appModelTheme?.darkTheme == true ? white : black,
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
                              if (PrefObj.preferences
                                      ?.containsKey(PrefKeys.USER_ID) ==
                                  true) {
                                final userId =
                                    PrefObj.preferences!.get(PrefKeys.USER_ID);
                                if (userId != null) {
                                  await customerNotificationListBloc
                                      .notificationListSinck(userId);
                                  if (mounted) {
                                    setState(() {});
                                  }
                                }
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Notifications deleted successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Failed to delete notifications'),
                                    backgroundColor: red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            log('Error deleting notifications: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error occurred'),
                                  backgroundColor: red,
                                ),
                              );
                            }
                          } finally {
                            Loader().hideLoader(context);
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        });
                  });
            },
            icon: Icon(Icons.delete, color: red)),
        Switch(
          activeColor: logoBlue,
          activeTrackColor: logoBlue.withOpacity(0.3),
          inactiveThumbColor:
              appModelTheme?.darkTheme == true ? greycolo : Colors.grey[400],
          inactiveTrackColor: appModelTheme?.darkTheme == true
              ? greycolo.withOpacity(0.3)
              : Colors.grey[300],
          value: isSwitch,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                isSwitch = value;
              });
            }
          },
        )
      ],
    );
  }
}
