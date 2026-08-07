import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import 'content_repository.dart';

class NavigationMenuItem {
  const NavigationMenuItem({
    required this.id,
    required this.section,
    required this.label,
    required this.route,
    required this.icon,
    this.subtitle,
    this.badge,
  });

  final String id;
  final String section;
  final String label;
  final String route;
  final String icon;
  final String? subtitle;
  final String? badge;

  IconData get iconData => navigationIconFor(icon);
}

class MoreMenuData {
  const MoreMenuData({
    this.featured,
    this.actions = const [],
    this.learn = const [],
    this.support = const [],
    this.account = const [],
    this.usedFallback = false,
  });

  final NavigationMenuItem? featured;
  final List<NavigationMenuItem> actions;
  final List<NavigationMenuItem> learn;
  final List<NavigationMenuItem> support;
  final List<NavigationMenuItem> account;
  final bool usedFallback;
}

IconData navigationIconFor(String key) {
  return switch (key) {
    'volunteer_activism' => Icons.volunteer_activism_outlined,
    'local_shipping' => Icons.local_shipping_outlined,
    'mosque' => Icons.mosque_outlined,
    'help_outline' => Icons.help_outline_rounded,
    'storefront' => Icons.storefront_outlined,
    'public' => Icons.public_outlined,
    'water_drop' => Icons.water_drop_outlined,
    'menu_book' => Icons.menu_book_outlined,
    'quiz' => Icons.quiz_outlined,
    'support_agent' => Icons.support_agent_outlined,
    'info' => Icons.info_outline,
    'settings' => Icons.settings_outlined,
    'language' => Icons.language,
    'privacy_tip' => Icons.privacy_tip_outlined,
    'description' => Icons.description_outlined,
    'history' => Icons.history,
    'receipt' => Icons.receipt_long_outlined,
    'bookmark' => Icons.bookmark_outline,
    'notifications' => Icons.notifications_outlined,
    'location' => Icons.location_on_outlined,
    'self_improvement' => Icons.self_improvement_outlined,
    'question_answer' => Icons.question_answer_outlined,
    _ => Icons.chevron_right,
  };
}

abstract final class NavigationMenuFallback {
  static const featured = NavigationMenuItem(
    id: 'featured',
    section: 'featured',
    label: 'Umrah & Hajj Guide',
    route: '/umrah-hajj',
    icon: 'mosque',
    subtitle: 'Step by step pilgrimage guide',
    badge: 'Featured Guide',
  );

  static MoreMenuData get menu => MoreMenuData(
        featured: featured,
        actions: const [
          NavigationMenuItem(id: 'a1', section: 'actions', label: 'Donate', route: '/donate', icon: 'volunteer_activism'),
          NavigationMenuItem(id: 'a2', section: 'actions', label: 'Order Free Quran', route: '/order', icon: 'local_shipping'),
          NavigationMenuItem(id: 'a3', section: 'actions', label: 'Umrah & Hajj Guide', route: '/umrah-hajj', icon: 'mosque'),
          NavigationMenuItem(id: 'a4', section: 'actions', label: 'Ask a Scholar', route: '/ask-scholar', icon: 'help_outline'),
          NavigationMenuItem(id: 'a5', section: 'actions', label: 'Become a Distributor', route: '/distributor', icon: 'storefront'),
        ],
        learn: const [
          NavigationMenuItem(id: 'l1', section: 'learn', label: 'New Muslim Guide', route: '/new-muslim', icon: 'public'),
          NavigationMenuItem(id: 'l2', section: 'learn', label: 'How to Pray', route: '/how-to-pray', icon: 'self_improvement'),
          NavigationMenuItem(id: 'l3', section: 'learn', label: 'Books & Articles', route: '/learn', icon: 'menu_book'),
        ],
        support: const [
          NavigationMenuItem(id: 's1', section: 'support', label: 'FAQ', route: '/faq', icon: 'quiz'),
          NavigationMenuItem(id: 's2', section: 'support', label: 'Contact Us', route: '/support', icon: 'support_agent'),
          NavigationMenuItem(id: 's3', section: 'support', label: 'About Us', route: '/about', icon: 'info'),
        ],
        account: const [
          NavigationMenuItem(id: 'c1', section: 'account', label: 'Profile & Settings', route: '/profile', icon: 'settings'),
          NavigationMenuItem(id: 'c2', section: 'account', label: 'Language', route: '/language', icon: 'language'),
          NavigationMenuItem(id: 'c3', section: 'account', label: 'Privacy Policy', route: '/privacy', icon: 'privacy_tip'),
          NavigationMenuItem(id: 'c4', section: 'account', label: 'Terms & Conditions', route: '/terms', icon: 'description'),
        ],
        usedFallback: true,
      );
}

class NavigationRepository {
  NavigationRepository(this._client);

  final SupabaseClient? _client;

  Future<MoreMenuData> fetchMoreMenu() async {
    final client = _client;
    if (client == null) {
      return MoreMenuData(
        featured: NavigationMenuFallback.menu.featured,
        actions: NavigationMenuFallback.menu.actions,
        learn: NavigationMenuFallback.menu.learn,
        support: NavigationMenuFallback.menu.support,
        account: NavigationMenuFallback.menu.account,
        usedFallback: true,
      );
    }

    try {
      final rows = await client
          .from('navigation_menu_items')
          .select('id, section, label, route, icon, subtitle, badge')
          .eq('published', true)
          .order('sort_order');

      if (rows.isEmpty) {
        return MoreMenuData(
          featured: NavigationMenuFallback.menu.featured,
          actions: NavigationMenuFallback.menu.actions,
          learn: NavigationMenuFallback.menu.learn,
          support: NavigationMenuFallback.menu.support,
          account: NavigationMenuFallback.menu.account,
          usedFallback: true,
        );
      }

      final items = rows
          .map(
            (row) => NavigationMenuItem(
              id: row['id'] as String,
              section: row['section'] as String,
              label: row['label'] as String,
              route: row['route'] as String,
              icon: row['icon'] as String? ?? 'chevron_right',
              subtitle: row['subtitle'] as String?,
              badge: row['badge'] as String?,
            ),
          )
          .toList();

      NavigationMenuItem? featured;
      final actions = <NavigationMenuItem>[];
      final learn = <NavigationMenuItem>[];
      final support = <NavigationMenuItem>[];
      final account = <NavigationMenuItem>[];

      for (final item in items) {
        switch (item.section) {
          case 'featured':
            featured ??= item;
          case 'actions':
            actions.add(item);
          case 'learn':
            learn.add(item);
          case 'support':
            support.add(item);
          case 'account':
            account.add(item);
        }
      }

      return MoreMenuData(
        featured: featured ?? NavigationMenuFallback.featured,
        actions: actions.isEmpty ? NavigationMenuFallback.menu.actions : actions,
        learn: learn.isEmpty ? NavigationMenuFallback.menu.learn : learn,
        support: support.isEmpty ? NavigationMenuFallback.menu.support : support,
        account: account.isEmpty ? NavigationMenuFallback.menu.account : account,
      );
    } catch (e, st) {
      debugPrint('NavigationRepository.fetchMoreMenu: $e\n$st');
      return MoreMenuData(
        featured: NavigationMenuFallback.menu.featured,
        actions: NavigationMenuFallback.menu.actions,
        learn: NavigationMenuFallback.menu.learn,
        support: NavigationMenuFallback.menu.support,
        account: NavigationMenuFallback.menu.account,
        usedFallback: true,
      );
    }
  }
}

final navigationRepositoryProvider = Provider<NavigationRepository>((ref) {
  return NavigationRepository(EnvConfig.supabase);
});

final moreMenuProvider = FutureProvider<MoreMenuData>((ref) async {
  final data = await ref.watch(navigationRepositoryProvider).fetchMoreMenu();
  if (data.usedFallback) {
    ref.read(cmsFallbackFlagProvider.notifier).state = true;
  }
  return data;
});
