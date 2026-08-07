import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded }

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.maxContentWidth = 720,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;
  final double maxContentWidth;

  static ScreenSize sizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 840) return ScreenSize.expanded;
    if (width >= 600) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  static bool isTablet(BuildContext context) => sizeOf(context) != ScreenSize.compact;

  @override
  Widget build(BuildContext context) {
    final size = sizeOf(context);
    final child = switch (size) {
      ScreenSize.compact => compact,
      ScreenSize.medium => medium ?? compact,
      ScreenSize.expanded => expanded ?? medium ?? compact,
    };

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
