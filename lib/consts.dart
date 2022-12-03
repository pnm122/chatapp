import 'package:flutter/material.dart';

class Consts {
  // Firebase stuff
  static String apiKey = "AIzaSyDnNnbM881qDtuufNafKINmWyl2ds27aBE";
  static String projectId ="chatapp-ba297";
  static String messagingSenderId = "315668262849";
  static String appId = "1:315668262849:web:6c6b9594b6bb333bdb0940";

  static const double sideMargin = 16.0;

  static EdgeInsets messagePadding = const EdgeInsets.all(16.0);
  static EdgeInsets messageSurroundPadding = const EdgeInsets.symmetric(horizontal: sideMargin, vertical: 32.0);
  static EdgeInsets messageSenderPadding = const EdgeInsets.all(16.0);
  static EdgeInsets innerSenderPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);

  static EdgeInsets groupSectionPadding = const EdgeInsets.all(16.0);

  static const Color sentColor = Color.fromARGB(255, 203, 67, 33);
  static const Color receivedColor = Color.fromARGB(255, 224, 224, 224);
  static const Color senderColor = Color.fromARGB(255, 99, 99, 99);
  static const Radius messageRadius = Radius.circular(18);

  static const Color inputBackgroundColor = Color.fromARGB(20, 0, 0, 0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(vertical:8.0, horizontal: 12.0);

  static const double showScrollButtonHeight = 300.0;

  static const double cutoffWidth = 700.0;
}