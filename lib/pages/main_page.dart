import 'dart:async';

import 'package:chatapp/consts.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/pages/info_page.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:html' as html;

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.viewModel});
  final viewModel;

  @override
  Widget build(BuildContext context) {
    bool active = true;
    String selectedGroupId = context.read<MainViewModel>().selectedGroupId;

    html.window.onBeforeUnload.listen((event) async {
      active = false;
      await DatabaseService().setInactive();
      // seems to never make it here :(
      await DatabaseService().readAllMessages(selectedGroupId);
    });
    html.window.onBlur.listen((event) {
      active = false;
      InactiveTimer.set(() { 
        DatabaseService().setInactive(); 
      });
    });
    html.window.onFocus.listen((event) {
      InactiveTimer.cancel();
      if(!active) {
        active = true;
        DatabaseService().setActive();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DatabaseService().getCurrentUserName().then((value) {
        // set current username here so we don't have to keep reading from the database every time we need it
        context.read<MainViewModel>().currentUserName = value;
        
        if(value.isNotEmpty) return;

        // Ask the user to create a username after creating an account (displayName is only empty right after making an account)

        TextEditingController _controller = TextEditingController();

        pushSpecialScreen(context, Container(
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
                    context.read<MainViewModel>().currentUserName = _controller.text;
                    _controller.dispose();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Let's chat!"),
              ),
            ],
          )
        ), "Create A Username");
      });
    });

    return Row(
      children: [
        MediaQuery.of(context).size.width > Consts.cutoffWidth
          ? const InfoPage()
          : Container(),

        // Use expanded so it doesn't overflow (bc the other row element is a sizedbox)
        Expanded(
          child: ChatPage(viewModel: viewModel),
        ),
      ],
    );
  }
}