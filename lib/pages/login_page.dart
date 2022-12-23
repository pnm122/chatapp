import 'package:chatapp/constants/consts.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var isLoginForm = true;

  final _formKey = GlobalKey<FormState>();

  String userEmail = "";
  String userPass = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Consts.foregroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                width: 432, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isLoginForm ? "Sign in" : "Register",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 4),

                    RichText(
                      text: TextSpan(
                        text: isLoginForm
                          ? "Don't have an account already? "
                          : "Already have an account? ",
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: isLoginForm ? "Register" : "Sign in",
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  isLoginForm = !isLoginForm;
                                });
                              }
                          ),
                        ]
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          // E-mail field
                          TextFormField(
                            onSaved: (value) { userEmail = value!; },
                            validator: (value) {
                              if(value == null || 
                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                                return "Please enter a valid email address";
                              }
                            },
                            keyboardType: TextInputType.emailAddress, // Request e-mail-specific keyboard!
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
                            onSaved: (value) { userPass = value!; },
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

                          const SizedBox(height:12.0),

                          isLoginForm ? Container() : TextFormField(
                            validator: (value) {
                              if(value == null || value != userPass) {
                                return "Passwords must match";
                              }
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Confirm password",
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
                            onPressed: () async {
                              _formKey.currentState!.save();
                              if(_formKey.currentState!.validate()) {
                                // Use the same authservice provider for all authentication purposes!
                                var provider = Provider.of<AuthService>(context, listen: false);

                                isLoginForm 
                                ? await provider.signInWithEmailAndPass(userEmail, userPass).then((result) {
                                  DatabaseService().setActive();
                                }, onError: (e) { showError(e); }) 
                                : await provider.createAccountWithEmailAndPass(userEmail, userPass).then((result) {
                                  DatabaseService().createUser(result);
                                  DatabaseService().setActive();
                                }, onError: (e) { showError(e); });
                              }
                            },
                            child: Text(isLoginForm ? "Sign in" : "Register"),
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
                      onPressed: () async {
                        final provider = Provider.of<AuthService>(context, listen: false);
                        provider.signInWithGoogle().then((value) {
                          if(!isLoginForm) DatabaseService().createUser(value);
                          DatabaseService().setActive();
                        }, 
                        onError: (e) {});
                      },

                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color(0xFF397AF3),
                      ),

                      icon: const FaIcon(FontAwesomeIcons.google),
                      label: Text(isLoginForm ? "Sign in with Google" : "Register with Google"),

                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      )
    );
  }

  showError(FirebaseAuthException error) {
    showModalBottomSheet(
      context: context, 
      builder: ((context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          color: Theme.of(context).colorScheme.error,
          child: Text(
            error.message == null ? "Unknown Error" : error.message!, 
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onError),
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }
}