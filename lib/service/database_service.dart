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

    messageCollection.doc().set({
      "isAlert": true,
      "sender": displayName,
      "message": " logged out.",
      "timeStamp": time,
    });
  }

  getMessages() async {
    return messageCollection.orderBy("timeStamp").snapshots();
  }
}