import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/consts.dart';

class HelperFunctions {
  static String userLoggedInKey = "LOGGEDINKEY";
  static String displayNameKey = "USERNAMEKEY";

  static final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  static final List<String> daysShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  static final List<String> daysLong = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  
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

  static String timeStampToString(int ms) {
    DateTime t = Timestamp.fromMillisecondsSinceEpoch(ms).toDate();
    int hr = t.hour == 0 || t.hour == 12
      ? 12
      : t.hour % 12;
    String min = t.minute < 10
      ? "0${t.minute}"
      : t.minute.toString();
    String ampm = t.hour > 11 ? "PM" : "AM";
    int daysOld = DateTime.now().difference(t).inDays;

    // Add the year in if the message is from another year for clarity
    if(DateTime.now().year != t.year) {
      return "${daysShort[t.weekday - 1]}, ${months[t.month - 1]} ${t.day} ${t.year}, $hr:$min $ampm";
    }

    // Different format for timestamps > 6 days old, at least a day old, or today
    if(daysOld > 6) {
      return "${daysShort[t.weekday - 1]}, ${months[t.month - 1]} ${t.day}, $hr:$min $ampm";
    } else if(daysOld > 0) {
      return "${daysLong[t.weekday - 1]} $hr:$min $ampm";
    } else {
      return "Today $hr:$min $ampm";
    }

  }
}