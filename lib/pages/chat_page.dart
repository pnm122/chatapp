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
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:chatapp/widgets/groups.dart';
import 'package:chatapp/widgets/message.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.viewModel});

  final viewModel;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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

  bool editingGroupName = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String groupName = context.watch<MainViewModel>().selectedGroupName;
    groupID = context.watch<MainViewModel>().selectedGroupId;
    messages = context.watch<MainViewModel>().messages as Stream<QuerySnapshot<Object?>>?;

    return Scaffold(
      appBar: CustomAppBar(
        title: groupName == "" ? null : Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    editingGroupName 
                      // Wrap with intrinsic width to limit its size to the text being inputted
                      ? IntrinsicWidth(
                        child: TextFormField(
                          initialValue: groupName,
                          maxLength: Consts.maxGroupNameLength,
                          onFieldSubmitted: (name) {
                            if(name.isNotEmpty) {
                              DatabaseService().renameGroup(groupID, name);
                              context.read<MainViewModel>().selectedGroupName = name;
                            }
                            setState(() {
                              editingGroupName = false;
                            });
                          },
                          decoration: const InputDecoration(
                            constraints: BoxConstraints(maxWidth: 200),
                            contentPadding: EdgeInsets.all(6.0),
                            counterText: "",
                            isDense: true,
                            filled: true,
                            fillColor: Consts.inputBackgroundColor,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            )
                          ),
                          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      )
                      : Text(
                          groupName,
                          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
                        ),

                    const SizedBox(width: 4.0),

                    Tooltip(
                      message: editingGroupName ? "Cancel Editing" : "Edit Group Name",
                      decoration: const BoxDecoration(color: Consts.toolTipColor),
                      // Use InkWell to get rid of extra padding
                      child: InkWell(
                        onTap: () {
                          // tell UI to change Group Name to a text field to edit the name
                          setState(() {
                            editingGroupName = !editingGroupName;
                          });
                        },
                        child: Icon(
                          editingGroupName ? Icons.close : Icons.create,
                          size: 20
                        )
                      )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "ID: ${context.read<MainViewModel>().selectedGroupId}",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black54),
                    ),

                    const SizedBox(width: 4.0),

                    Tooltip(
                      message: "Copy to Clipboard",
                      decoration: const BoxDecoration(color: Consts.toolTipColor),
                      // Use InkWell to get rid of extra padding
                      child: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: context.read<MainViewModel>().selectedGroupId))
                            .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Copied Group ID to clipboard."),
                                  backgroundColor: Consts.successColor,
                                )
                              );
                            });
                        },
                        child: const Icon(Icons.copy, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: DatabaseService().getGroupUsers(context.read<MainViewModel>().selectedGroupId),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return Container(
                      // Constraints = size of UserBubble
                      // Should be a temporary fix but I really don't know how to fix the userbubble expanding to height otherwise
                      constraints: const BoxConstraints(maxHeight: 56),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return UserBubble(userData: snapshot.data[index].data());
                        }
                      ),
                    );
                  } else { return Container(); }
                },
              ),
            )
          ],
        ),
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
                pageBuilder: ((context, animation, secondaryAnimation) => 
                  ChangeNotifierProvider<MainViewModel>.value(
                    value: widget.viewModel, // Pass in the same viewmodel to this new view
                    child: const Groups(),
                  )
                ),
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
        hasBottom: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: Consts.sideMargin),
            child: TextButton(
              onPressed: () {
                DatabaseService().setInactive();
                Provider.of<AuthService>(context, listen: false).signOut();
                pushScreenReplace(context, const LoginPage());
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                shadowColor: MaterialStateProperty.all(Colors.transparent), 
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 0))
              ),
              child: const Text("Log out"),
            ),
          ),
        ]
      ),
      body: Container(
      color: Consts.foregroundColor,
      child: groupID == "" 
        ? const Center(child: Text("Please select a group"))
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
          ),
      ),
    );
  }

  scrollButtonAndNotifier() {
    return Tooltip(
      preferBelow: false,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(color: Consts.toolTipColor),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black12,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  onFieldSubmitted: (e) {
                    sendMessage();
                  },
                  // Allow enter to submit message
                  keyboardType: TextInputType.text,
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: "Send a message...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
                    isDense: true,
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              InkWell(
                onTap: () => sendMessage(),
                child: const Padding(
                  padding: EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0),
                  child: Icon(
                    Icons.send,
                    color: Consts.sentColor, 
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