import 'dart:async';

import 'package:chatapp/constants/consts.dart';
import 'package:chatapp/helper/helper_functions.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:chatapp/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

void pushScreen(context, page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page)
  );
}

void pushScreenReplace(context, page) {
  Navigator.pushReplacement(
    context, 
    MaterialPageRoute(builder: (context) => page)
  );
}

void pushSpecialScreen(context, page, String title, bool closeable) {
  double maxWidth = 300;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Theme.of(context).colorScheme.primary, Consts.gradientEndColor]
            )
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CustomAppBar(
              leading: closeable ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ) : Container(),
              title: Text(
                title,
                style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(Consts.sideMargin),
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      children: [
                        page,
                        // half of appbar height so that the page is centered on the whole page
                        const SizedBox(height: 32.5),
                      ]
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class SpecialScreenFormField extends StatelessWidget {
  const SpecialScreenFormField({super.key, required this.controller, required this.title, required this.hintText, this.maxLength, this.helpText});
  final TextEditingController controller;
  final String title;
  final String hintText;
  final int? maxLength;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title, 
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            helpText != null ? const SizedBox(width: 4) : Container(),
            helpText != null ? Tooltip(
              preferBelow: false,
              decoration: const BoxDecoration(color: Consts.toolTipColor),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              message: helpText,
              child: const Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.white,
              ),
            ) : Container(),
          ],
        ),
        TextFormField(
          textAlign: TextAlign.center,
          controller: controller,
          cursorColor: Colors.white,
          maxLength: maxLength,
          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white70),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.white70)
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.white)
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            isDense: true,
            counterStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

class SpecialScreenButton extends StatelessWidget {
  const SpecialScreenButton({super.key, required this.onPressed, required this.title, required this.controller});
  final VoidCallback? onPressed;
  final String title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),

        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            disabledBackgroundColor: Colors.white70,
            backgroundColor: Colors.white,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: controller.text.isEmpty ? Colors.black54 : Consts.secondaryButtonColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class InactiveTimer {
  static Timer? t;
  static set(void Function() callback) {
    // allow only one timer at a time
    if(t != null && t!.isActive) return;
    t = Timer(
      const Duration(minutes: 3),
      callback
    );
  }
  static cancel() {
    if(t == null) return;
    if(t!.isActive) t!.cancel();
  }
}

class ShimmerPlaceholder extends StatefulWidget {
  const ShimmerPlaceholder({super.key, required this.height, required this.width, required this.isRounded});

  final double height;
  final double width;
  final bool isRounded;

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  Animation? gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    gradientPosition = Tween<double>(
      begin: -2,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeOutExpo
      ),
    )..addListener(() {
      setState(() {});
    });

    _controller!.repeat();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width:  widget.width,
        height: widget.height, 
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(gradientPosition!.value, -0.3),
            end: Alignment(gradientPosition!.value + 1, 0.3),
            colors: const [Colors.black12, Color.fromARGB(12, 0, 0, 0), Colors.black12],
            stops: const [0.0, 0.5, 1],
          ),
          borderRadius: widget.isRounded
              ? const BorderRadius.all(Radius.circular(99))
              : const BorderRadius.all(Radius.circular(4.0)),
        ),
    );
  }
}

class NewMessagesBubble extends StatelessWidget {
  const NewMessagesBubble({super.key, required this.numNewMessages});
  final int numNewMessages;

  @override
  Widget build(BuildContext context) {
    return numNewMessages > 0 ? Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          numNewMessages > 9 ? "9+" : numNewMessages.toString(),
          style: numNewMessages > 9 
           ? const TextStyle(fontSize: 10, color: Colors.white)
           : Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
        ),
      ),
    ) : Container();
  }
}

class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.userData});
  final Map userData;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: userData["displayName"],
      decoration: const BoxDecoration(
        color: Consts.toolTipColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: Colors.grey.shade300,
              ),
              child: Center(
                child: Text(
                  HelperFunctions.abbreviate(userData["displayName"]),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)
                ),
              )
            ),
            // Active/Inactive bubble
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: userData["active"] ? const Color.fromARGB(255, 38, 208, 44) : Colors.grey,
                ),
              )
            )
          ],
        ),
      )
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key, required this.stream});
  final Stream? stream;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return Container(
              // Constraints = size of UserBubble
              // Should be a temporary fix but I really don't know how to fix the userbubble expanding to height otherwise
              constraints: const BoxConstraints(maxHeight: 56),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return UserBubble(userData: snapshot.data[index].data());
                }
              ),
            );
          } else { return Container(); }
        },
      ),
    );
  }
}