import 'dart:async';
import 'dart:html';

import 'package:badges/badges.dart';
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

  bool showScrollButton = false;
  int notifs = 0;
  int messagesWhenButtonShown = 0;

  @override
  void initState() {
    DatabaseService().getMessages()
      .then((val) {
        setState(() {
          messages = val;
        });
      });

    //getLoggedInUserName();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  /*void getLoggedInUserName() async {
    await HelperFunctions.getDisplayName().then((value) {
      setState(() {
        loggedInDisplayName = value!;
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                //DatabaseService().alertLogOut();
                authService.signOut();
                pushScreenReplace(context, const LoginPage());
              },
              child: const Text("Log out"),
            ),
          ),
        ]
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                chatMessages(),
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  alignment: Alignment.bottomCenter,
                  key: ValueKey<bool>(showScrollButton), // updates when showScrollButton is changed!
                  child: showScrollButton
                    ? scrollButtonAndNotifier()
                    : const SizedBox(height: 0, width: 0),
                ),
              ],
            ),
          ),
          messageSender(),
        ],
      )
    );
  }

  scrollButtonAndNotifier() {
    return InkWell(
      onTap: () => scrollToBottom(true),
      child: Badge(
        key: ValueKey<int>(notifs),
        position: BadgePosition.topEnd(),
        showBadge: notifs > 0,
        badgeContent: Text(
          notifs.toString(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(999),
          ),
      
          child: Text(
            "Go to bottom",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  messageSender() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),

      child: Padding(
        padding: Consts.messageSenderPadding,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black12,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(99),
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
              InkWell(
                onTap: () => sendMessage(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary, 
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }

  bool wait = false;

  chatMessages() {
    return StreamBuilder(
      stream: messages,
      builder:(context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Called on initial load and after new messages are sent by any user
        SchedulerBinding.instance.addPostFrameCallback((_) {

          if(wait) { wait = false; return; } // Don't scroll to bottom directly after getting rid of the scroll button
          if(showScrollButton) { 
            setState(() {
              notifs = snapshot.data.docs.length - messagesWhenButtonShown;
            });
            return; 
          }
          if(_scrollController.hasClients) {
            scrollToBottom(false);
          }
        });

        return snapshot.hasData
        ? NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            double dist = _scrollController.position.maxScrollExtent - scroll.metrics.pixels;
            if(dist > Consts.showScrollButtonHeight && showScrollButton == false) {
              setState(() {showScrollButton = true; notifs = 0; messagesWhenButtonShown = snapshot.data.docs.length; });
            } else if(dist < Consts.showScrollButtonHeight && showScrollButton == true) {
              setState(() {showScrollButton = false; wait = true; });
            } 
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

  scrollToBottom(bool animate) {
    if(animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
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
        });
      });
    }
  }
}