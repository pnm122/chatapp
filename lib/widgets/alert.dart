import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/consts.dart';

class Alert extends StatelessWidget {
  const Alert({super.key, required this.sender, required this.message, required this.timeStamp});
  final String sender;
  final String message;
  final int timeStamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Consts.messagePadding,
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                text: sender,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: message
                  )
                ],
              )
            ),
          ),
          Text(
            Timestamp.fromMillisecondsSinceEpoch(timeStamp).toDate().toString(), 
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}