import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/consts.dart';

class Message extends StatelessWidget {
  const Message({super.key, required this.sender, required this.message, required this.timeStamp});
  final String sender;
  final String message;
  final int timeStamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Consts.messagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(
                sender.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              // TODO: use correct timeStamping and get time from timeStamp
              Expanded(
                child: Text(
                  Timestamp.fromMillisecondsSinceEpoch(timeStamp).toDate().toString(), 
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            ],
          ),

          const SizedBox(height:3.0),

          Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(width: 2.0))
            ),
            padding: const EdgeInsets.only(left: 3.0, top: 3.0, bottom: 3.0),
            child: Text(message)
          ),
        ],
      ),
    );
  }
}