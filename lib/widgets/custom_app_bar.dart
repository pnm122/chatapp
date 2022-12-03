import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.leading, this.title, this.centerTitle, this.actions});
  final Widget? leading;
  final Widget? title;
  final bool? centerTitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.primary,
      leading: leading,
      title: title,
      centerTitle: centerTitle,
      actions: actions,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(50);
}