import 'package:flutter/material.dart';

class ReactionTypes {
  static const String favorite = "FAVORITE";
  static const String thumb_up = "THUMBUP";
  static const String thumb_down = "THUMBDOWN";
  static const String exclamation = "EXCLAMATION";
  static const String question = "QUESTION";

  static Color colorOf(String reactionType) {
    switch(reactionType) {
      case ReactionTypes.favorite:
        return Colors.red;
      case ReactionTypes.thumb_up:
        return Colors.blue;
      case ReactionTypes.thumb_down:
        return Colors.teal;
      case ReactionTypes.exclamation:
        return Colors.yellow.shade800;
      case ReactionTypes.question:
        return Colors.indigo.shade400;
      default:
        return Colors.black;
    }
  }

  static IconData iconOf(String reactionType) {
    switch(reactionType) {
      case ReactionTypes.favorite:
        return Icons.favorite;
      case ReactionTypes.thumb_up:
        return Icons.thumb_up;
      case ReactionTypes.thumb_down:
        return Icons.thumb_down;
      case ReactionTypes.exclamation:
        return Icons.priority_high;
      case ReactionTypes.question:
        return Icons.question_mark;
      default:
        return Icons.error;
    }
  }
}