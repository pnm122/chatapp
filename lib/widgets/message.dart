import 'package:chatapp/constants/reaction_types.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/viewmodels/chat_page_view_model.dart';
import 'package:chatapp/widgets/message_time_stamp.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/constants/consts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Message extends StatelessWidget {
  const Message({
    super.key, 
    required this.sender,
    required this.lastMessageSender,
    required this.sentByMe, 
    required this.message, 
    required this.timeStamp, 
    required this.messageID,
    required this.reactions,
    required this.replyID,
    required this.lastMessageTimeStamp,
    required this.mainViewModel,
    required this.chatPageViewModel,
  });
  // who the message was sent by
  final String sender;
  // who sent the message before this one. used to figure out what padding to use/if the name should appear with the message
  final String lastMessageSender;
  // if this message was sent by the current user
  final bool sentByMe;
  // the message content
  final String message;
  // time the message was sent in milliseconds since Epoch
  final int timeStamp;
  // ID of the message. Can be null while waiting to set the ID after creating the message, since these must be done in two steps in DatabaseService
  final String? messageID;
  // list of reactions to this message
  final List reactions;
  // ID of the message this message is replying to
  final String? replyID;
  // time the message before this message was sent. used to figure out what padding to use/if the name should appear with the message
  final int lastMessageTimeStamp;
  // MainViewModel instance which gets passed into the new screen created on long pressing a message
  final MainViewModel mainViewModel;
  final ChatPageViewModel chatPageViewModel;

  @override
  Widget build(BuildContext context) {
    // 180,000 ms => 3 minutes
    final bool showTimeStamp = timeStamp > lastMessageTimeStamp + 180000;
    final bool groupingMessages = !showTimeStamp && sender == lastMessageSender;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: Consts.sideMargin),
      child: Column(
        children: [
          showTimeStamp ? MessageTimeStamp(timeStamp: timeStamp) : Container(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: sentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                  children: [
                    // Only show sender when not grouping messages together
                    groupingMessages ? Container() : const SizedBox(height: 4),
                    groupingMessages ? Container() : SelectableText(
                      sender,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Consts.senderColor),
                    ),
                    const SizedBox(height: 4.0),
                    GestureDetector(
                      onLongPressStart: (details) {
                        // Takes time to assign ID to just-sent messages, which is used for replying
                        // So I don't allow the popup to come up until this is loaded
                        if(messageID == null) return;

                        context.read<ChatPageViewModel>().setSelectedMessage(messageID!, reactions);

                        double yPos = details.globalPosition.dy - details.localPosition.dy - 26 - 4 - 44;
                        // make sure the popup doesn't go above the screen
                        if(yPos < 16) yPos = 16;

                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
                            barrierDismissible: true,
                            barrierColor: Colors.black87,
                            pageBuilder: (_, __, ___) { 
                              // Wrap both viewmodels around this page since we need to call functions on/get data from both
                              return ChangeNotifierProvider<MainViewModel>.value(
                                value: mainViewModel,
                                child: ChangeNotifierProvider<ChatPageViewModel>.value(
                                  value: chatPageViewModel,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: sentByMe ? null : details.globalPosition.dx - details.localPosition.dx,
                                        // *** WILL BREAK IF I ADD ANYTHING TO THE RIGHT SIDE OF THE MAIN PAGE
                                        // Better way to do this requires getting the widget width, which I can't do during a build :(
                                        right: sentByMe ? Consts.sideMargin : null,
                                        top: yPos,
                                        child: Column(
                                          crossAxisAlignment: sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                          children: [
                                            const ReactionOptions(height: 44),
                                                              
                                            const SizedBox(height: 4),
                                                              
                                            SizedBox(
                                              height: 26,
                                              child: RichText(
                                                text: TextSpan(
                                                  text: "$sender  ",
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                                  children: [
                                                    TextSpan(
                                                      text: HelperFunctions.timeStampToString(timeStamp),
                                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                                    )
                                                  ]
                                                ),
                                                textAlign: sentByMe ? TextAlign.end : TextAlign.start,
                                              ),
                                            ),
                                            Container(
                                              decoration: const BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(blurRadius: 8, offset: Offset(3, 6), color: Colors.black12)
                                                ]
                                              ),
                                              child: InnerMessage(sentByMe: sentByMe, message: message, sender: sender)
                                            ),
                                            const SizedBox(height: 4.0),
                                                              
                                            // Dropdown options
                                            MessageDropdownOptionList(
                                              sentByMe: sentByMe, 
                                              options: [
                                                MessageDropdownOption(
                                                  onTap: () {
                                                    context.read<ChatPageViewModel>().replyingToID = context.read<ChatPageViewModel>().selectedMessageID;
                                                    Navigator.pop(context);
                                                  },
                                                  name: "Reply",
                                                  icon: Icons.reply,
                                                ),
                                              ]
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          )
                        );
                      },
                      child: InnerMessage(sentByMe: sentByMe, message: message, sender: sender, reactions: reactions),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InnerMessage extends StatelessWidget {
  const InnerMessage({super.key, required this.sentByMe, required this.message, required this.sender, this.reactions});
  final bool sentByMe;
  final String message;
  final String sender;
  final List? reactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Consts.messageRadius,
              topRight: Consts.messageRadius,
              bottomLeft: sentByMe ? Consts.messageRadius : Radius.zero,
              bottomRight: sentByMe ? Radius.zero : Consts.messageRadius,
            ),
            color: sentByMe
            ? Consts.sentColor
            : Consts.receivedColor,
          ),
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.all(16.0),
          child: SelectableText(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sentByMe
              ? Consts.sentColor.computeLuminance() > 0.5 ? const Color.fromARGB(193, 0, 0, 0) : Colors.white
              : Consts.receivedColor.computeLuminance() > 0.5 ? Colors.black : Colors.white
            )
          ),
        ),
        reactions != null && reactions!.isNotEmpty ? const SizedBox(height: 4) : Container(),
        reactions != null && reactions!.isNotEmpty ? OnMessageReactions(reactions: reactions!) : Container(),
      ],
    );
  }
}

class OnMessageReactions extends StatelessWidget {
  const OnMessageReactions({super.key, required this.reactions});
  final List reactions;

  @override
  Widget build(BuildContext context) {
    // users with each type of reaction
    Map<String, String> reactionsByType = <String, String>{};
    for(String reaction in reactions) {
      // reactions are stored as TYPE_UID_DISPLAYNAME
      List<String> split = reaction.split('_');
      String? names = reactionsByType[split.first];
      if(names == null) { 
        reactionsByType[split.first] = split.last; 
      } else { 
        reactionsByType[split.first] = "$names, ${split.last}"; 
      }
    }
    double size = 20;

    return SizedBox(
      height: size,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reactionsByType.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          String type = reactionsByType.entries.elementAt(index).key;
          String names = reactionsByType.entries.elementAt(index).value;
          return Row(
            children: [
              Tooltip(
                message: names,
                verticalOffset: 12,
                decoration: const BoxDecoration(
                  color: Consts.toolTipColor,
                ),
                child: Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    color: ReactionTypes.colorOf(type),
                    shape: BoxShape.circle
                  ),
                  child: Icon(
                    ReactionTypes.iconOf(type),
                    color: Colors.white,
                    size: size / 2,
                  ),
                ),
              ),
              index != reactionsByType.length - 1 ? const SizedBox(width: 4) : Container(),
            ],
          );
        },
      ),
    );
  }
}

class ReactionOptions extends StatefulWidget {
  const ReactionOptions({super.key, required this.height});
  final double height;

  @override
  State<ReactionOptions> createState() => _ReactionOptionsState();
}

class _ReactionOptionsState extends State<ReactionOptions> {
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Wrap(
        spacing: 6,
        children: const [
          ReactionOption(type: ReactionTypes.favorite),
          ReactionOption(type: ReactionTypes.thumb_up),
          ReactionOption(type: ReactionTypes.thumb_down),
          ReactionOption(type: ReactionTypes.exclamation),
          ReactionOption(type: ReactionTypes.question),
        ],
      )
    );
  }
}

class ReactionOption extends StatefulWidget {
  const ReactionOption({super.key, required this.type});
  final String type;

  @override
  State<ReactionOption> createState() => _ReactionOptionState();
}

class _ReactionOptionState extends State<ReactionOption> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    String currentUserReaction = context.watch<ChatPageViewModel>().selectedMessageReaction;
    bool selected = currentUserReaction == widget.type;
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if(currentUserReaction != "") {
            DatabaseService().removeReactionToMessage(
              context.read<MainViewModel>().selectedGroupId, 
              context.read<ChatPageViewModel>().selectedMessageID, 
              currentUserReaction, 
              FirebaseAuth.instance.currentUser!.uid,
              context.read<MainViewModel>().currentUserName,
            );
          }
          if(currentUserReaction == widget.type) {
            context.read<ChatPageViewModel>().currentUserReaction = "";
            return;
          }

          DatabaseService().reactToMessage(
            context.read<MainViewModel>().selectedGroupId, 
            context.read<ChatPageViewModel>().selectedMessageID, 
            widget.type, 
            FirebaseAuth.instance.currentUser!.uid,
            context.read<MainViewModel>().currentUserName,
          );
          context.read<ChatPageViewModel>().currentUserReaction = widget.type;
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected ? ReactionTypes.colorOf(widget.type) : Colors.white,
            borderRadius: BorderRadius.circular(99),
            boxShadow: const [
              BoxShadow(blurRadius: 8, offset: Offset(3, 6), color: Colors.black12)
            ],
          ),
          child: Icon(
            ReactionTypes.iconOf(widget.type),
            color: selected ? Colors.white 
                 : hovering ? ReactionTypes.colorOf(widget.type) : Colors.black,
          ),
        ),
      ),
    );
  }
}

class MessageDropdownOptionList extends StatelessWidget {
  const MessageDropdownOptionList({super.key, required this.sentByMe, required this.options});
  final bool sentByMe;
  final List<MessageDropdownOption> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Consts.foregroundColor,
        borderRadius: sentByMe ? const BorderRadius.only(
          topLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
          bottomLeft: Radius.circular(18)
        ) : const BorderRadius.only(
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
          bottomLeft: Radius.circular(18)
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 8, offset: Offset(3, 6), color: Colors.black12)
        ]
      ),
      child: Column(
        children: options
      ),
    );
  }
}

class MessageDropdownOption extends StatefulWidget {
  const MessageDropdownOption({super.key, required this.onTap, required this.name, required this.icon});
  final VoidCallback onTap;
  final String name;
  final IconData icon;

  @override
  State<MessageDropdownOption> createState() => _MessageDropdownOptionState();
}

class _MessageDropdownOptionState extends State<MessageDropdownOption> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: TextButton(
        onHover: (hover) {
          setState(() {
            hovering = hover;
          });
        },
        onPressed: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: hovering ? Theme.of(context).colorScheme.primary : Colors.black,
                  )
                ),
              ),
              Icon(
                widget.icon,
                color: hovering ? Theme.of(context).colorScheme.primary : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}