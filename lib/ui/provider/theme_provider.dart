import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imechano/ui/common/globals.dart';
import 'package:imechano/ui/share_preferences/preference.dart';
import 'package:imechano/ui/share_preferences/pref_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppModel extends ChangeNotifier {
  AppPreference appPreference = AppPreference();
  bool checkCon = false;
  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    appPreference.setThemePref(value);
    notifyListeners();
  }

  Locale _appLocale = Locale('en');

  Locale get appLocal => _appLocale;

  // Initialize theme and language from preferences
  void initializeApp() async {
    await fetchLocale();
    await fetchTheme();
  }

  // Fetch theme from SharedPreferences
  fetchTheme() async {
    _darkTheme = await appPreference.getTheme();
    notifyListeners();
  }

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();

    // Check both SharedPreferences and Hive for language preference
    String? langCode = prefs.getString('language_code');
    if (langCode == null && PrefObj.preferences != null) {
      langCode = PrefObj.preferences!.get(PrefKeys.LANGUAGE_CODE);
    }

    if (langCode == "ar") {
      _appLocale = Locale('ar');
      langSwitch = true;
    } else {
      _appLocale = Locale('en');
      langSwitch = false;
    }
    notifyListeners();
  }

  void changeLanguage(Locale type) async {
    print("My Language is ");
    log(_appLocale.toString());
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      print("GOOD");
      return;
    }
    if (type == Locale("ar")) {
      print("good");
      _appLocale = Locale("ar");
      await prefs.setString('language_code', 'ar');
      await prefs.setString('countryCode', '');
      // Also save to Hive for consistency
      if (PrefObj.preferences != null) {
        PrefObj.preferences!.put(PrefKeys.LANGUAGE_CODE, 'ar');
      }
      langSwitch = true;
    } else {
      _appLocale = Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
      // Also save to Hive for consistency
      if (PrefObj.preferences != null) {
        PrefObj.preferences!.put(PrefKeys.LANGUAGE_CODE, 'en');
      }
      langSwitch = false;
    }

    log("Language changed: $appLocal");
    log(prefs.getString('language_code')!);
    Get.updateLocale(appLocal);

    notifyListeners();
  }
}
