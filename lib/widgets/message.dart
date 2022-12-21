import 'package:chatapp/widgets/message_time_stamp.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/consts.dart';

class Message extends StatelessWidget {
  const Message({
    super.key, 
    required this.sender,
    required this.lastMessageSender,
    required this.sentByMe, 
    required this.message, 
    required this.timeStamp, 
    required this.lastMessageTimeStamp,
    required this.currentDisplayName
  });
  final String sender;
  final String lastMessageSender;
  final bool sentByMe;
  final String message;
  final int timeStamp;
  final int lastMessageTimeStamp;
  final String currentDisplayName;

  @override
  Widget build(BuildContext context) {
    // 180,000 ms => 3 minutes
    final bool showTimeStamp = timeStamp > lastMessageTimeStamp + 180000;
    final bool groupingMessages = !showTimeStamp && sender == lastMessageSender;
    final String heroTag = "${timeStamp}_$sender";
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
                    Hero(
                      tag: heroTag,
                      child: GestureDetector(
                        onLongPressStart: (details) {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false,
                              barrierDismissible: true,
                              barrierColor: Colors.black87,
                              pageBuilder: (_, __, ___) { 
                                return Stack(
                                  children: [
                                    Positioned(
                                      left: sentByMe ? null : details.globalPosition.dx - details.localPosition.dx,
                                      // *** WILL BREAK IF I ADD ANYTHING TO THE RIGHT SIDE OF THE MAIN PAGE
                                      // Better way to do this requires getting the widget width, which I can't do during a build :(
                                      right: sentByMe ? Consts.sideMargin : null,
                                      top: details.globalPosition.dy - details.localPosition.dy - 26,
                                      child: Column(
                                        crossAxisAlignment: sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
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
                                          Hero(
                                            tag: heroTag,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(blurRadius: 8, offset: Offset(3, 6), color: Colors.black12)
                                                ]
                                              ),
                                              child: InnerMessage(sentByMe: sentByMe, message: message, sender: sender)
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),

                                          // Dropdown options
                                          Container(
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
                                              children: [
                                                MessageDropdownOption(
                                                  onTap: () {},
                                                  name: "Reply",
                                                  icon: Icons.reply,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                            )
                          );
                        },
                        child: InnerMessage(sentByMe: sentByMe, message: message, sender: sender),
                      ),
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
  const InnerMessage({super.key, required this.sentByMe, required this.message, required this.sender});
  final bool sentByMe;
  final String message;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Container(
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