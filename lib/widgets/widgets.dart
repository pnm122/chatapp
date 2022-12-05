import 'package:chatapp/consts.dart';
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

void pushPopUp(context, page, String title, bool closeable) {
  double width = 300;
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
              SizedBox(
                width: width,
                child: Column(
                  children: [
                    // Header for pop-up
                    Container(
                      color: Color.fromARGB(20, 0, 0, 0),
                      child: Stack(
                        children: [
                          Container(
                            height: 32,
                            alignment: Alignment.center,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          closeable ? Positioned(
                            height: 32,
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () { Navigator.pop(context); }
                            ),
                          ) : Container()
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    page
                  ],
                )
              )
            ]
          )
        )
      );
    })
  );
}