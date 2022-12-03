import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/consts.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class Groups extends StatefulWidget {
  const Groups({super.key});

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  Stream<QuerySnapshot>? groups;

  @override
  void initState() {
    super.initState();
    DatabaseService().getCurrentUserGroups().then((groups) {
      setState(() {
        this.groups = groups;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Scaffold(
        appBar: const CustomAppBar(
          centerTitle: true,
          title: Text("Your Groups"),
        ),
        body: Container(
          padding: Consts.groupSectionPadding,
          color: Colors.white,
          child: StreamBuilder(
              stream: groups,
              builder:(context, AsyncSnapshot snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if(snapshot.hasData && snapshot.data.docs.length > 0) {
                  // make first item an add group button
                  return Column(
                    children: [
                      CreateGroupButton(),
                      ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          String id = snapshot.data.docs[index]["id"];
                          Stream<DocumentSnapshot> g = DatabaseService().getGroup(id);
                          return StreamBuilder(
                            stream: g,
                            builder: ((context, AsyncSnapshot snapshot) {
                              if(snapshot.hasData) {
                                return Text(snapshot.data["name"]);
                              } else {
                                return Container();
                              }
                            })
                          );
                        },
                      )
                    ]
                  );
                } else { 
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("You haven't joined any groups yet."),
                      SizedBox(height: 5.0),
                      CreateGroupButton()
                    ]
                  );
                }
              },
            ),
        )
      ),
    );
  }
}

class CreateGroupButton extends StatefulWidget {
  const CreateGroupButton({super.key});

  @override
  State<CreateGroupButton> createState() => _CreateGroupButtonState();
}

class _CreateGroupButtonState extends State<CreateGroupButton> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {

    return InkWell(
      onHover: (value) {
        setState(() {
          hover = value;
        });
      },
      onTap: () {
        showGeneralDialog(
          barrierColor: const Color.fromARGB(175, 0, 0, 0),
          context: context, 
          pageBuilder: ((context, animation, secondaryAnimation) {
            return const CreateGroupPopUp();
          })
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Create a group",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )
          ),
          Icon(
            hover ? Icons.add_circle : Icons.add_circle_outline,
            size: 20.0,
            color: Theme.of(context).colorScheme.primary
          )
        ],
      ),
    );
  }
}

class CreateGroupPopUp extends StatefulWidget {
  const CreateGroupPopUp({super.key});

  @override
  State<CreateGroupPopUp> createState() => _CreateGroupPopUpState();
}

class _CreateGroupPopUpState extends State<CreateGroupPopUp> {
  final TextEditingController _controller = TextEditingController();
  String abbreviation = "G";

  @override
  void initState() {
    super.initState();
    _controller.addListener(_abbreviate);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _abbreviate() {
    setState(() {
      abbreviation = HelperFunctions.abbreviate(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Do this so there is a material widget ancestor for things to behave properly
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        color: Colors.white,
        // Use this to minimize height to fit content
        child: Wrap(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade500,
                          foregroundColor: Colors.black,
                          radius: 45,
                          child: Text(abbreviation, style: Theme.of(context).textTheme.headline4)
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () { Navigator.pop(context); }
                        ),
                      )
                    ],
                  ),
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: _controller,
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: "Give your group a name...",
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 16.0),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      DatabaseService().createGroup(_controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text("Create group"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}