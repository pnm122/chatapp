import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/consts.dart';

class Message extends StatelessWidget {
  const Message({super.key, required this.sender, required this.sentByMe, required this.message, required this.timeStamp, required this.currentDisplayName});
  final String sender;
  final bool sentByMe;
  final String message;
  final int timeStamp;
  final String currentDisplayName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Consts.messageSurroundPadding,
      child: Column(
        children: [
          Center(
            child: Text(
              HelperFunctions.timeStampToString(timeStamp), 
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: sentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                  children: [
                    Text(
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
                      padding: Consts.messagePadding,
                      child: Text(
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