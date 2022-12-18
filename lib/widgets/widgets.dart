import 'package:chatapp/consts.dart';
import 'package:chatapp/helper/helper_functions.dart';
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

void pushSpecialScreen(context, page, String title) {
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
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              ),
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