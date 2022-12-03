import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/consts.dart';

class HelperFunctions {
  static String userIDKey = "USERIDKEY";
  static String displayNameKey = "USERNAMEKEY";

  static final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  static final List<String> daysShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  static final List<String> daysLong = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  
  // Shared Preferences is like a set of things we can save when the user closes out of the app

  static Future<bool> saveUserID(String id) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userIDKey, id);
  }
  static Future<String?> getUserID() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userIDKey);
  }
  

  static Future<bool> saveDisplayName(String displayName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(displayNameKey, displayName);
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
    DateTime now = DateTime.now();
    int daysOld = DateTime(now.year, now.month, now.day)
      .difference(DateTime(t.year, t.month, t.day)).inDays;

    // Add the year in if the message is from another year for clarity
    if(DateTime.now().year != t.year) {
      return "${daysShort[t.weekday - 1]}, ${months[t.month - 1]} ${t.day} ${t.year}, $hr:$min $ampm";
    }

    // Different format for timestamps > 6 days old, at least a day old, or today
    if(daysOld > 6) {
      return "${daysShort[t.weekday - 1]}, ${months[t.month - 1]} ${t.day}, $hr:$min $ampm";
    } else if(daysOld > 1) {
      return "${daysLong[t.weekday - 1]} $hr:$min $ampm";
    } else if(daysOld == 1) {
      return "Yesterday $hr:$min $ampm";
    } else {
      return "Today $hr:$min $ampm";
    }
  }

  static String abbreviate(String full) {
    List<String> split = full.split(' ');
    String a = "";
    for(int i = 0; i < split.length; i++) {
      String s = split[i];
      if(i == 2) { break; }
      if(s != "") { a += s[0].toUpperCase(); }
    }

    if(a == "") { a = "G"; }

    return a;
  }
}