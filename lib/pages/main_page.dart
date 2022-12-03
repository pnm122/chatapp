import 'package:chatapp/consts.dart';
import 'package:chatapp/pages/chat_room.dart';
import 'package:chatapp/widgets/groups.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:chatapp/pages/login_page.dart';

import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MediaQuery.of(context).size.width > Consts.cutoffWidth
          ? const Groups()
          : Container(),

        // Use expanded so it doesn't overflow (bc the other row element is a sizedbox)
        Expanded(
          child: Scaffold(
            appBar: CustomAppBar(
              leading: MediaQuery.of(context).size.width > Consts.cutoffWidth
                ? null : IconButton(
                  icon: const Icon(Icons.groups),
                  // Using this instead of drawer because Scaffold.of(context).openDrawer() didn't like me for some reason
                  onPressed: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      // Color behind this route and in front of the one behind
                      barrierColor: Colors.black38,
                      barrierDismissible: true,
                      pageBuilder: ((context, animation, secondaryAnimation) => Groups()),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    )
                  )
                ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: Consts.sideMargin),
                  child: ElevatedButton(
                    onPressed: () {
                      //DatabaseService().alertLogOut();
                      _auth.signOut();
                      pushScreenReplace(context, const LoginPage());
                    },
                    child: const Text("Log out"),
                  ),
                ),
              ]
            ),
            body: const ChatRoom(),
          ),
        ),
      ],
    );
  }
}