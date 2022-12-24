import 'dart:async';
import 'dart:html';

import 'package:badges/badges.dart';
import 'package:chatapp/constants/consts.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/pages/info_page.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/viewmodels/chat_page_view_model.dart';
import 'package:chatapp/widgets/alert.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:chatapp/widgets/groups.dart';
import 'package:chatapp/widgets/message.dart';
import 'package:chatapp/widgets/message_time_stamp.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.mainViewModel, required this.chatPageViewModel});

  final MainViewModel mainViewModel;
  final ChatPageViewModel chatPageViewModel;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  AuthService authService = AuthService();
  // List of messages in the database
  // DatabaseService().getMessages() returns a listener to it so it automatically updates and rebuilds widgets when the messages change
  Stream<QuerySnapshot<Object?>>? messages;
  Stream? groupMembers;
  String groupID = "";
  String loggedInDisplayName = "";

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool firstLoad = true;
  bool showScrollButton = false;
  int messagesWhenButtonShown = 0;

  bool editingGroupName = false;
  bool replying = false;

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
    messages = context.watch<MainViewModel>().messages;
    groupMembers = context.watch<MainViewModel>().selectedGroupMembers;
    String replyingToID = context.watch<ChatPageViewModel>().replyingToID;
    replying = replyingToID != "";

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: Consts.backgroundColor,
        title: groupName == "" ? null : Row(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
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
                                //constraints: BoxConstraints(maxWidth: 280),
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
                          // Allow the group name to be scrolled
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
              ),
            ),
            Expanded(child: UserList(stream: groupMembers)),
          ],
        ),
        leading: MediaQuery.of(context).size.width > Consts.cutoffWidth
          ? null : IconButton(
            icon: const Icon(Icons.menu),
            // Using this instead of drawer because Scaffold.of(context).openDrawer() didn't like me for some reason
            onPressed: () => Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                // Color behind this route and in front of the one behind
                barrierColor: Colors.black38,
                barrierDismissible: true,
                pageBuilder: ((context, animation, secondaryAnimation) => 
                  ChangeNotifierProvider<MainViewModel>.value(
                    value: widget.mainViewModel, // Pass in the same viewmodel to this new view
                    child: const InfoPage(),
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
      ),
      body: Container(
        color: Consts.backgroundColor,
        child: groupID == "" 
          ? const Center(child: Text("Please select a group"))
          : Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    chatMessages(),
                    Positioned(bottom: 0, left: 0, right: 0, 
                      child: Column(
                        children: [
                          showScrollButton ? scrollButtonAndNotifier() : Container(),
                          replying ? ReplyToMessage(replyingToID: replyingToID) : Container(),
                          messageSender()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  scrollButtonAndNotifier() {
    return Padding(
      padding: EdgeInsets.all(replying ? 0 : 8),
      child: Tooltip(
        preferBelow: false,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(color: Consts.toolTipColor),
        message: "Scroll to bottom",
        child: StreamBuilder(
          stream: messages,
          builder: (context, snapshot) {
            int numNewMessages = 0;
            if(snapshot.hasData) numNewMessages = snapshot.data!.docs.length - messagesWhenButtonShown;

            return InkWell(
              onTap: () => animateToBottom(),
              child: Badge(
                position: BadgePosition.topEnd(),
                showBadge: numNewMessages > 0,
                badgeContent: Text(
                  numNewMessages.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(blurRadius: 16, offset: Offset(2, 4), color: Colors.black12)
                    ],
                  ),
              
                  child: const Icon(Icons.arrow_downward, color: Colors.white)
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  messageSender() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromARGB(0, 249, 249, 249), Consts.backgroundColor]),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Consts.foregroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color.fromARGB(24, 0, 0, 0), blurRadius: 8.0, offset: Offset(2, 4))
          ]
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
          if(showScrollButton) return;
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
              setState(() {showScrollButton = true; messagesWhenButtonShown = snapshot.data.docs.length; });
            } else if(dist < Consts.showScrollButtonHeight && showScrollButton == true) {
              setState(() {showScrollButton = false; wait = true; });
            } 
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length + 1,
            itemBuilder: (context, index) {
              if(index == snapshot.data.docs.length) {
                return SizedBox(height: context.read<ChatPageViewModel>().replyingToID == "" ? 86 : 86 + 50);
              }
              Map data = snapshot.data.docs[index].data();
              return Column(
                children: [
                  snapshot.data.docs[index]["isAlert"] 
                    ? Alert(
                      sender: data["sender"],
                      message: data["message"],
                      timeStamp: data["timeStamp"],
                    ) 
                    : Message(
                      sender: data["sender"],
                      lastMessageSender: index > 0 ? snapshot.data.docs[index - 1]["sender"] : "",
                      sentByMe: data["senderID"] == FirebaseAuth.instance.currentUser!.uid,
                      message: data["message"],
                      timeStamp: data["timeStamp"],
                      messageID: data["id"],
                      reactions: data["reactions"],
                      replyMessage: data["replyMessage"],
                      replySender: data["replySender"],
                      replyTimeStamp: data["replyTimeStamp"],
                      lastMessageTimeStamp: index > 0 ? snapshot.data.docs[index - 1]["timeStamp"] : 0,
                      mainViewModel: widget.mainViewModel,
                      chatPageViewModel: widget.chatPageViewModel,
                    ),
                ],
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
        "sender": context.read<MainViewModel>().currentUserName,
        "senderID": FirebaseAuth.instance.currentUser!.uid,
        "timeStamp": Timestamp.now().millisecondsSinceEpoch,
        "reactions": []
      };
      if(replying) {
        ChatPageViewModel vm = context.read<ChatPageViewModel>();
        Map<String, dynamic> replyMap = {
          "replyMessage": vm.replyingToMessage,
          "replySender": vm.replyingToSender,
          "replyTimeStamp": vm.replyingToTimeStamp
        };
        messageMap.addAll(replyMap);
        context.read<ChatPageViewModel>().replyingToID = "";
      }

      DatabaseService().sendMessage(groupID, messageMap).then((_) {
        setState(() {
          _messageController.clear();
        });
      });
    }
  }
}

class ReplyToMessage extends StatelessWidget {
  const ReplyToMessage({super.key, required this.replyingToID});
  final String replyingToID;

  @override
  Widget build(BuildContext context) {
    Stream replyingToMessage = DatabaseService().getMessage(
      context.read<MainViewModel>().selectedGroupId,
      replyingToID,
    );
    return StreamBuilder(
      stream: replyingToMessage,
      builder: (context, snapshot) { 
        bool waiting = snapshot.connectionState == ConnectionState.waiting;
        if(!waiting) {
          Map info = snapshot.data.data();
          context.read<ChatPageViewModel>().setReplyMessage(
            info["message"], 
            info["sender"], 
            info["timeStamp"]
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: Consts.sideMargin),
          
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: Consts.backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              boxShadow: const [
                BoxShadow(blurRadius: 16, offset: Offset(2, 4), color: Colors.black12)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        !waiting ? Text(
                          "Replying to ${snapshot.data.data()["sender"].toString()}:",
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ) : Container(),
                        !waiting ? Text(
                          snapshot.data.data()["message"].toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ) : Container(),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () { context.read<ChatPageViewModel>().replyingToID = ""; },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16, top: 16, bottom: 16),
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}