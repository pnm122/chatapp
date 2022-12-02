import 'package:chatapp/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'database_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //_firebaseAuth.currentUser.updateDisplayName(displayName)

  UserCredential? _user;

  UserCredential get user => _user!;

  Future createAccountWithEmailAndPass(String email, String pass) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: pass
      ).then((credential) {
        _user = credential;
        return null;
      },);
    } on FirebaseAuthException catch(e) {
      return e.code;
    }
  }

  Future signInWithEmailAndPass(String email, String pass) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: pass
      ).then((credential) {
        _user = credential;
        return null;
      },);
    } on FirebaseAuthException catch(e) {
      return e.code;
    }
  }

  Future signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();
    if(account == null) return null;

    final auth = await account.authentication;
    try {
      _user = await _firebaseAuth.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: auth.idToken,
          accessToken: auth.accessToken
        )
      );

      print("${user.additionalUserInfo?.username} : ${user.additionalUserInfo?.isNewUser}");
      return _user;
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