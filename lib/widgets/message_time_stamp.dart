import 'package:flutter/material.dart';
import 'package:chatapp/helper/helper_functions.dart';

class MessageTimeStamp extends StatelessWidget {
  const MessageTimeStamp({super.key, required this.timeStamp});
  final int timeStamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          HelperFunctions.timeStampToString(timeStamp), 
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}