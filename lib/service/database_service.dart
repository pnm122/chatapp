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
      "groups": [],
    });
  }

  Future createGroup(String groupName) async {
    DocumentReference group = await groupCollection.add({
      "name": groupName,
      "createdTime": DateTime.now().millisecondsSinceEpoch,
      "lastMessage": "",
      "lastMessageTimeStamp": -1,
      "members": [FirebaseAuth.instance.currentUser!.uid],
      // Also will have a collection of messages
    });

    // Store the ID in the group as well so it's easier to pull out later
    await group.update({"id": group.id});

    String? uid = FirebaseAuth.instance.currentUser!.uid;
    await userCollection.doc(uid).update({
      "groups": FieldValue.arrayUnion([group.id])
    });
  }

  Stream<DocumentSnapshot> getCurrentUserInfo() {
    // Use instead of HelperFunctions method to get current user ID?
    String? uid = FirebaseAuth.instance.currentUser!.uid;
    return userCollection.doc(uid).snapshots();
  }

  Stream<DocumentSnapshot> getGroup(String groupId) {
    return groupCollection.doc(groupId).snapshots();
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

  signIn() async {
    await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "loggedIn": true,
    });
  }

  signOut() async {
    await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "loggedIn": false,
    });
  }

  getMessages(String groupID) {
    if(groupID.isEmpty) return null;
    return groupCollection.doc(groupID).collection("messages").orderBy("timeStamp").snapshots();
  }

  sendMessage(String groupID, Map<String, dynamic> messageMap) async {
    groupCollection.doc(groupID).collection("messages").add(messageMap);
  }
}