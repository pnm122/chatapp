import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/consts.dart';

class Message extends StatelessWidget {
  const Message({super.key, required this.sender, required this.message, required this.timeStamp, required this.currentDisplayName});
  final String sender;
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
                  crossAxisAlignment: currentDisplayName == sender
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
                        borderRadius: BorderRadius.circular(Consts.messageRadius),
                        color: currentDisplayName == sender
                        ? Consts.sentColor
                        : Consts.receivedColor,
                      ),
                      constraints: const BoxConstraints(maxWidth: 350),
                      padding: Consts.messagePadding,
                      child: Text(
                        message,
                        style: currentDisplayName == sender
                          ? Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)
                          : Theme.of(context).textTheme.bodyMedium,
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