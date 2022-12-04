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

void pushPopUp(context, page) {
  showGeneralDialog(
    barrierColor: const Color.fromARGB(175, 0, 0, 0),
    context: context, 
    pageBuilder: ((context, animation, secondaryAnimation) {
      return Center(
        // Do this so there is a material widget ancestor for things to behave properly
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          color: Colors.white,
          // Use this to minimize height to fit content
          child: Wrap(
            children: [
              page
            ]
          )
        )
      );
    })
  );
}