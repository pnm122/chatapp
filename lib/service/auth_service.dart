import 'package:chatapp/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future signInAnonymously(String displayName) async {
    try {
      User user = (await firebaseAuth.signInAnonymously()).user!;
      DatabaseService(uid: user.uid).updateUserData(displayName);
      await HelperFunctions.saveUserLoggedInStatus(true);
      await HelperFunctions.saveDisplayName(displayName);
      return user;

    } on FirebaseAuthException catch(e) {
      print(e);
      return null;
    }
  }

  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveDisplayName("");
      await firebaseAuth.signOut();
    } catch(e) {
      return null;
    }
  }
}