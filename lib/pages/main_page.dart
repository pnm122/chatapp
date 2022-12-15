import 'dart:async';

import 'package:chatapp/consts.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/widgets/groups.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:chatapp/pages/login_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:html' as html;

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.viewModel});
  final viewModel;

  @override
  Widget build(BuildContext context) {
    // Set active state of user depending on the window state
    // Put this inside MainPage since the user is guaranteed to be logged in here
    html.window.onBeforeUnload.listen((event) async {
      await DatabaseService().setInactive();
    });
    html.window.onBlur.listen((event) async {
      await DatabaseService().setInactive();
    });
    html.window.onFocus.listen((event) async {
      await DatabaseService().setActive();
    });


    var provider = Provider.of<AuthService>(context, listen: false);

    var selectedGroupName = context.watch<MainViewModel>().selectedGroupName;

    // Ask the user to create a username after creating an account
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(provider.user != null && provider.user!.additionalUserInfo!.isNewUser) {
        TextEditingController _controller = TextEditingController();

        pushPopUp(context, Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                textAlign: TextAlign.center,
                controller: _controller,
                style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  hintText: "Give yourself a name...",
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 16.0),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  if(_controller.text.isNotEmpty) {
                    DatabaseService().setDisplayName(_controller.text);
                    _controller.dispose();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Let's chat!"),
              ),
            ],
          )
        ), "Create A Username", false);
      }
    });

    return Row(
      children: [
        MediaQuery.of(context).size.width > Consts.cutoffWidth
          ? const Groups()
          : Container(),

        // Use expanded so it doesn't overflow (bc the other row element is a sizedbox)
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                Consts.shadow
              ]
            ),
            child: ChatPage(viewModel: viewModel),
          ),
        ),
      ],
    );
  }
}