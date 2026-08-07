import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';

enum MainTab { home, quran, qibla, saved, more }

SystemUiOverlayStyle dqSystemUiOverlay(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.darkCard,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    );
  }
  return const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );
}

class DqBottomNav extends StatelessWidget {
  const DqBottomNav({
    super.key,
    required this.activeTab,
    this.onTabSelected,
  });

  final MainTab activeTab;
  final ValueChanged<MainTab>? onTabSelected;

  static const _items = [
    (MainTab.home, 'Home', Icons.home_outlined, Icons.home_rounded),
    (MainTab.quran, 'Quran', Icons.menu_book_outlined, Icons.menu_book_rounded),
    (MainTab.qibla, 'Qibla', Icons.explore_outlined, Icons.explore_rounded),
    (MainTab.saved, 'Saved', Icons.favorite_border_rounded, Icons.favorite_rounded),
    (MainTab.more, 'More', Icons.menu_rounded, Icons.menu_rounded),
  ];

  String _pathFor(MainTab tab) => switch (tab) {
        MainTab.home => '/home',
        MainTab.quran => '/quran',
        MainTab.qibla => '/qibla',
        MainTab.saved => '/saved',
        MainTab.more => '/more',
      };

  @override
  Widget build(BuildContext context) {
    final dq = DqTheme.of(context);
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: dq.cardBorder)),
      ),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _items.map((item) {
          final (tab, label, icon, activeIcon) = item;
          final isActive = activeTab == tab;
          final color = isActive ? colors.onSurface : dq.muted;
          return Semantics(
            button: true,
            selected: isActive,
            label: label,
            child: InkWell(
              onTap: () {
                if (onTabSelected != null) {
                  onTabSelected!(tab);
                } else {
                  context.go(_pathFor(tab));
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 52,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isActive ? activeIcon : icon, size: 22, color: color),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                    ),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: AppColors.yellow, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DqShell extends StatelessWidget {
  const DqShell({super.key, required this.activeTab, required this.child});

  final MainTab activeTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dqSystemUiOverlay(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(child: child),
        bottomNavigationBar: DqBottomNav(activeTab: activeTab),
      ),
    );
  }
}

class DqTabScaffold extends StatelessWidget {
  const DqTabScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final tab = MainTab.values[navigationShell.currentIndex];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dqSystemUiOverlay(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(child: navigationShell),
        bottomNavigationBar: DqBottomNav(
          activeTab: tab,
          onTabSelected: (selected) => navigationShell.goBranch(
            MainTab.values.indexOf(selected),
            initialLocation: selected == tab,
          ),
        ),
      ),
    );
  }
}
