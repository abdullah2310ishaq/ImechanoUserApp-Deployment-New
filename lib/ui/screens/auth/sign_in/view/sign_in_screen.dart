// ignore_for_file: unused_field, deprecated_member_use

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:imechano/localization/language_constrants.dart';
import 'package:imechano/ui/common/globals.dart';
import 'package:imechano/ui/modal/forget_password_model.dart';
import 'package:imechano/ui/modal/login_modal.dart';
import 'package:imechano/ui/modal/otp_verify_model.dart';
import 'package:imechano/ui/modal/reset_password_model.dart';
import 'package:imechano/ui/provider/theme_provider.dart';
import 'package:imechano/ui/repository/repository.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/share_preferences/pref_key.dart';
import 'package:imechano/ui/share_preferences/preference.dart';
import 'package:imechano/ui/shared/widgets/buttons/custom_button.dart';
import 'package:imechano/ui/shared/widgets/form/custom_form.dart';
import 'package:imechano/ui/shared/widgets/text_widgets.dart';
import 'package:imechano/ui/styling/colors.dart';
import 'package:imechano/ui/styling/global.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController mobilepassword = TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController EmailId = TextEditingController();
  TextEditingController OTP = TextEditingController();
  TextEditingController resetpassword = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final _repository = Repository();
  bool _obscureText = true;
  bool showPassword = true;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String fcmToken = '';
  late CountdownTimerController timerController;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
  @override
  void initState() {
    firebaseCloudMessaging_Listeners();
    super.initState();
    timerController = CountdownTimerController(endTime: endTime, onEnd: onEnd);
  }

  void onEnd() {
    print('onEnd');
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  void firebaseCloudMessaging_Listeners() async {
    // if (Platform.isIOS) iOS_Permission();

    await _firebaseMessaging.getToken().then((token) {
      print(token);
      fcmToken = token!;
    });
  }

  dynamic appModelTheme;
  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    appModelTheme = appModel;
    return Scaffold(
        body: ScreenUtilInit(
      designSize: Size(414, 896),
      builder: (context, child) =>
          NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700),
              child: Container(
                height: 1.sh,
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 0.1.sh),
                    Image.asset(
                      "assets/icons/splash/logo.png",
                      height: 0.11.sh,
                      color: appModelTheme.darkTheme ? white : null,
                    ),
                    SizedBox(height: 35.h),
                    Text(
                      getTranslated("loginaccount", context),
                      style: TextStyle(
                          fontFamily: "poppins2",
                          fontSize: 21.sp,
                          color: logoBlue),
                    ),
                    Text(
                      getTranslated("withyourphonenumber", context),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "Poppins3",
                      ),
                    ),
                    SizedBox(height: 35.h),
                    CustomForm(
                      fillColor:
                          appModelTheme.darkTheme ? darkmodeColor : grayE6E6E5,
                      validationform: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Fil The Mobile No';
                        }
                        return null;
                      },
                      controller: phoneController,
                      imagePath: 'assets/icons/auth/sign_up/mobile-number.png',
                      hintText: getTranslated('mobileno.orEmail', context),
                    ),
                    SizedBox(height: 16.h),
                    _textfiled(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              showMaterialModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(40),
                                        topRight: Radius.circular(40))),
                                context: context,
                                builder: (context) => Form(
                                  key: _formKey1,
                                  child: NotificationListener<
                                      OverscrollIndicatorNotification>(
                                    onNotification: (notification) {
                                      notification.disallowIndicator();
                                      return true;
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 25.w, right: 25.w, top: 5.h),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                      child: Padding(
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 30.h,
                                              ),
                                              Text(
                                                "Forgot Password",
                                                style: TextStyle(
                                                    fontFamily: "Poppins3",
                                                    fontSize: 26.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        appModelTheme.darkTheme
                                                            ? logoBlue
                                                            : logoBlue),
                                              ),
                                              SizedBox(height: 10.h),
                                              Text(
                                                "ENTER YOUR REGISTERED email FOR THE \n VERIFICATION PROCESS, WE WILL SEND \n  4 DIGITS CODE TO YOUR EMAIL.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontFamily: "Poppins3",
                                                    fontSize: 13.sp),
                                              ),
                                              SizedBox(height: 35.h),
                                              CustomForm(
                                                fillColor:
                                                    appModelTheme.darkTheme
                                                        ? darkmodeColor
                                                        : grayE6E6E5,
                                                validationform: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter Fil The Email Id';
                                                  }
                                                  return null;
                                                },
                                                controller: EmailId,
                                                imagePath:
                                                    'assets/icons/auth/sign_up/email.png',
                                                hintText: 'Email Id',
                                              ),
                                              SizedBox(height: 15.h),
                                              Row(children: <Widget>[
                                                Expanded(
                                                  child: new Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 10.0,
                                                              right: 15.0),
                                                      child: Divider(
                                                        color: appModelTheme
                                                                .darkTheme
                                                            ? white
                                                            : Color(0xffBFBFBF),
                                                        height: 36.h,
                                                      )),
                                                ),
                                                Text(
                                                  "OR",
                                                  style: TextStyle(
                                                      color: Color(0xffBFBFBF)),
                                                ),
                                                Expanded(
                                                  child: new Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 20.0,
                                                              right: 10.0),
                                                      child: Divider(
                                                        color: appModelTheme
                                                                .darkTheme
                                                            ? white
                                                            : Color(0xffBFBFBF),
                                                        height: 36.h,
                                                      )),
                                                ),
                                              ]),
                                              SizedBox(height: 15.h),
                                              CustomForm(
                                                fillColor:
                                                    appModelTheme.darkTheme
                                                        ? darkmodeColor
                                                        : grayE6E6E5,
                                                validationform: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter Fil The Mobile Password';
                                                  }
                                                  return null;
                                                },
                                                controller: mobilepassword,
                                                imagePath:
                                                    'assets/icons/auth/sign_up/mobile-number.png',
                                                hintText: 'Mobile Password',
                                              ),
                                              SizedBox(
                                                height: 80.h,
                                              ),
                                              CustomButton(
                                                title:
                                                    Regular20White('Continue'),
                                                width: 0.9.sw,
                                                bgColor: logoBlue,
                                                borderColor: logoBlue,
                                                callBackFunction: () {
                                                  if (EmailId.text.isEmpty &&
                                                      mobilepassword
                                                          .text.isEmpty) {
                                                    if (_formKey1.currentState!
                                                        .validate()) {}
                                                  } else {
                                                    // Navigator.pop(context);
                                                    // _showmodelbottom();
                                                    onforgetpasswordAPI();
                                                  }
                                                },
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              Text(
                                                  "OTP sent on the fields which you have selected",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins1",
                                                    color: red,
                                                    fontSize: 10.sp,
                                                  )),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                            ],
                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                                getTranslated('ForgotPassword', context) + "  ",
                                style: TextStyle(
                                    fontFamily: 'poppins1',
                                    color: appModelTheme.darkTheme
                                        ? logoBlue
                                        : red)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomButton(
                      title: Text(
                        getTranslated('signin', context),
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: "Poppins1",
                            color: Colors.white),
                      ),
                      width: 0.9,
                      bgColor: logoBlue,
                      borderColor: logoBlue,
                      callBackFunction: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            appModelTheme.checkCon = false;
                          });
                          validatePassword(password.text);
                          onLoginAPI();
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      title: Text(
                        getTranslated('guest', context),
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: "Poppins1",
                            color: Colors.white),
                      ),
                      width: 0.9,
                      bgColor: logoBlue,
                      borderColor: logoBlue,
                      callBackFunction: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return BottomBarPage(2);
                          },
                        ));
                        // if (_formKey.currentState!.validate()) {
                        // setState(() {
                        //   appModelTheme.checkCon = false;
                        // });
                        // validatePassword(password.text);

                        // onLoginAPI();
                        // }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(getTranslated('donthaveaccount', context) + " ?",
                            style: TextStyle(
                                fontFamily: 'poppins1',
                                fontSize: 13.sp,
                                color:
                                    appModelTheme.darkTheme ? white : black)),
                        TextButton(
                            onPressed: () {
                              Get.toNamed('/sign-up');
                            },
                            child: Text(getTranslated('Signup', context),
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontFamily: 'poppins1',
                                    color: appModelTheme.darkTheme
                                        ? logoBlue
                                        : red)))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }

  Widget _textfiled() {
    return Container(
      child: TextFormField(
        style: TextStyle(fontFamily: "Poppins3", color: Colors.white),
        validator: validatePassword,
        controller: password,
        obscureText: showPassword,
        decoration: InputDecoration(
          fillColor: appModelTheme.darkTheme ? darkmodeColor : grayE6E6E5,
          filled: true,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          prefixIcon:
              Image.asset('assets/icons/auth/sign_up/create-password.png'),
          hintText: getTranslated('password', context),
          hintStyle: TextStyle(fontFamily: "Poppins3", color: black),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
            icon: Icon(
              showPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Future _showmodelbottom() {
    return showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      context: context,
      builder: (context) => Form(
        key: _formKey2,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowIndicator();
            return true;
          },
          child: Container(
            margin: EdgeInsets.only(left: 25.w, right: 25.w),
            height: 0.6.sh,
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    Text("Enter 4 Digits Code",
                        style: TextStyle(
                            fontFamily: "Poppins3",
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: logoBlue)),
                    SizedBox(height: 20.h),
                    Column(
                      children: [
                        Text(
                            "Enter 4 digits code that you received\non your mail",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Poppins1",
                              fontSize: 14.sp,
                            )),
                        SizedBox(
                          height: 30.h,
                        ),
                        OtpTextField(
                          numberOfFields: 4,
                          borderColor: Color(0xFF512DA8),
                          //set to true to show as box or false to show as dash
                          showFieldAsBox: true,
                          //runs when a code is typed in
                          onCodeChanged: (String code) {
                            //handle validation or checks here
                          },
                          autoFocus: false,
                          //runs when every textfield is filled
                          onSubmit: (String verificationCode) {
                            if (_formKey2.currentState!.validate()) {
                              // Navigator.pop(context);
                              onotpAPI(verificationCode);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Enter Code",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          }, // end onSubmit
                        ),
                        SizedBox(
                          height: 45.h,
                        ),
                        // CustomButton(
                        //   title: Text(
                        //     'Continue',
                        //     style:
                        //         TextStyle(fontSize: 18, fontFamily: 'Poppins1'),
                        //   ),
                        //   width: 0.9,
                        //   bgColor: logoBlue,
                        //   borderColor: logoBlue,
                        //   callBackFunction: () {
                        //     if (_formKey2.currentState!.validate()) {
                        //       // Navigator.pop(context);
                        //       onotpAPI(OtpTextField.text);
                        //     }else{
                        //       Fluttertoast.showToast(
                        //           msg: "Enter Code",
                        //           toastLength: Toast.LENGTH_SHORT,
                        //           gravity: ToastGravity.CENTER,
                        //           timeInSecForIosWeb: 3,
                        //           backgroundColor: Colors.red,
                        //           textColor: Colors.white,
                        //           fontSize: 16.0
                        //       );
                        //     }
                        //   },
                        // ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "I don't receive code.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Poppins1",
                                  height: 1.8,
                                  fontSize: 14.sp),
                            ),
                            TextButton(
                              onPressed: () {
                                timerController.disposeTimer();
                                Navigator.pop(context);
                                onforgetpasswordAPI();
                              },
                              child: Text(
                                "Resend Code",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Poppins1",
                                    color: Colors.red,
                                    height: 1.8,
                                    fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                        CountdownTimer(
                          endTime: DateTime.now().millisecondsSinceEpoch +
                              1000 * 120,
                          widgetBuilder: (BuildContext context,
                              CurrentRemainingTime? time) {
                            if (time == null) {
                              return Text('OTP Expired!');
                            }
                            if (time.min != null && time.sec! < 10) {
                              return Text('01:0${time.sec} sec left');
                            }
                            if (time.min == null && time.sec! > 9) {
                              return Text('00:${time.sec} sec left');
                            }
                            if (time.min == null && time.sec! < 10) {
                              return Text('00:0${time.sec} sec left');
                            }
                            return Text('0${time.min}:${time.sec} sec left');
                          },
                          textStyle: TextStyle(
                              fontFamily: "Poppins1",
                              height: 1.6,
                              fontSize: 14),
                        ),
                        // SizedBox(
                        //   height: 23.h,
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _showmodelbottom1() {
    return showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      context: context,
      builder: (context) => Form(
        key: _formKey3,
        child: Container(
          margin: EdgeInsets.only(left: 25, right: 25),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text("Reset Password",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: logoBlue)),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Column(
                    children: [
                      Text(
                        "Set the new password for your account \n so you can login and access \n all the features",
                        style: TextStyle(fontFamily: "Poppins3", fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      CustomForm(
                        fillColor: appModelTheme.darkTheme
                            ? darkmodeColor
                            : grayE6E6E5,
                        validationform: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Fil The Password';
                          }
                          return null;
                        },
                        controller: resetpassword,
                        imagePath:
                            'assets/icons/auth/sign_up/create-password.png',
                        hintText: 'Password',
                        isSuffix: true,
                        icon: Icons.visibility,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      CustomForm(
                        fillColor: appModelTheme.darkTheme
                            ? darkmodeColor
                            : grayE6E6E5,
                        validationform: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Fil The Confirm Password';
                          }
                          return null;
                        },
                        controller: confirmpassword,
                        ObscureText: true,
                        imagePath:
                            'assets/icons/auth/sign_up/create-password.png',
                        hintText: 'Confirm Password',
                        isSuffix: true,
                        icon: Icons.visibility_off,
                      ),
                      SizedBox(
                        height: 45.h,
                      ),
                      CustomButton(
                        title: Regular20White('Reset Password'),
                        width: 0.9,
                        bgColor: logoBlue,
                        borderColor: logoBlue,
                        callBackFunction: () {
                          if (_formKey3.currentState!.validate()) {
                            onresetAPI();
                          }
                        },
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validatePassword(String? value) {
    // Pattern pattern =
    //     r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    // RegExp regex = new RegExp(pattern);
    print(value);
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    return null;
  }

  dynamic onresetAPI() async {
    // show loader
    Loader().showLoader(context);
    final ResetPasswordModel isreset = await _repository.onreset(
        EmailId.text, mobilepassword.text, resetpassword.text);

    if (isreset.code != '0') {
      FocusScope.of(context).requestFocus(FocusNode());
      PrefObj.preferences!.put(PrefKeys.USER_DATA, json.encode(isreset.data));
      Loader().hideLoader(context);
      //snackBar('forget Success!!');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
          ));
      // _showmodelbottom1();
    } else {
      Loader().hideLoader(context);
      showpopDialog(
          context, 'Error', isreset.message != null ? isreset.message! : '');
    }
  }

  dynamic onotpAPI(String verificationCode) async {
    print("onOTPApi called");
    print("verificationCode");
    print(verificationCode);
    print("EmailId.text");
    print(EmailId.text);
    // show loader
    Loader().showLoader(context);
    final OtpVerifyModel isotp =
        await _repository.onotpAPI(EmailId.text, verificationCode, "1");
    print("isotp.code");
    print(isotp.code);
    if (isotp.code == '1') {
      FocusScope.of(context).requestFocus(FocusNode());
      PrefObj.preferences!.put(PrefKeys.USER_DATA, json.encode(isotp.code));
      Loader().hideLoader(context);
      snackBar(isotp.message.toString());
      Fluttertoast.showToast(
          msg: isotp.message.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      _showmodelbottom1();
    } else {
      Loader().hideLoader(context);
      showpopDialog(
          context, 'Error', isotp.message != null ? isotp.message! : '');
    }
  }

  dynamic onforgetpasswordAPI() async {
    print("onforgetpasswordAPI called");
    // show loader
    Loader().showLoader(context);
    final ForgetPasswordModel isforget =
        await _repository.onforget(EmailId.text, mobilepassword.text);
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    print("isforget.code");
    print(isforget.code);
    print(isforget.message);
    if (isforget.code == '1') {
      FocusScope.of(context).requestFocus(FocusNode());
      PrefObj.preferences!.put(PrefKeys.USER_DATA, json.encode(isforget.code));
      Loader().hideLoader(context);
      snackBar(isforget.message.toString());
      Fluttertoast.showToast(
          msg: isforget.message.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      _showmodelbottom();
    } else {
      Loader().hideLoader(context);
      showpopDialog(
          context, 'Error', isforget.message != null ? isforget.message! : '');
    }
  }

  dynamic onLoginAPI() async {
    // show loader
    Loader().showLoader(context);
    try {
      LoginModal isLogin = await _repository.onLogin(
          phoneController.text, password.text, fcmToken);

      if (isLogin.code != '0') {
        FocusScope.of(context).requestFocus(FocusNode());
        PrefObj.preferences!.put(PrefKeys.USER_DATA, json.encode(isLogin.data));
        PrefObj.preferences!
            .put(PrefKeys.PROFILE_DATA, json.encode(isLogin.data));
        PrefObj.preferences!.put(PrefKeys.USER_ID, isLogin.data!.id);
        PrefObj.preferences!.put(PrefKeys.APPSTARTED, true);
        var prefs = await SharedPreferences.getInstance();

        if (prefs.getString('language_code') == "en") {
          changeLocale(isLogin.data!.id!, "en");
        } else if (prefs.getString('language_code') == "ar") {
          changeLocale(isLogin.data!.id!, "ar");
        }

        Loader().hideLoader(context);
        snackBar('Login Success!!');

        // Check for account deletion status
        _checkAccountDeletionStatus(isLogin.data!.id!);

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BottomBarPage(2),
        //   ),
        // );

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BottomBarPage(2)),
            (Route<dynamic> route) => false);

        // bool checkConditionDrawer = false;
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BottomBarPage(checkConditionDrawer),
        //   ),
        // );
      } else {
        Loader().hideLoader(context);
        showpopDialog(
            context, 'Error', isLogin.message != null ? isLogin.message! : '');
      }
    } catch (e) {
      Loader().hideLoader(context);
    }
  }

  void showpopDialog(BuildContext context, String title, String body) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(
      String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _checkAccountDeletionStatus(String userId) {
    // Check if account deletion was requested
    bool isDeletionRequested =
        PrefObj.preferences!.containsKey(PrefKeys.ACCOUNT_DELETION_REQUESTED);

    if (!isDeletionRequested) {
      // No deletion requested, proceed normally
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => BottomBarPage(2)),
          (Route<dynamic> route) => false);
      return;
    }

    // Account deletion was requested, check if it's overdue
    if (!PrefObj.preferences!.containsKey(PrefKeys.ACCOUNT_DELETION_DATE)) {
      // No deletion date set, clear the flag and proceed
      PrefObj.preferences!.delete(PrefKeys.ACCOUNT_DELETION_REQUESTED);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => BottomBarPage(2)),
          (Route<dynamic> route) => false);
      return;
    }

    int deletionTimestamp =
        PrefObj.preferences!.get(PrefKeys.ACCOUNT_DELETION_DATE);
    DateTime deletionDate =
        DateTime.fromMillisecondsSinceEpoch(deletionTimestamp);
    DateTime now = DateTime.now();

    if (now.isAfter(deletionDate)) {
      // Account should be deleted
      PrefObj.preferences!.put(PrefKeys.ACCOUNT_DELETED, true);
      _showAccountDeletedDialog();
    } else {
      // Account deletion is pending but not yet due - show option to cancel
      _showAccountDeletionPendingDialog(deletionDate);
    }
  }

  void _showAccountDeletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                Icon(Icons.delete_forever, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text(
                  "Account Deleted",
                  style: TextStyle(fontFamily: "Poppins2", color: Colors.red),
                ),
              ],
            ),
          ),
          content: Text(
            "This account has been permanently deleted. Please create a new account to continue using the app.",
            style: TextStyle(fontSize: 14, fontFamily: "Poppins1"),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text(
                  "Create New Account",
                  style: TextStyle(color: logoBlue, fontFamily: "Poppins1"),
                ),
                onPressed: () {
                  // Clear all data and go to sign-up
                  PrefObj.preferences?.clear();
                  PrefObj.preferences?.put(PrefKeys.APPSTARTED, true);
                  Navigator.of(context).pop();
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

  void _showAccountDeletionPendingDialog(DateTime deletionDate) {
    int daysLeft = deletionDate.difference(DateTime.now()).inDays;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Column(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 50),
                SizedBox(height: 10),
                Text(
                  "Account Deletion Pending",
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
                    ? "Your account is scheduled for deletion in $daysLeft days."
                    : "Your account deletion is overdue.",
                style: TextStyle(fontSize: 14, fontFamily: "Poppins1"),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                "Deletion Date: ${deletionDate.day}/${deletionDate.month}/${deletionDate.year}",
                style: TextStyle(
                    fontSize: 12, fontFamily: "Poppins1", color: Colors.grey),
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
                    // Cancel account deletion
                    PrefObj.preferences!
                        .delete(PrefKeys.ACCOUNT_DELETION_REQUESTED);
                    PrefObj.preferences!.delete(PrefKeys.ACCOUNT_DELETION_DATE);

                    Navigator.of(context).pop();

                    // Show success message
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Center(
                            child: Column(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 50),
                                SizedBox(height: 10),
                                Text(
                                  "Deletion Cancelled",
                                  style: TextStyle(
                                      fontFamily: "Poppins2",
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          content: Text(
                            "Your account deletion has been cancelled. Welcome back!",
                            style:
                                TextStyle(fontSize: 14, fontFamily: "Poppins1"),
                            textAlign: TextAlign.center,
                          ),
                          actions: <Widget>[
                            Center(
                              child: TextButton(
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                      color: logoBlue, fontFamily: "Poppins1"),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomBarPage(2)),
                                      (Route<dynamic> route) => false);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                TextButton(
                  child: Text(
                    "Continue",
                    style: TextStyle(color: logoBlue, fontFamily: "Poppins1"),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => BottomBarPage(2)),
                        (Route<dynamic> route) => false);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class CustomProvider extends ChangeNotifier {
  final text = TextEditingController();
  bool validate = false;

  void checkValidation() {
    if (text.text.isEmpty) {
      validate = true;
    } else {
      validate = false;
    }
    notifyListeners();
  }
}
