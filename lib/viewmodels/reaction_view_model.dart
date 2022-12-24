import 'package:chatapp/constants/reaction_types.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReactionViewModel with ChangeNotifier {
  late String _currentUserReaction;
  String messageID;

  ReactionViewModel(reactions, this.messageID) {
    if(reactions == null) _currentUserReaction = "";
    // format for reactions:
    // TYPE_UID_DISPLAYNAME
    for(String reaction in reactions!) {
      List<String> split = reaction.split('_');
      String uid = split.elementAt(1);

      if(uid == FirebaseAuth.instance.currentUser!.uid) {
        _currentUserReaction = split.first;
        return;
      }
    }
    _currentUserReaction = "";
  }

  String get currentUserReaction => _currentUserReaction;

  set currentUserReaction(reactionType) {
    _currentUserReaction = reactionType;
    notifyListeners();
  }
}