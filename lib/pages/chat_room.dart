import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  const ChatRoom({super.key});

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();
    return Center(
      child: ElevatedButton(
        onPressed: () {
          authService.signOut();
          //pushScreenReplace(context, LoginPage());
        },
        child: Text("Log out"),
      ),
    );
  }
}