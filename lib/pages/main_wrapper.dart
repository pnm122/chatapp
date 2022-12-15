import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/pages/main_page.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final viewModel = MainViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        // listen for changes on authentication state, and decide what to show based on that
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if(snapshot.hasData) {
            return ChangeNotifierProvider(
              create: (context) => viewModel,
              child: MainPage(viewModel: viewModel),
            );
          } else if(snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          } else {
            return const LoginPage();
          }
        }
      ),
    );
  }
}

class Tester extends StatelessWidget {
  const Tester({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().getUserGroups(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(snapshot.data[index].data().toString()),
              );
            },
          );
        } else { return CircularProgressIndicator(); }
      },
    );
  }
}