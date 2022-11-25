import 'package:flutter/material.dart';
import 'package:chatapp/helper/helper_functions.dart';

class Message extends StatelessWidget {
  const Message({super.key, required this.sender, required this.message, required this.timeStamp});
  final String sender;
  final String message;
  final String timeStamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(sender),
              // Todo: use correct timeStamping and get time from timeStamp
              Expanded(child: Text(timeStamp, textAlign: TextAlign.end),)
            ],
          ),
          Text(message),
        ],
      ),
    );
  }
}