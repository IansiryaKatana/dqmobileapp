import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_state_provider.dart';
import '../../core/services/content_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/dq_onboard_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(appStateProvider.notifier).completeOnboarding();
  }

  /// Guest path: finish onboarding → permissions → home.
  Future<void> _skipAsGuest() async {
    await _completeOnboarding();
    if (mounted) context.go('/permissions');
  }

  Future<void> _goSignup() async {
    await _completeOnboarding();
    if (mounted) context.go('/signup');
  }

  Future<void> _goLogin() async {
    await _completeOnboarding();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _OnboardIntroPage(
            onGetStarted: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            ),
          ),
          _OnboardWhyPage(
            onSkip: _skipAsGuest,
            onCreateAccount: _goSignup,
            onSignIn: _goLogin,
          ),
        ],
      ),
    );
  }
}

/// Screen 1 — layout matches exppppp.png
class _OnboardIntroPage extends ConsumerWidget {
  const _OnboardIntroPage({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = ref.watch(onboardingCopyProvider).valueOrNull ?? OnboardingCopy.fallback;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DqOnboardBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(28, 12, 28, 20 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                copy.brand,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(flex: 3),
              Text(
                copy.introTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                copy.introSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(height: 18),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onGetStarted,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          copy.introCta,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward, color: Colors.white.withValues(alpha: 0.95), size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen 2 — layout matches eeeeee.png
class _OnboardWhyPage extends ConsumerWidget {
  const _OnboardWhyPage({
    required this.onSkip,
    required this.onCreateAccount,
    required this.onSignIn,
  });

  final VoidCallback onSkip;
  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = ref.watch(onboardingCopyProvider).valueOrNull ?? OnboardingCopy.fallback;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DqOnboardBackground(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 20 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      copy.brand,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.black87, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(copy.skipLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              Text(
                copy.whyTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                copy.whySubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: onCreateAccount,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.onBrand,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: Text(copy.createAccountCta),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: onSignIn,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.yellow,
                    side: const BorderSide(color: AppColors.yellow, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: Text(copy.signInCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
