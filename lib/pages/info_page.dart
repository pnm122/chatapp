import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:chatapp/widgets/groups.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/consts.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:chatapp/pages/login_page.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool editingDisplayName = false;

  String displayName = "";
  int userCreatedTime = -1;

  @override
  Widget build(BuildContext context) {
    DatabaseService().getCurrentUserInfo().first.then((value) { 
      setState(() {
        displayName = value["displayName"];
        userCreatedTime = value["createdTime"];
      });
    });
    
    /*.then((value) {
      setState(() {
        displayName = value;
      });
    });*/
    return SizedBox(
      width: 300,
      child: Scaffold(
        appBar: CustomAppBar(
          title: userCreatedTime != -1 ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            editingDisplayName 
                            ? IntrinsicWidth(
                              child: TextFormField(
                                initialValue: displayName,
                                maxLength: Consts.maxDisplayNameLength,
                                onFieldSubmitted: (name) {
                                  if(name.isNotEmpty) {
                                    DatabaseService().setDisplayName(name);
                                    setState(() {
                                      editingDisplayName = false;
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(6.0),
                                  counterText: "",
                                  isDense: true,
                                  filled: true,
                                  fillColor: Consts.inputBackgroundColor,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  )
                                ),
                                style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            )
                            // Allow the group name to be scrolled
                            : Text(
                              displayName,
                              style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4.0),
                            Tooltip(
                              message: editingDisplayName ? "Cancel Editing" : "Edit Display Name",
                              decoration: const BoxDecoration(color: Consts.toolTipColor),
                              // Use InkWell to get rid of extra padding
                              child: InkWell(
                                onTap: () {
                                  // tell UI to change Group Name to a text field to edit the name
                                  setState(() {
                                    editingDisplayName = !editingDisplayName;
                                  });
                                },
                                child: Icon(
                                  editingDisplayName ? Icons.close : Icons.create,
                                  size: 20
                                )
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                "User since ${HelperFunctions.timeStampToStringShort(userCreatedTime)}",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black54),
              )
            ],
          ) : Container(),
    
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: Consts.sideMargin),
              child: TextButton(
                onPressed: () {
                  DatabaseService().setInactive();
                  Provider.of<AuthService>(context, listen: false).signOut();
                  pushScreenReplace(context, const LoginPage());
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                  shadowColor: MaterialStateProperty.all(Colors.transparent), 
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 0))
                ),
                child: const Text("Log out"),
              ),
            ),
          ],
          hasBottom: true,
        ),
        body: const Groups(),
      ),
    );
  }
}