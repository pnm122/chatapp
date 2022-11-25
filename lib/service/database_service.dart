import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = 
    FirebaseFirestore.instance.collection("users");

  final CollectionReference messageCollection = 
    FirebaseFirestore.instance.collection("messages");

  Future updateUserData(String displayName) async {
    return await userCollection.doc(uid).set({
      "uid": uid,
      "display_name": displayName,
    });
  }

  getMessages() async {
    return messageCollection.orderBy("timeStamp").snapshots();
  }
}