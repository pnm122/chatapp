import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/alert.dart';
import 'package:chatapp/widgets/message.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthService authService = AuthService();
  // List of messages in the database
  // DatabaseService().getMessages() returns a listener to it so it automatically updates and rebuilds widgets when the messages change
  Stream<QuerySnapshot>? messages;

  @override
    void initState() {
      DatabaseService().getMessages()
        .then((val) {
          setState(() {
            messages = val;
          });
        });

      super.initState();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              DatabaseService().alertLogOut();
              authService.signOut();
              pushScreenReplace(context, const LoginPage());
            },
            child: const Text("Log out"),
          ),
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: messages,
          builder:(context, AsyncSnapshot snapshot) {
            return snapshot.hasData
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return snapshot.data.docs[index]["isAlert"] 
                    ? Alert(
                      sender: snapshot.data.docs[index]["sender"],
                      message: snapshot.data.docs[index]["message"],
                      timeStamp: snapshot.data.docs[index]["timeStamp"],
                    ) 
                    : Message(
                      sender: snapshot.data.docs[index]["sender"],
                      message: snapshot.data.docs[index]["message"],
                      timeStamp: snapshot.data.docs[index]["timeStamp"],
                    );
                },
              )
            : const Text("No data");
          },
        ),
      ),
    );
  }
}