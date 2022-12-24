import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPageViewModel with ChangeNotifier {
  String _selectedMessageReaction = "";
  String _selectedMessageID = "";
  String _replyingToID = "";
  String _replyingToMessage = "";
  String _replyingToSender = "";
  int _replyingToTimeStamp = -1;

  String get selectedMessageReaction => _selectedMessageReaction;
  String get replyingToID => _replyingToID;
  String get selectedMessageID => _selectedMessageID;
  String get replyingToMessage => _replyingToMessage;
  String get replyingToSender => _replyingToSender;
  int get replyingToTimeStamp => _replyingToTimeStamp;

  set currentUserReaction(reactionType) {
    _selectedMessageReaction = reactionType;
    notifyListeners();
  }

  set replyingToID(messageID) {
    _replyingToID = messageID;
    notifyListeners();
  }

  void setReplyMessage(replyingToMessage, replyingToSender, replyingToTimeStamp) {
    _replyingToMessage = replyingToMessage;
    _replyingToSender = replyingToSender;
    _replyingToTimeStamp = replyingToTimeStamp;
  }

  void setSelectedMessage(String messageID, List? reactions) {
    _selectedMessageID = messageID;
    if(reactions == null) {
      _selectedMessageReaction = "";
      return;
    }
    // format for reactions:
    // TYPE_UID_DISPLAYNAME
    for(String reaction in reactions) {
      List<String> split = reaction.split('_');
      String uid = split.elementAt(1);

      if(uid == FirebaseAuth.instance.currentUser!.uid) {
        _selectedMessageReaction = split.first;
        return;
      }
    }
    _selectedMessageReaction = "";
  }
}