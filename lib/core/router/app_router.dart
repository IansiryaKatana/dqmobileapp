import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state_provider.dart';
import '../../features/auth/auth_screens.dart';
import '../../features/donate/donate_screens.dart';
import '../../features/guides/how_to_pray_screen.dart';
import '../../features/guides/learn_article_screens.dart';
import '../../features/guides/logistics_screen.dart';
import '../../features/guides/umrah_hajj_screens.dart';
import '../../features/guides/wudu_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/more/more_screens.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/permissions_screen.dart';
import '../../features/order/order_screens.dart';
import '../../features/profile/profile_screens.dart';
import '../../features/qibla/prayer_times_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/quran/quran_screens.dart';
import '../../features/splash/splash_screen.dart';
import '../../shared/widgets/dq_bottom_nav.dart';
import '../../shared/widgets/dq_web_screen.dart';
import '../models/checkout_args.dart';
import '../services/content_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorQuranKey = GlobalKey<NavigatorState>(debugLabel: 'quran');
final _shellNavigatorQiblaKey = GlobalKey<NavigatorState>(debugLabel: 'qibla');
final _shellNavigatorSavedKey = GlobalKey<NavigatorState>(debugLabel: 'saved');
final _shellNavigatorMoreKey = GlobalKey<NavigatorState>(debugLabel: 'more');

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(appStateProvider.select((s) => s.onboardingComplete));
  final permissionsPromptComplete = ref.watch(appStateProvider.select((s) => s.permissionsPromptComplete));

  final user = ref.watch(appStateProvider.select((s) => s.user));

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/splash') return null;

      const authEntry = ['/login', '/signup'];
      final onAuthEntry = authEntry.any((p) => loc == p || loc.startsWith('$p/'));

      if (!onboardingComplete && !loc.startsWith('/onboarding') && !onAuthEntry) {
        return '/onboarding/1';
      }
      if (onboardingComplete &&
          !permissionsPromptComplete &&
          loc != '/permissions' &&
          !loc.startsWith('/onboarding') &&
          !onAuthEntry) {
        return '/permissions';
      }
      const authRequired = [
        '/profile/orders',
        '/profile/addresses',
        '/profile/questions',
      ];
      if (authRequired.any(loc.startsWith) && user == null) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding/1', builder: (_, __) => const OnboardingScreen()),
      GoRoute(
        path: '/onboarding/2',
        redirect: (_, __) => '/onboarding/1',
      ),
      GoRoute(path: '/permissions', builder: (_, __) => const PermissionsScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => DqTabScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorQuranKey,
            routes: [GoRoute(path: '/quran', builder: (_, __) => const QuranHomeScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorQiblaKey,
            routes: [GoRoute(path: '/qibla', builder: (_, __) => const QiblaScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSavedKey,
            routes: [GoRoute(path: '/saved', builder: (_, __) => const SavedScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMoreKey,
            routes: [GoRoute(path: '/more', builder: (_, __) => const MoreScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/quran/reader',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is QuranReaderArgs) {
            return QuranReaderScreen(
              surahNumber: extra.surahNumber,
              surahName: extra.surahName,
              initialAyah: extra.initialAyah,
            );
          }
          return QuranReaderScreen(surahNumber: 1, surahName: extra as String? ?? 'Al-Fatihah');
        },
      ),
      GoRoute(
        path: '/quran/juz',
        builder: (_, state) => JuzReaderScreen(juzNumber: state.extra as int? ?? 1),
      ),
      GoRoute(
        path: '/donate',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const DonateScreen(),
      ),
      GoRoute(
        path: '/donate/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is DonateCheckoutArgs) {
            return DonateCheckoutScreen(amount: extra.amount, frequency: extra.frequency);
          }
          return DonateCheckoutScreen(amount: extra as int? ?? 25, frequency: 'once');
        },
      ),
      GoRoute(
        path: '/donate/success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is DonateSuccessArgs) {
            return DonateSuccessScreen(amount: extra.amount, receiptId: extra.receiptId, email: extra.email);
          }
          return DonateSuccessScreen(amount: extra as int? ?? 25, receiptId: 'DQ-PENDING');
        },
      ),
      GoRoute(
        path: '/order',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const OrderScreen(),
      ),
      GoRoute(
        path: '/order/detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => OrderDetailScreen(title: state.extra as String? ?? '1 Free Quran Copy'),
      ),
      GoRoute(
        path: '/order/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra as OrderCheckoutArgs?;
          return OrderCheckoutScreen(
            title: extra?.title ?? '1 Free Quran Copy',
            language: extra?.language ?? 'English',
            quantity: extra?.quantity ?? 1,
          );
        },
      ),
      GoRoute(
        path: '/order/success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => OrderSuccessScreen(
          reference: (state.extra as OrderSuccessArgs?)?.reference ?? 'DQ-ORD-PENDING',
        ),
      ),
      GoRoute(
        path: '/umrah-hajj',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const UmrahHajjScreen(),
      ),
      GoRoute(
        path: '/guide/:slug',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final slug = state.pathParameters['slug']!;
          if (slug == 'logistics') return const LogisticsScreen();
          return GuideStepsScreen(slug: slug);
        },
      ),
      GoRoute(
        path: '/logistics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LogisticsScreen(),
      ),
      GoRoute(
        path: '/umrah-guide',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const UmrahGuideScreen(),
      ),
      GoRoute(
        path: '/hajj-guide',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const HajjGuideScreen(),
      ),
      GoRoute(
        path: '/ask-scholar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AskScholarScreen(),
      ),
      GoRoute(
        path: '/ask-scholar/success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ScholarSuccessScreen(
          referenceId: (state.extra as ScholarSuccessArgs?)?.referenceId ?? 'SQ-PENDING',
        ),
      ),
      GoRoute(
        path: '/new-muslim',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const NewMuslimScreen(),
      ),
      GoRoute(
        path: '/learn',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LearnScreen(),
      ),
      GoRoute(
        path: '/learn/article',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ArticleDetailScreen(articleId: state.extra as String? ?? 'fatihah'),
      ),
      GoRoute(path: '/what-is-islam', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const WhatIsIslamScreen()),
      GoRoute(path: '/what-is-quran', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const WhatIsQuranScreen()),
      GoRoute(path: '/who-is-prophet', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const WhoIsProphetScreen()),
      GoRoute(path: '/qibla/prayer-times', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const PrayerTimesScreen()),
      GoRoute(path: '/profile/donations', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const DonationHistoryScreen()),
      GoRoute(path: '/profile/orders', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const OrderHistoryScreen()),
      GoRoute(path: '/profile/addresses', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const SavedAddressesScreen()),
      GoRoute(path: '/profile/receipts', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const DonationHistoryScreen(receiptsOnly: true)),
      GoRoute(
        path: '/profile/receipt',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => ReceiptDetailScreen(args: state.extra as ReceiptDetailArgs),
      ),
      GoRoute(
        path: '/profile/order',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => OrderDetailHistoryScreen(args: state.extra as OrderDetailArgs),
      ),
      GoRoute(path: '/profile/questions', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const MyQuestionsScreen()),
      GoRoute(path: '/profile/notifications', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const NotificationsSettingsScreen()),
      GoRoute(path: '/profile/edit', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/reset-password', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const ResetPasswordScreen()),
      GoRoute(path: '/login', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/profile', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/language', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const LanguageSelectScreen()),
      GoRoute(path: '/faq', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const FaqScreen()),
      GoRoute(path: '/about', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const AboutUsScreen()),
      GoRoute(path: '/wudu-guide', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const WuduGuideScreen()),
      GoRoute(path: '/how-to-pray', parentNavigatorKey: _rootNavigatorKey, builder: (_, __) => const HowToPrayScreen()),
      GoRoute(
        path: '/privacy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const _CmsWebLinkScreen(title: 'Privacy Policy', linkKey: 'privacy'),
      ),
      GoRoute(
        path: '/terms',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const _CmsWebLinkScreen(title: 'Terms & Conditions', linkKey: 'terms'),
      ),
      GoRoute(
        path: '/distributor',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const _CmsWebLinkScreen(title: 'Become a Distributor', linkKey: 'distributor'),
      ),
      GoRoute(
        path: '/support',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const _CmsWebLinkScreen(title: 'Support', linkKey: 'support'),
      ),
    ],
  );
});

class _CmsWebLinkScreen extends ConsumerWidget {
  const _CmsWebLinkScreen({required this.title, required this.linkKey});

  final String title;
  final String linkKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(externalLinksProvider).valueOrNull ?? ExternalLinksCopy.fallback;
    return DqWebScreen(title: title, url: links.urlFor(linkKey));
  }
}

class QuranReaderArgs {
  const QuranReaderArgs({
    required this.surahNumber,
    required this.surahName,
    this.initialAyah,
  });

  final int surahNumber;
  final String surahName;
  final int? initialAyah;
}
