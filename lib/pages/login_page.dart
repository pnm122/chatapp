import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/pages/chat_room.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 350, 
              child: SignInForm()
            ),
          ],
        ),
      )
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {

  String displayName = "";

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(36, 0, 0, 0),
            blurRadius: 16.0,
            offset: Offset(2, 4),
          ),
        ],
      ),
      
      child: Column(
        children: <Widget>[
          const Text(
            "Sign in",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 32.0),

          ElevatedButton.icon(
            onPressed: () {
              final provider = Provider.of<AuthService>(context, listen: false);
              provider.signInWithGoogle();
            },

            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),

            icon: const FaIcon(FontAwesomeIcons.google),
            label: const Text("Sign in with Google"),

          ),
        ],
      ),
    );
  }
}