import 'dart:async';

import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:chatapp/pages/main_page.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'dart:html' as html;

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

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
            return const MainPageViewModelWrapper();
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

/// Used because MainViewModel gets disposed after an an auth state change, so it needs to be inside this wrapper to avoid trying to reuse after disposing
class MainPageViewModelWrapper extends StatelessWidget {
  const MainPageViewModelWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final viewModel = MainViewModel();
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: MainPage(viewModel: viewModel),
    );
  }
}