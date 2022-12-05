import 'package:flutter/material.dart';

class Consts {
  // Firebase stuff
  static String apiKey = "AIzaSyDnNnbM881qDtuufNafKINmWyl2ds27aBE";
  static String projectId ="chatapp-ba297";
  static String messagingSenderId = "315668262849";
  static String appId = "1:315668262849:web:6c6b9594b6bb333bdb0940";

  static const double sideMargin = 16.0;

  static EdgeInsets appBarIconPadding =  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0);

  static EdgeInsets messagePadding = const EdgeInsets.all(16.0);
  static EdgeInsets messageSurroundPadding = const EdgeInsets.symmetric(horizontal: sideMargin, vertical: 32.0);
  static EdgeInsets messageSenderPadding = const EdgeInsets.all(16.0);
  static EdgeInsets innerSenderPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);

  static EdgeInsets groupSectionPadding =  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static EdgeInsets groupTilePadding = const EdgeInsets.all(12.0);
  static EdgeInsets groupTileMargin = const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0);
  static const Color foregroundColor = Color.fromARGB(255, 241, 250, 241); // i.e. chat background
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255); // i.e. groups background
   static const Color toolTipColor = Color.fromARGB(255, 73, 73, 73);

  static const tileShadow = BoxShadow(color: Colors.black12, offset: Offset(2, 5), blurRadius: 12.0);
  static const hoverTileShadow = BoxShadow(color: Colors.black26, offset: Offset(2, 5), blurRadius: 6.0);

  static const Color sentColor = Color.fromARGB(255, 41, 106, 238);
  static const Color receivedColor = Color.fromARGB(255, 224, 224, 224);
  static const Color senderColor = Color.fromARGB(255, 99, 99, 99);
  static const Radius messageRadius = Radius.circular(18);

  static const Color inputBackgroundColor = Color.fromARGB(20, 0, 0, 0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(vertical:8.0, horizontal: 12.0);

  static const double showScrollButtonHeight = 300.0;

  static const double cutoffWidth = 700.0;
}