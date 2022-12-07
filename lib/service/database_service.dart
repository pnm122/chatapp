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
      "lastMessageSender": "",
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

  Future joinGroup(String groupID) async {
    String id = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentReference group = groupCollection.doc(groupID);
      
      /*if(await group.get().then((value) => (value.data() as Map<String, dynamic>)["members"].contains(id))) {

      }*/
      await group.update({
        "members": FieldValue.arrayUnion([id])
      });
      await userCollection.doc(id).update({
        "groups": FieldValue.arrayUnion([groupID])
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future renameGroup(String id, String name) async {
    await groupCollection.doc(id).update({
      "name": name,
    });
  }

  Stream<DocumentSnapshot> getCurrentUserInfo() {
    // Use instead of HelperFunctions method to get current user ID?
    String? uid = FirebaseAuth.instance.currentUser!.uid;
    return userCollection.doc(uid).snapshots();
  }

  Future<String> getCurrentUserName() async {
    String? uid = FirebaseAuth.instance.currentUser!.uid;
    return await userCollection.doc(uid).get().then((value) => (value.data() as Map<String, dynamic>)["displayName"]);
  }

  Stream<DocumentSnapshot> getGroup(String groupId) {
    return groupCollection.doc(groupId).snapshots();
  }

  Future setDisplayName(String displayName) async {
    await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "displayName": displayName,
    });
  }

  signIn() async {
    await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "isLoggedIn": true,
    });
  }

  signOut() async {
    await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "isLoggedIn": false,
    });
  }

  getMessages(String groupID) {
    if(groupID.isEmpty) return null;
    return groupCollection.doc(groupID).collection("messages").orderBy("timeStamp").snapshots();
  }

  sendMessage(String groupID, Map<String, dynamic> messageMap) async {
    var group = groupCollection.doc(groupID);
    group.collection("messages").add(messageMap);
    group.update({
      "lastMessage": messageMap["message"],
      "lastMessageSender": messageMap["sender"],
      "lastMessageTimeStamp": messageMap["timeStamp"],
    });
  }
}