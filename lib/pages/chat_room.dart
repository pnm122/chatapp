import 'dart:async';
import 'dart:html';

import 'package:badges/badges.dart';
import 'package:chatapp/consts.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/widgets/alert.dart';
import 'package:chatapp/widgets/message.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthService authService = AuthService();
  // List of messages in the database
  // DatabaseService().getMessages() returns a listener to it so it automatically updates and rebuilds widgets when the messages change
  Stream<QuerySnapshot<Object?>>? messages;
  String groupID = "";
  String loggedInDisplayName = "";

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool firstLoad = true;
  bool showScrollButton = false;
  int notifs = 0;
  int messagesWhenButtonShown = 0;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    groupID = context.watch<MainViewModel>().selectedGroupId;
    messages = context.watch<MainViewModel>().messages as Stream<QuerySnapshot<Object?>>?;

    return groupID == "" 
      ? Center(child: Text("Please select a group"))
      : Column(
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
        );
  }

  scrollButtonAndNotifier() {
    return Tooltip(
      preferBelow: false,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(color: Colors.grey.shade700),
      message: "Scroll to bottom",
      child: InkWell(
        onTap: () => animateToBottom(),
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
        
            child: const Icon(Icons.arrow_downward, color: Colors.white)
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
                  decoration: InputDecoration(
                    hintText: "Send a message...",
                    border: InputBorder.none,
                    contentPadding: Consts.innerSenderPadding,
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              InkWell(
                onTap: () => sendMessage(),
                child: Padding(
                  padding: Consts.innerSenderPadding,
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
            // jump to bottom when the page loads for the first time, otherwise animate the scroll
            if(firstLoad) { firstLoad = false; jumpToBottom(); }
            else { animateToBottom(); }
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
                    sentByMe: snapshot.data.docs[index]["senderID"] == FirebaseAuth.instance.currentUser!.uid,
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

  animateToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  jumpToBottom() {
    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  sendMessage() async {
    if(_messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "isAlert": false,
        "message": _messageController.text,
        "sender": await DatabaseService().getCurrentUserName(),
        "senderID": FirebaseAuth.instance.currentUser!.uid,
        "timeStamp": Timestamp.now().millisecondsSinceEpoch
      };

      DatabaseService().sendMessage(groupID, messageMap).then((_) {
        setState(() {
          _messageController.clear();
        });
      });
    }
  }
}