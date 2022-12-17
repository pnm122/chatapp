import 'package:chatapp/helper/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'database_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //_firebaseAuth.currentUser.updateDisplayName(displayName)

  Future<UserCredential> createAccountWithEmailAndPass(String email, String pass) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, 
      password: pass
    );
  }

  Future<UserCredential> signInWithEmailAndPass(String email, String pass) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email, 
      password: pass
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? auth = await account!.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: auth?.idToken,
      accessToken: auth?.accessToken
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}