import 'package:flutter/material.dart';

class Consts {
  // Firebase stuff
  static String apiKey = "AIzaSyDnNnbM881qDtuufNafKINmWyl2ds27aBE";
  static String projectId ="chatapp-ba297";
  static String messagingSenderId = "315668262849";
  static String appId = "1:315668262849:web:6c6b9594b6bb333bdb0940";

  static const double sideMargin = 16.0;

  static const int maxGroupNameLength = 30;

  static EdgeInsets appBarIconPadding =  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0);

  static EdgeInsets messagePadding = const EdgeInsets.all(16.0);
  static EdgeInsets messageSurroundPadding = const EdgeInsets.symmetric(horizontal: sideMargin, vertical: 16.0);

  static EdgeInsets groupSectionPadding =  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static EdgeInsets groupTilePadding = const EdgeInsets.all(12.0);
  static const double groupTileHeight = 76;
  static const Color backgroundColor = Color.fromARGB(255, 249, 249, 249); // i.e. chat background
  static const Color foregroundColor = Color.fromARGB(255, 255, 255, 255); // i.e. groups background
  static const Color toolTipColor = Color.fromARGB(255, 73, 73, 73);
  static const Color hoverColor = Color.fromARGB(255, 242, 242, 242);
  static const Color selectedColor = Color.fromARGB(255, 248, 248, 248);
  static const Color successColor = Color(0xFF44CC44);

  static const Color sentColor = Color.fromARGB(255, 56, 141, 99);
  static const Color receivedColor = Color.fromARGB(255, 224, 224, 224);
  static const Color senderColor = Color.fromARGB(255, 99, 99, 99);
  static const Radius messageRadius = Radius.circular(18);

  static const Color inputBackgroundColor = Color.fromARGB(20, 0, 0, 0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(vertical:8.0, horizontal: 12.0);

  static const double showScrollButtonHeight = 300.0;

  static const double cutoffWidth = 700.0;

  static const Duration animationDuration = Duration(milliseconds: 200);
}