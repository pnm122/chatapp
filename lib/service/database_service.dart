import 'package:chatapp/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = 
    FirebaseFirestore.instance.collection("users");

  final CollectionReference messageCollection = 
    FirebaseFirestore.instance.collection("messages");

  final CollectionReference groupCollection =
    FirebaseFirestore.instance.collection("groups");

  Future createUser(UserCredential user) async {
    await userCollection.doc(user.user?.uid).set({
      "displayName": "",
      "isLoggedIn": true,
    });
    // Other data:
    // groups (collection)
  }

  Stream<DocumentSnapshot> getGroup(String id) {
    return groupCollection.doc(id).snapshots();
  }

  Future createGroup(String groupName) async {
    DocumentReference group = groupCollection.doc();
    await group.set({
      "name": groupName,
    });

    String? uid = await HelperFunctions.getUserID();
    await userCollection.doc(uid).collection("groups").doc().set({
      "id": group.id,
    });
  }

  Future getCurrentUserGroups() async {
    String? uid = await HelperFunctions.getUserID();
    return userCollection.doc(uid).collection("groups").snapshots();
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

  getMessages() {
    return messageCollection.orderBy("timeStamp").snapshots();
  }

  sendMessage(Map<String, dynamic> messageMap) async {
    messageCollection.add(messageMap);
  }
}