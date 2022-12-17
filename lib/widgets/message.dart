import 'package:chatapp/widgets/message_time_stamp.dart';
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
    // 300,000 ms => 5 minutes
    final bool showTimeStamp = timeStamp > lastMessageTimeStamp + 300000;
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
                    groupingMessages ? Container() : SelectableText(
                      sender,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Consts.senderColor),
                    ),
                    const SizedBox(height: 4.0),
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