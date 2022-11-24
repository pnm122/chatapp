import 'package:flutter/material.dart';

void pushScreen(context, page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page)
  );
}

void pushScreenReplace(context, page) {
  Navigator.pushReplacement(
    context, 
    MaterialPageRoute(builder: (context) => page)
  );
}