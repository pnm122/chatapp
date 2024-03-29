import 'package:chatapp/constants/consts.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.automaticallyImplyLeading, this.leading, this.title, this.centerTitle = false, this.actions, this.backgroundColor = Consts.foregroundColor, this.hasBottom = false, this.height = 65.0});
  final bool? automaticallyImplyLeading;
  final Widget? leading;
  final Widget? title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Color backgroundColor;
  final bool hasBottom;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      backgroundColor: backgroundColor,
      shadowColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.primary,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      leading: leading,
      titleTextStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
      title: title,
      centerTitle: centerTitle,
      actions: actions,
      bottom: hasBottom ? const BottomDivider() : null,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(height);
}

class BottomDivider extends StatelessWidget implements PreferredSizeWidget {
  const BottomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(1);
}