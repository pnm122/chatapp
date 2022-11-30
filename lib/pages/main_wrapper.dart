import 'package:chatapp/pages/chat_room.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        // listen for changes on authentication state, and decide what to show based on that
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if(snapshot.hasData) {
            return const ChatRoom();
          } else if(snapshot.hasData) {
            return const Center(child: Text("Something went wrong!"));
          } else {
            return const LoginPage();
          }
        }
      ),
    );
  }
}