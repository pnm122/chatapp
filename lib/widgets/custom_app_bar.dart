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
      titleTextStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w700),
      title: title,
      centerTitle: centerTitle,
      actions: actions,
      bottom: const BottomDivider()
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(50);
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