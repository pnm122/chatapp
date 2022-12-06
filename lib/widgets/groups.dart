import 'dart:async';

import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/service/auth_service.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/viewmodels/main_view_model.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List groupIDs = List.empty(growable: true);
  List<Stream> groups = List.empty(growable: true);
  StreamSubscription? _subscription;

  @override
  void initState() {
    _subscription = DatabaseService().getCurrentUserInfo().listen((event) { 
      if(FirebaseAuth.instance.currentUser == null) { return; } // Avoid setState calls on the user logging out

      setState(() {
        if(event.data() != null) {
          groupIDs = (event.data() as Map<String, dynamic>)["groups"];
        }
      });
      groups = List.empty(growable: true);
      for(var id in groupIDs) {
        groups.add(DatabaseService().getGroup(id.toString()));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text(
            "Your Groups",
            style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
          ) ,
          backgroundColor: Consts.backgroundColor,
          actions: [
            Padding(
              padding: Consts.appBarIconPadding,
              child: const ActionButton(defaultIcon: Icons.add, hoverIcon: Icons.add_circle, popUpWidget: JoinGroupPopUp(), title: "Join Group"),
            ),
            Padding(
              padding: Consts.appBarIconPadding,
              child: const ActionButton(defaultIcon: Icons.create_outlined, hoverIcon: Icons.create, popUpWidget: CreateGroupPopUp(), title: "Create Group"),
            ),
            const Padding(padding: EdgeInsets.all(4.0)),
          ]
        ),
        body: Container(
          color: Consts.backgroundColor,
          // Outer StreamBuilder: list of all group ID's associated with this user
          // Get the group with this ID from the database
          // Use another StreamBuilder to pull the actual info from this group
          child: groupIDs.isEmpty
            ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("You haven't joined any groups yet."),
                  SizedBox(height: 5.0),
                  NoGroupsJoinGroupButton(),
                  SizedBox(height: 5.0),
                  NoGroupsCreateGroupButton()
                ]
              )
            )
            : ListView.builder(
              itemCount: groups.length + 1, // +1 to allow padding on the end of the list
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if(index == groups.length) { return const Padding(padding: EdgeInsets.all(4.0)); }
                return StreamBuilder(
                  stream: groups[index],
                  builder:(context, AsyncSnapshot snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: GroupTilePlaceholder());
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
        )
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  const ActionButton({super.key, required this.defaultIcon, required this.hoverIcon, required this.popUpWidget, required this.title});
  final IconData defaultIcon;
  final IconData hoverIcon;
  final Widget popUpWidget;
  final String title;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      decoration: const BoxDecoration(color: Consts.toolTipColor),
      message: widget.title,
      child: InkWell(
        onHover:(hover) {
          setState(() {
            hovering = hover;
          });
        },
        onTap: () {
          pushPopUp(context, widget.popUpWidget, widget.title, true);
        },
        child: Icon(
          hovering ? widget.hoverIcon : widget.defaultIcon,
          size: 28,
          color: Theme.of(context).colorScheme.primary,
        )
      ),
    );
  }
}

class GroupTilePlaceholder extends StatefulWidget {
  const GroupTilePlaceholder({super.key});

  @override
  State<GroupTilePlaceholder> createState() => _GroupTilePlaceholderState();
}

class _GroupTilePlaceholderState extends State<GroupTilePlaceholder> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Consts.groupTileHeight,
      padding: Consts.groupTilePadding,
      constraints: const BoxConstraints(minHeight: Consts.groupTileHeight),
      color: Consts.backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const ShimmerPlaceholder(
            height: 52,
            width: 52,
            isRounded: true,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ShimmerPlaceholder(
                  height: 12, 
                  width: 50, 
                  isRounded: false
                ),
                SizedBox(height: 3),
                ShimmerPlaceholder(
                  height: 12, 
                  width: 150, 
                  isRounded: false
                ),
              ],
            ),
          )
        ],
      )
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
  bool hovering = false;

  @override
  Widget build(BuildContext context) {

    int selectedIndex = context.watch<MainViewModel>().selectedIndex;

    return InkWell(
      onTap: () {
        // Don't need to load a new group page if it's already selected
        if(widget.index != selectedIndex) {
          context.read<MainViewModel>().setSelectedIndex(widget.index);
          context.read<MainViewModel>().setSelectedGroupId(widget.info["id"]);
          context.read<MainViewModel>().setSelectedGroupName(widget.info["name"]);

          // For when the groups page appears via button
          if(MediaQuery.of(context).size.width <= Consts.cutoffWidth) {
            Navigator.pop(context);
          }
        }
      },
      onHover: (hover) {
        setState(() {
          hovering = hover;
        });
      },
      child: AnimatedContainer(
        duration: Consts.animationDuration,
        padding: Consts.groupTilePadding,
        constraints: const BoxConstraints(minHeight: Consts.groupTileHeight),
        color: widget.index == selectedIndex
          ? Consts.selectedColor
          : hovering ? Consts.hoverColor : Consts.backgroundColor,
        
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: widget.index == selectedIndex ? Theme.of(context).colorScheme.primary : Color.fromARGB(44, 0, 0, 0),
              radius: 26,
              child: Text(
                HelperFunctions.abbreviate(widget.info["name"]),
                style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: widget.index == selectedIndex ? Colors.white : Colors.black,
                )
              )
            ),
        
            const SizedBox(width: 8.0),
        
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title of the group
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.info["name"],
                            maxLines: 1,
                            // ellipsis bugs out with custom font
                            overflow: TextOverflow.clip,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700, 
                              color: widget.index == selectedIndex ? Theme.of(context).colorScheme.primary : Colors.black,
                            ),
                          ),
                        ),
                        widget.info["lastMessage"] == "" ? Container() : Text(
                          HelperFunctions.timeStampToStringShort(widget.info["lastMessageTimeStamp"]),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black38, 
                          ),
                        ),
                      ],
                    ),
            
                    const SizedBox(height: 3.0),
            
                    // Last message sent
                    widget.info["lastMessage"] == ""
                      ? Text(
                          "No messages yet.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                            fontStyle: FontStyle.italic
                          ),
                        )
                      : RichText(
                          maxLines: 2,
                          // ellipsis bugs out with custom font
                          overflow: TextOverflow.clip,
                          text: TextSpan(
                            text: "${widget.info["lastMessageSender"]}: ",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: widget.info["lastMessage"],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black38, 
                                ),
                              ),
                            ]
                          ),
                      )
                  ],
                ),
              ),
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
        pushPopUp(context, const JoinGroupPopUp(), "Join Group", true);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Join a group",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            )
          ),
          Icon(
            hover ? Icons.add_circle : Icons.add,
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
      child: Column(
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
        pushPopUp(context, const CreateGroupPopUp(), "Create Group", true);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Create a group",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            )
          ),
          Icon(
            hover ? Icons.create : Icons.create_outlined,
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
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 193, 193, 193),
              foregroundColor: Colors.black,
              radius: 45,
              child: Text(abbreviation, style: Theme.of(context).textTheme.headline4)
            ),
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