import 'package:chatapp/pages/main_wrapper.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'consts.dart';
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ONLY WORKS IN IOS + ANDROID: await Firebase.initializeApp();
  // This only works in web applications
  // If I want to support all platforms, i need to import foundation.dart and use if(kIsWeb) to determine which initializeApp call to use
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Consts.apiKey, 
      appId: Consts.appId, 
      messagingSenderId: Consts.messagingSenderId, 
      projectId: Consts.projectId
    ),
  );

  FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  // ANY DATABASE FUNCTIONS REQUIRE US TO BE SIGNED IN FIRST...
  /*html.window.onUnload.listen((event) async {
    print("Unload...");
    await DatabaseService().test();
  },);*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /*getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if(value != null) {
        setState(() {
          _isLoggedIn = value;
        });
      }
    });
  }*/
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        theme: ThemeData(
          colorScheme: const ColorScheme( 
            primary: Color.fromARGB(255, 255, 115, 0),
            onPrimary: Colors.white,
            secondary: Colors.white,
            onSecondary: Colors.black,
            error: Colors.red,
            onError: Colors.white,
            surface: Color.fromARGB(255, 240, 240, 240),
            onSurface: Colors.black,
            background: Colors.white,
            onBackground: Colors.black,
            brightness: Brightness.light
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 250, 246, 244),
        ),
        home: const MainWrapper(),
      ),
    );
  }
}

