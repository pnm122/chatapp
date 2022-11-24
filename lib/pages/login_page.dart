import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/pages/chat_room.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  bool _isLoading = false;

  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return _isLoading 
    ? const Center(child: CircularProgressIndicator())
    : Container(
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
      
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Text(
              "Sign in",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 32.0),

            TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                filled: true,
                fillColor: const Color.fromARGB(16, 0, 0, 0),
                hintText: "Enter a username",

                errorStyle: TextStyle(height: 0.8),
              ),
              onSaved: (value){displayName = value!;},
              
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return "Please enter a username";
                }
                return null;
              }
            ),

            const SizedBox(height: 16.0),

            // Form submission button
            ElevatedButton(
              onPressed: () async {
                if(_formKey.currentState!.validate()) {
                  setState(() { _isLoading = true; });

                  _formKey.currentState!.save();

                  await _auth.signInAnonymously(displayName)
                    .then((value) async {
                      if(value != null) {
                        await HelperFunctions.saveUserLoggedInStatus(true);
                        await HelperFunctions.saveDisplayName(displayName);
                        pushScreenReplace(context, const ChatRoom());
                      } else {
                        setState(() { _isLoading = false; });
                      }
                    });
                  /*showModalBottomSheet(
                    context: context, 
                    builder: ((context) => Container(
                      padding: const EdgeInsets.all(16),
                      child: result == null 
                        ? const Text("Sign in unsuccessful")
                        : const Text("Successfully signed in"),
                    )),
                  );*/
                }
              },

              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),

              child: Text("Start chatting!"),

            ),
          ],
        ),
      ),
    );
  }
}