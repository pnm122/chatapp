import 'package:chatapp/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'database_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //_firebaseAuth.currentUser.updateDisplayName(displayName)

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();
    if(account == null) return null;

    _user = account;

    final auth = await account.authentication;
    try {
      final user = await _firebaseAuth.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: auth.idToken,
          accessToken: auth.accessToken
        )
      );

      print("${user.additionalUserInfo?.username} : ${user.additionalUserInfo?.isNewUser}");
      return user;
    } on FirebaseAuthException catch(e) {
      //print(e.message);
      return null;
    }
  }

  Future signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch(e) {
      return null;
    }
  }
}