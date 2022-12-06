import 'package:chatapp/consts.dart';
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

void pushPopUp(context, page, String title, bool closeable) {
  double width = 300;
  showGeneralDialog(
    barrierColor: const Color.fromARGB(175, 0, 0, 0),
    context: context, 
    pageBuilder: ((context, animation, secondaryAnimation) {
      return Center(
        // Do this so there is a material widget ancestor for things to behave properly
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          color: Colors.white,
          // Use this to minimize height to fit content
          child: Wrap(
            children: [
              SizedBox(
                width: width,
                child: Column(
                  children: [
                    // Header for pop-up
                    Container(
                      color: Color.fromARGB(20, 0, 0, 0),
                      child: Stack(
                        children: [
                          Container(
                            height: 32,
                            alignment: Alignment.center,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          closeable ? Positioned(
                            height: 32,
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () { Navigator.pop(context); }
                            ),
                          ) : Container()
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    page
                  ],
                )
              )
            ]
          )
        )
      );
    })
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