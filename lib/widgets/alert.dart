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
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        text: TextSpan(
          text: sender,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          children: [
            TextSpan(
              text: message,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          ],
        )
      ),
    );
  }
}