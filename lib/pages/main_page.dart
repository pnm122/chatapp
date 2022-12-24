import 'dart:async';

import 'package:chatapp/constants/consts.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/pages/info_page.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/viewmodels/chat_page_view_model.dart';
import 'package:chatapp/widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:html' as html;

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.viewModel});
  final MainViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    bool active = true;
    String selectedGroupId = context.read<MainViewModel>().selectedGroupId;
    final ChatPageViewModel chatPageViewModel = ChatPageViewModel();

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
        pushSpecialScreen(context, 
          // Wrap the viewmodel around this screen b/c I call a function to set the current user name in the viewmodel
          ChangeNotifierProvider<MainViewModel>.value(
            value: viewModel,
            child: const SetDisplayNameScreen()
          ), 
          "Create A Display Name", 
          false
        );
      });
    });

    return Row(
      children: [
        MediaQuery.of(context).size.width > Consts.cutoffWidth
          ? const InfoPage()
          : Container(),

        // Use expanded so it doesn't overflow (bc the other row element is a sizedbox)
        Expanded(
          child: ChangeNotifierProvider(
            create: (context) => chatPageViewModel,
            child: ChatPage(mainViewModel: viewModel, chatPageViewModel: chatPageViewModel)
          ),
        ),
      ],
    );
  }
}

class SetDisplayNameScreen extends StatefulWidget {
  const SetDisplayNameScreen({super.key});

  @override
  State<SetDisplayNameScreen> createState() => _SetDisplayNameScreenState();
}

class _SetDisplayNameScreenState extends State<SetDisplayNameScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.addListener(textChanged);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _controller.removeListener(textChanged);
  }

  textChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        SpecialScreenFormField(
          controller: _controller, 
          title: "Name", 
          maxLength: Consts.maxDisplayNameLength,
          hintText: "Give yourself a name..."
        ),

        SpecialScreenButton(
          onPressed: _controller.text.isEmpty ? null : () {
            context.read<MainViewModel>().currentUserName = _controller.text;
            DatabaseService().setDisplayName(_controller.text);
            Navigator.pop(context);
          },
          controller: _controller,
          title: "Start Chatting!",
        ),
      ],
    );
  }
}