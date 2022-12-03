import 'package:chatapp/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/consts.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = 
    FirebaseFirestore.instance.collection("users");

  final CollectionReference messageCollection = 
    FirebaseFirestore.instance.collection("messages");

  Future test() async {
    return await userCollection.doc().set({
      "test": "test",
    });
  }

  Future updateUserData(String displayName) async {
    return await userCollection.doc(uid).set({
      "displayName": displayName,
    });
  }

  alertLogIn() async {
    final displayName = await HelperFunctions.getDisplayName();
    final time = Timestamp.now().millisecondsSinceEpoch;

    messageCollection.doc().set({
      "isAlert": true,
      "sender": displayName,
      "message": " logged in.",
      "timeStamp": time,
    });
  }

  alertLogOut() async {
    final displayName = await HelperFunctions.getDisplayName();
    final time = Timestamp.now().millisecondsSinceEpoch;

    try {
        messageCollection.doc().set({
        "isAlert": true,
        "sender": displayName,
        "message": " logged out.",
        "timeStamp": time,
      });
    } on FirebaseException catch(e) {
      print(e);
    }
    
  }

  getMessages() async {
    // Descending = true to reverse the order, so that newest messages are at the start of the list
    // This is important so that we can render the newest messages first on the chat page
    return messageCollection.orderBy("timeStamp", descending: true).snapshots();
  }

  sendMessage(Map<String, dynamic> messageMap) async {
    messageCollection.add(messageMap);
  }
}