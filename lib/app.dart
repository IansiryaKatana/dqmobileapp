import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_state_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/auth_repository.dart';
import 'core/services/auth_session_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_strings.dart';

class DonateQuranApp extends ConsumerStatefulWidget {
  const DonateQuranApp({super.key});

  @override
  ConsumerState<DonateQuranApp> createState() => _DonateQuranAppState();
}

class _DonateQuranAppState extends ConsumerState<DonateQuranApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService.init(ref.read(routerProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authSessionProvider);
    final router = ref.watch(routerProvider);
    final appState = ref.watch(appStateProvider);
    final bootstrap = ref.watch(authBootstrapProvider);
    final online = ref.watch(connectivityProvider).maybeWhen(data: (v) => v, orElse: () => true);

    return MaterialApp.router(
      title: 'Donate Quran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: appState.isDark ? ThemeMode.dark : ThemeMode.light,
      locale: AppStrings(appState.language).isRtl ? const Locale('ar') : const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('ur')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        if (bootstrap.isLoading) {
          return const Material(child: Center(child: CircularProgressIndicator()));
        }
        return Directionality(
          textDirection: AppStrings(appState.language).isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              if (!online)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: AppColors.destructive,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You are offline. Some features may be unavailable.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
