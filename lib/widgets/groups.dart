import 'package:flutter/material.dart';
import 'package:chatapp/consts.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';

class Groups extends StatelessWidget {
  const Groups({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Scaffold(
        appBar: const CustomAppBar(
          centerTitle: true,
          title: Text("Your Groups"),
        ),
        body: Container(color: Colors.red)
      ),
    );
  }
}