import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "LOGGEDINKEY";
  static String displayNameKey = "USERNAMEKEY";
  
  // Shared Preferences is like a set of things we can save when the user closes out of the app

  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveDisplayName(String displayName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(displayNameKey, displayName);
  }

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getDisplayName() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(displayNameKey);
  }
}