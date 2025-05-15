import 'package:flutter/material.dart';

class PveAppBar extends StatelessWidget implements PreferredSizeWidget {
  PveAppBar({
    super.key,
    this.title,
    this.automaticallyImplyLeading = true,
    this.elevation,
    this.leading,
    this.actions,
    this.centerTitle,
    this.bottom,
    this.toolbarHeight,
    this.backgroundColor,
    this.iconTheme,
  }) : preferredSize = Size.fromHeight((toolbarHeight ?? kToolbarHeight) +
            (bottom?.preferredSize.height ?? 0));

  final Widget? title;
  final double? elevation;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final Color? backgroundColor;
  final IconThemeData? iconTheme;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle ?? false,
      title: title,
      elevation: elevation ?? 0,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      backgroundColor: backgroundColor,
      iconTheme: iconTheme,
    );
  }
}
