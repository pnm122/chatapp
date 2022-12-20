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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Consts.foregroundColor,
      appBar: CustomAppBar(
        height: 50,
        title: Text(
          "Your Groups",
          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: Consts.appBarIconPadding,
            child: const ActionButton(defaultIcon: Icons.group_add_outlined, hoverIcon: Icons.group_add, page: JoinGroupScreen(), title: "Join Group"),
          ),
          Padding(
            padding: Consts.appBarIconPadding,
            child: const ActionButton(defaultIcon: Icons.create_outlined, hoverIcon: Icons.create, page: CreateGroupScreen(), title: "Create Group"),
          ),
          const Padding(padding: EdgeInsets.all(4.0)),
        ]
      ),
      body: StreamBuilder(
        stream: DatabaseService().getUserGroups(),
        builder: (context, snapshot) {
          // Placeholder list of tiles
          if(snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return const GroupTilePlaceholder();
              },
            );
          }
          if(snapshot.connectionState == ConnectionState.active) {
            if(snapshot.data.length == 0) {
              return Center(
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
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return GroupTile(info: snapshot.data[index].data());
              },
            );
          } else {
            return const Center(child: Text("Error"));
          }
        },
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  const ActionButton({super.key, required this.defaultIcon, required this.hoverIcon, required this.page, required this.title});
  final IconData defaultIcon;
  final IconData hoverIcon;
  final Widget page;
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
          pushSpecialScreen(context, widget.page, widget.title);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        height: Consts.groupTileHeight,
        padding: Consts.groupTilePadding,
        constraints: const BoxConstraints(minHeight: Consts.groupTileHeight),
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
      ),
    );
  }
}

class GroupTile extends StatefulWidget {
  const GroupTile({super.key, required this.info});
  final Map<String, dynamic> info;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  bool hovering = false;
  Stream? numMessagesReadStream; 
  
  @override
  initState() {
    DatabaseService().getMessagesReadInGroup(widget.info["id"]).then((value) {
      setState(() {
        numMessagesReadStream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String selectedID = context.watch<MainViewModel>().selectedGroupId;
    bool selected = selectedID == widget.info["id"];
    int numMessages = widget.info["numMessages"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          // Don't need to load a new group page if it's already selected
          if(!selected) {
            // read all messages of the current group if it's selected
            String beforeSwitchGroupId = context.read<MainViewModel>().selectedGroupId;
            if(beforeSwitchGroupId.isNotEmpty) DatabaseService().readAllMessages(beforeSwitchGroupId);

            context.read<MainViewModel>().selectedGroupId = widget.info["id"];
            context.read<MainViewModel>().selectedGroupName = widget.info["name"];
            context.read<MainViewModel>().setSelectedGroupMembers(widget.info["members"]);
            // set user's read messages to all messages in the newly selected group
            DatabaseService().readAllMessages(widget.info["id"]);

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
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        
        child: AnimatedContainer(
          duration: Consts.animationDuration,
          padding: Consts.groupTilePadding,
          constraints: const BoxConstraints(minHeight: Consts.groupTileHeight),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
              ? Consts.selectedColor
              : hovering ? Consts.hoverColor : Consts.foregroundColor,
          ),
          
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: selected ? Theme.of(context).colorScheme.primary : Color.fromARGB(44, 0, 0, 0),
                radius: 26,
                child: Text(
                  HelperFunctions.abbreviate(widget.info["name"]),
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: selected ? Colors.white : Colors.black,
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
                                color: selected ? Theme.of(context).colorScheme.primary : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4.0),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          widget.info["lastMessage"] == ""
                            ? Expanded(
                              child: Text(
                                  "No messages yet.",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic
                                  ),
                                ),
                            )
                            : Expanded(
                              child: RichText(
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
                              ),
                            ),
                          StreamBuilder(
                            stream: numMessagesReadStream,
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.active) {
                                return NewMessagesBubble(
                                  numNewMessages: selected ? 0 : numMessages - snapshot.data.data()["numMessages"] as int
                                );
                              } else { return Container(); }
                            }
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        pushSpecialScreen(context, const JoinGroupScreen(), "Join a Group");
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

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ID", 
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 4),
            const Tooltip(
              preferBelow: false,
              decoration: BoxDecoration(color: Consts.toolTipColor),
              message: "Users who create a group can copy the group ID from the title above the chat room. Enter this ID to join that group!",
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.white,
              ),
            )
          ],
        ),
        TextFormField(
          textAlign: TextAlign.center,
          controller: _controller,
          cursorColor: Colors.white,
          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter the group ID...",
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.white70)
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.white)
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.0),
            isDense: true,
          ),
        ),

        const SizedBox(height: 16.0),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            disabledBackgroundColor: Colors.white70,
            backgroundColor: Colors.white,
          ),
          onPressed: _controller.text.isEmpty ? null : () {
            Navigator.pop(context);
            DatabaseService().joinGroup(_controller.text).then((success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? "Succesfully joined group" : "Failed to join group. The ID was probably invalid"),
                  backgroundColor: success ? Consts.successColor : Colors.red,
                )
              );
            });
          },
          child: Text(
            "Join Group",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _controller.text.isEmpty ? Colors.black54 : Consts.secondaryButtonColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
        pushSpecialScreen(context, const CreateGroupScreen(), "Create a Group");
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

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
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
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 209, 242, 226),
              border: Border.all(
                color: Colors.white,
                width: 6,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))
              ]
            ),
            child: Center(
              child: Text(
                abbreviation,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Consts.secondaryButtonColor),
              ),
            )
          ),
          const SizedBox(height: 16),
          // Title of the field input
          Text(
            "Name", 
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          TextFormField(
            maxLength: Consts.maxGroupNameLength,
            textAlign: TextAlign.center,
            controller: _controller,
            cursorColor: Colors.white,
            style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Give your group a name...",
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.white70)
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.white)
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.0),
              isDense: true,
              counterText: "",
            ),
          ),

          const SizedBox(height: 4.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${_controller.text.length}/${Consts.maxGroupNameLength}",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 20.0),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              disabledBackgroundColor: Colors.white70,
              backgroundColor: Colors.white,
            ),
            onPressed: _controller.text.isEmpty ? null : () {
              String name = _controller.text;
              Navigator.pop(context);
              DatabaseService().createGroup(name);
            },
            child: Text(
              "Create group",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _controller.text.isEmpty ? Colors.black54 : Consts.secondaryButtonColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}