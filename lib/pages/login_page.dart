import 'package:chatapp/consts.dart';
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
              width: 400, 
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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(50, 0, 0, 0),
            blurRadius: 20.0,
            offset: Offset(2, 4),
          ),
        ],
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Sign in",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 32.0),

          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // E-mail field
                TextFormField(
                  validator: (value) {
                    if(value == null || 
                    !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)) {
                      return "Please enter a valid email address";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    filled: true,
                    fillColor: Consts.inputBackgroundColor,
                    contentPadding: Consts.inputPadding,
                  ),
                ),

                const SizedBox(height:12.0),
                // Password field
                TextFormField(
                  validator: (value) {
                    if(value == null || value.length < 8) {
                      return "Password must be at least 8 characters long";
                    }
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    filled: true,
                    fillColor: Consts.inputBackgroundColor,
                    contentPadding: Consts.inputPadding,
                  ),
                ),

                const SizedBox(height:24.0),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: (){
                    if(_formKey.currentState!.validate()) {
                      // Sign in via email and password
                    }
                  },
                  child: const Text("Sign in"),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: const <Widget>[
                Expanded(child: Divider()),
                SizedBox(width: 5.0),
                Text("OR"),
                SizedBox(width: 5.0),
                Expanded(child: Divider()),
              ],
            ),
          ),

          // Google sign in button
          ElevatedButton.icon(
            onPressed: () {
              final provider = Provider.of<AuthService>(context, listen: false);
              provider.signInWithGoogle();
            },

            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFF397AF3),
            ),

            icon: const FaIcon(FontAwesomeIcons.google),
            label: const Text("Sign in with Google"),

          ),
        ],
      ),
    );
  }
}