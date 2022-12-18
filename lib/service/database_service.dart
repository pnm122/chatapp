import 'package:chatapp/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = 
    FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
    FirebaseFirestore.instance.collection("groups");

  createUser(UserCredential user) async {
    if(!verify()) return;

    await userCollection.doc(user.user?.uid).set({
      "displayName": "",
      "createdTime": DateTime.now().millisecondsSinceEpoch,
      "active": true,
      "groups": [],
    });
  }

  createGroup(String groupName) async {
    if(!verify()) return;

    DocumentReference group = await groupCollection.add({
      "name": groupName,
      "createdTime": DateTime.now().millisecondsSinceEpoch,
      "lastMessage": "",
      "lastMessageSender": "",
      "lastMessageTimeStamp": -1,
      "members": [FirebaseAuth.instance.currentUser!.uid],
      "numMessages": 0,
      // Also will have a collection of messages
    });

    // Add a count of messages read for this user
    await group.collection("messagesReadByUser").doc(FirebaseAuth.instance.currentUser!.uid).set({
      "numMessages": 0,
    });

    // Store the ID in the group as well so it's easier to pull out later
    await group.update({"id": group.id});

    String? uid = FirebaseAuth.instance.currentUser!.uid;
    await userCollection.doc(uid).update({
      "groups": FieldValue.arrayUnion([group.id])
    });
  }

  joinGroup(String groupID) async {
    if(!verify()) return;

    String id = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentReference group = groupCollection.doc(groupID);
      await group.update({
        "members": FieldValue.arrayUnion([id])
      });
      await userCollection.doc(id).update({
        "groups": FieldValue.arrayUnion([groupID])
      });
      await group.collection("messagesReadByUser").doc(FirebaseAuth.instance.currentUser!.uid).set({
        "numMessages": 0,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  renameGroup(String id, String name) async {
    if(!verify()) return;

    await groupCollection.doc(id).update({
      "name": name,
    });
  }

  Stream<DocumentSnapshot>? getCurrentUserInfo() {
    if(!verify()) return null;

    // Use instead of HelperFunctions method to get current user ID?
    String? uid = FirebaseAuth.instance.currentUser!.uid;
    return userCollection.doc(uid).snapshots();
  }

  getCurrentUserName() async {
    if(!verify()) return null;

    String? uid = FirebaseAuth.instance.currentUser!.uid;
    return await userCollection.doc(uid).get().then((value) => (value.data() as Map<String, dynamic>)["displayName"]);
  }

  Stream<DocumentSnapshot>? getGroup(String groupId) {
    if(!verify()) return null;

    return groupCollection.doc(groupId).snapshots();
  }

  Stream? getGroupUsers(String groupId) {
    if(!verify()) return null;

    return userCollection.snapshots().map((event) {
      List users = [];
      for(var doc in event.docs) {
        if((doc["groups"] as List).contains(groupId)) {
          users.add(doc);
        }
      }
      return users;
    });
  }

  Stream? getUserGroups() {
    if(!verify()) return null;

    // Get all groups that contain the current user's ID in them, then sort by most recent message
    // This list updates automatically thanks to snapshots()
    return groupCollection.snapshots().map((event) {
      List groups = [];
      for(var doc in event.docs) {
        if((doc["members"] as List).contains(FirebaseAuth.instance.currentUser!.uid)) {
          groups.add(doc);
        }
      }
      // Sort by most recent message
      // Note: not a stable sort method so groups without messages may rearrange? Not really important practically
      groups.sort((a, b) {
        return b["lastMessageTimeStamp"].compareTo(a["lastMessageTimeStamp"]);
      });
      return groups;
    });
    
  }

  Future setDisplayName(String displayName) async {
    if(!verify()) return;

    await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "displayName": displayName,
    });
  }

  Future setInactive() async {
    print(verify());
    if(!verify()) return;

    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;
    print("Working");
    await userCollection.doc(user.uid).update({
      "active": false,
    });
  }

  Future setActive() async {
    if(!verify()) return;

    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;
    await userCollection.doc(user.uid).update({
      "active": true,
    });
  }

  /// Update the number of messasges read for the current user to equal the total number of messages in the group
  readAllMessages(String groupID) {
    if(!verify()) return;

    var group = groupCollection.doc(groupID);
    group.get().then((value) {
      int totalMessages = (value.data() as Map)["numMessages"];
      group.collection("messagesReadByUser").doc(FirebaseAuth.instance.currentUser!.uid).update({
        "numMessages": totalMessages,
      });
    });
  }

  Future getNumberOfNewMessages(String groupID) async {
    if(!verify()) return;

    var group = groupCollection.doc(groupID);
    return await group.get().then((value) {
      int totalMessages = (value.data() as Map)["numMessages"];
      return group.collection("messagesReadByUser").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
        return totalMessages - (value.data() as Map)["numMessages"] as int;
      });
    });
  }

  getMessages(String groupID) {
    if(!verify()) return;

    if(groupID.isEmpty) return null;
    return groupCollection.doc(groupID).collection("messages").orderBy("timeStamp").snapshots();
  }

  Future getMessagesSince(String groupID, int timeStamp) async {
    if(!verify()) return;

    if(groupID.isEmpty) return "empty";
    return await groupCollection.doc(groupID).collection("messages").where("timeStamp", isGreaterThan: timeStamp).snapshots().length;
  }

  sendMessage(String groupID, Map<String, dynamic> messageMap) async {
    if(!verify()) return;

    var group = groupCollection.doc(groupID);
    // Increment the number of messages this user has seen as well, since they're on the page when the message is sent
    // Do this first to stop the new messages # from appearing on the UI
    group.collection("messagesReadByUser").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "numMessages": FieldValue.increment(1)
    });
    group.collection("messages").add(messageMap);
    group.update({
      "lastMessage": messageMap["message"],
      "lastMessageSender": messageMap["sender"],
      "lastMessageTimeStamp": messageMap["timeStamp"],
      "numMessages": FieldValue.increment(1),
    });
  }

  /// Verify if the user is currently logged. Returns true if logged in, false otherwise
  /// Doesn't seem to stop errors :(
  bool verify() {
    return FirebaseAuth.instance.currentUser != null;
  }
}