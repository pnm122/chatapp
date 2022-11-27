import 'package:flutter/material.dart';

class Consts {
  // Firebase stuff
  static String apiKey = "AIzaSyDnNnbM881qDtuufNafKINmWyl2ds27aBE";
  static String projectId ="chatapp-ba297";
  static String messagingSenderId = "315668262849";
  static String appId = "1:315668262849:web:6c6b9594b6bb333bdb0940";

  static EdgeInsets messagePadding = const EdgeInsets.all(16.0);
  static EdgeInsets messageSurroundPadding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
  static EdgeInsets messageSenderPadding = const EdgeInsets.all(16.0);

  static const Color sentColor = Color.fromARGB(255, 109, 35, 230);
  static const Color receivedColor = Color.fromARGB(255, 224, 224, 224);
  static const Color senderColor = Color.fromARGB(255, 99, 99, 99);
  static const double messageRadius = 12.0;
}