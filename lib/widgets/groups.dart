import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/widgets/widgets.dart';
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
  List<Stream> groups = List.empty(growable: true);

  @override
  void initState() {
    Stream<DocumentSnapshot> userInfo = DatabaseService().getCurrentUserInfo();
    userInfo.forEach((element) { 
      List groupIDs = ((element.data() as Map<String, dynamic>)["groups"]);
      for(var groupID in groupIDs) { groups.add(DatabaseService().getGroup(groupID)); }
      try { 
        setState(() {}); 
      } catch (e) {
        print(e);
      }
    });
    super.initState();
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
          color: Colors.white,
          // Outer StreamBuilder: list of all group ID's associated with this user
          // Get the group with this ID from the database
          // Use another StreamBuilder to pull the actual info from this group
          child: groups.isEmpty
            ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("You haven't joined any groups yet."),
                  SizedBox(height: 5.0),
                  NoGroupsJoinGroupButton(),
                  NoGroupsCreateGroupButton()
                ]
              )
            )
            : Column(
                children: [
                  NoGroupsJoinGroupButton(),
                  NoGroupsCreateGroupButton(),
                  ListView.builder(
                    itemCount: groups.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return StreamBuilder(
                        stream: groups[index],
                        builder:(context, AsyncSnapshot snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if(snapshot.hasData) {
                            return GroupTile(info: snapshot.data!.data(), index: index);
                          } else { 
                            return Container(); // ?
                          }
                        },
                      );
                    },
                    
                  ),
                ],
              ),
        )
      ),
    );
  }
}

class GroupTile extends StatefulWidget {
  const GroupTile({super.key, required this.info, required this.index});
  final Map<String, dynamic> info;
  final int index;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    int selectedIndex = context.watch<MainViewModel>().selectedIndex;
    return InkWell(
      onTap: () {
        context.read<MainViewModel>().setSelectedIndex(widget.index);
        context.read<MainViewModel>().setSelectedGroupId(widget.info["id"]);
      },
      child: Container(
        padding: Consts.groupTilePadding,
        color: widget.index == selectedIndex
          ? const Color.fromARGB(255, 245, 226, 208)
          : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: widget.index == selectedIndex ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
              foregroundColor: widget.index == selectedIndex ? Colors.white : Colors.black, // Not working?
              radius: 24,
              child: Text(HelperFunctions.abbreviate(widget.info["name"]), style: Theme.of(context).textTheme.headline6)
            ),

            const SizedBox(width: 8.0),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title of the group
                Text(
                  widget.info["name"],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 5.0),

                // Last message sent
                widget.info["lastMessage"] == ""
                  ? Text(
                      "No messages yet.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey, fontStyle: FontStyle.italic),
                    )
                  : Text(
                      widget.info["lastMessage"],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    )
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class NoGroupsJoinGroupButton extends StatefulWidget {
  const NoGroupsJoinGroupButton({super.key});

  @override
  State<NoGroupsJoinGroupButton> createState() => _NoGroupsJoinGroupButtonState();
}

class _NoGroupsJoinGroupButtonState extends State<NoGroupsJoinGroupButton> {
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
        pushPopUp(context, const JoinGroupPopUp());
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Join a group",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )
          ),
          Icon(
            hover ? Icons.add_circle : Icons.add,
            size: 20.0,
            color: Theme.of(context).colorScheme.primary
          )
        ],
      ),
    );
  }
}

class JoinGroupPopUp extends StatefulWidget {
  const JoinGroupPopUp({super.key});

  @override
  State<JoinGroupPopUp> createState() => _JoinGroupPopUpState();
}

class _JoinGroupPopUpState extends State<JoinGroupPopUp> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Stack(
        children: [
          Column(
            children: [
              TextFormField(
                textAlign: TextAlign.center,
                controller: _controller,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  hintText: "Enter the group ID",
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
                    DatabaseService().joinGroup(_controller.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Join group"),
              ),
            ],
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
    );
  }
}


class NoGroupsCreateGroupButton extends StatefulWidget {
  const NoGroupsCreateGroupButton({super.key});

  @override
  State<NoGroupsCreateGroupButton> createState() => _NoGroupsCreateGroupButtonState();
}

class _NoGroupsCreateGroupButtonState extends State<NoGroupsCreateGroupButton> {
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
        pushPopUp(context, const CreateGroupPopUp());
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
            hover ? Icons.create : Icons.create_outlined,
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          Stack(
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 193, 193, 193),
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
              if(_controller.text.isNotEmpty) {
                DatabaseService().createGroup(_controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Create group"),
          ),
        ],
      ),
    );
  }
}