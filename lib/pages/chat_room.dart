import 'dart:async';

import 'package:chatapp/consts.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/alert.dart';
import 'package:chatapp/widgets/message.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  String loggedInDisplayName = "";

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    DatabaseService().getMessages()
      .then((val) {
        setState(() {
          messages = val;
        });
      });

    getLoggedInUserName();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  void getLoggedInUserName() async {
    await HelperFunctions.getDisplayName().then((value) {
      setState(() {
        loggedInDisplayName = value!;
      });
    });
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
      body: Column(
        children: [
          Expanded(child: chatMessages()),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: messageSender(),
          ),
        ],
      )
    );
  }

  messageSender() {
    return Padding(
      padding: Consts.messageSenderPadding,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(Consts.messageRadius),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Send a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8.0),
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            GestureDetector(
              onTap: () {
                sendMessage();
              },
              child: Padding(
                padding: Consts.messageSenderPadding,
                child: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary, 
                ),
              ),
            )
          ],
        )
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: messages,
      builder:(context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if(_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return snapshot.hasData
        ? NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            print("${scroll.metrics.pixels} : ${_scrollController.position.maxScrollExtent}");
            return false;
          },
          child: ListView.builder(
              controller: _scrollController,
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
                    currentDisplayName: loggedInDisplayName,
                  );
              },
            ),
        )
        : Container();
      },
    );
  }

  sendMessage() {
    if(_messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "isAlert": false,
        "message": _messageController.text,
        "sender": loggedInDisplayName,
        "timeStamp": Timestamp.now().millisecondsSinceEpoch
      };

      DatabaseService().sendMessage(messageMap).then((_) {
        setState(() {
          _messageController.clear();
            _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
      });

      

      
    }
  }
}