import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/chat_room.dart';
import 'consts.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if(value != null) {
        setState(() {
          _isLoggedIn = value;
        });
      }
    });
    
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: const ColorScheme( 
          primary: Color.fromARGB(255, 0, 0, 0),
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
      ),
      home: _isLoggedIn ? const ChatRoom() : const LoginPage(),
    );
  }
}

