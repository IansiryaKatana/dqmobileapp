import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/utils/error_messages.dart';
import '../../shared/utils/validators.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/services/auth_repository.dart';
import '../../core/services/content_repository.dart';
import '../../core/services/content_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';
import '../../shared/widgets/dq_logo.dart';
import '../../shared/widgets/figma_components.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _email.text.trim(),
            password: _password.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorMessages.friendly(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (Validators.email(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your email above first')));
      return;
    }
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorMessages.friendly(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
                child: Row(
                  children: [
                    DqBackButton(onPressed: () => context.pop()),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.sand,
                        foregroundColor: AppColors.muted,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Skip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.yellow.withValues(alpha: 0.25)),
                            ),
                            child: const Icon(Icons.menu_book_rounded, size: 30, color: AppColors.yellow),
                          ),
                          const SizedBox(height: 16),
                          const DqLogo(size: LogoSize.large),
                          const SizedBox(height: 16),
                          const Text('Welcome Back', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
                          const SizedBox(height: 4),
                          const Text('Sign in to your account', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    DqAuthField(controller: _email, hint: 'Email address', keyboardType: TextInputType.emailAddress, validator: Validators.email),
                    const SizedBox(height: 12),
                    DqAuthField(
                      controller: _password,
                      hint: 'Password',
                      obscure: _obscure,
                      validator: Validators.password,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.muted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(onPressed: _forgotPassword, child: const Text('Forgot Password?', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600))),
                    ),
                    DqPrimaryButton(label: _loading ? 'Signing in...' : 'Sign In', onPressed: _loading ? null : _login),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(fontSize: 12, color: AppColors.muted))),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => context.push('/signup'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Create an Account', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(onPressed: () => context.go('/home'), child: const Text('Continue as Guest', style: TextStyle(color: AppColors.muted))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agreed = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to the Terms & Privacy Policy')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signUp(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorMessages.friendly(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
                child: DqBackButton(onPressed: () => context.pop()),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const DqLogo(size: LogoSize.large),
                          const SizedBox(height: 16),
                          const Text('Create Account', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
                          const SizedBox(height: 4),
                          const Text('Join the Donate Quran community', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    DqAuthField(controller: _name, hint: 'Full Name', validator: Validators.name),
                    const SizedBox(height: 12),
                    DqAuthField(controller: _email, hint: 'Email Address', keyboardType: TextInputType.emailAddress, validator: Validators.email),
                    const SizedBox(height: 12),
                    DqAuthField(
                      controller: _password,
                      hint: 'Password',
                      obscure: _obscure,
                      validator: Validators.password,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.muted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DqAuthField(
                      controller: _confirm,
                      hint: 'Confirm Password',
                      obscure: _obscureConfirm,
                      validator: (v) => Validators.required(v, field: 'Confirm password'),
                      suffix: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.muted),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => setState(() => _agreed = !_agreed),
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: _agreed ? AppColors.yellow : AppColors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _agreed ? AppColors.yellow : AppColors.border, width: 1.5),
                            ),
                            child: _agreed ? const Icon(Icons.check, size: 14, color: AppColors.navy) : null,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.muted),
                                children: [
                                  TextSpan(text: 'I agree to the '),
                                  TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600)),
                                  TextSpan(text: ' and '),
                                  TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    DqPrimaryButton(label: _loading ? 'Creating...' : 'Create Account', onPressed: _loading ? null : _signup),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: 13, color: AppColors.muted),
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(text: 'Sign In', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final user = appState.user;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
              child: Row(
                children: [
                  DqBackButton(onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  const Text('Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.sand,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: const Icon(Icons.person_outline, size: 32, color: AppColors.muted),
                      ),
                      const SizedBox(height: 10),
                      if (user != null) ...[
                        Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
                        Text(user.email, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => context.push('/profile/edit'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.navy),
                          child: const Text('Edit profile'),
                        ),
                      ] else ...[
                        const Text('Guest User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
                        const SizedBox(height: 8),
                        DqPrimaryButton(label: 'Sign In / Register', onPressed: () => context.push('/login')),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  const DqSectionLabel('History'),
                  DqMenuGroup(
                    items: [
                      DqMenuItem(label: 'Donation History', onTap: () => context.push('/profile/donations')),
                      DqMenuItem(label: 'Order History', onTap: () => context.push('/profile/orders')),
                      DqMenuItem(label: 'Receipts', onTap: () => context.push('/profile/receipts')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const DqSectionLabel('Quran'),
                  DqMenuGroup(
                    items: [
                      DqMenuItem(label: 'Bookmarks', onTap: () => context.go('/saved'), icon: Icons.bookmark_outline),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const DqSectionLabel('Preferences'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _ProfileRow(label: 'Language', trailing: Text(appState.language, style: const TextStyle(fontSize: 13, color: AppColors.muted)), onTap: () => context.push('/language')),
                        const Divider(height: 1, color: AppColors.border),
                        _ProfileRow(
                          label: 'Notifications',
                          trailing: const Icon(Icons.chevron_right, size: 15, color: AppColors.muted),
                          onTap: () => context.push('/profile/notifications'),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _ProfileRow(
                          label: 'Dark Mode',
                          trailing: Switch(
                            value: appState.isDark,
                            onChanged: (v) => ref.read(appStateProvider.notifier).setDark(v),
                            activeThumbColor: AppColors.navy,
                            activeTrackColor: AppColors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const DqSectionLabel('Account'),
                  DqMenuGroup(
                    items: [
                      DqMenuItem(label: 'Saved Addresses', onTap: () => context.push('/profile/addresses'), icon: Icons.location_on_outlined),
                      DqMenuItem(label: 'Privacy Policy', onTap: () => context.push('/privacy')),
                      DqMenuItem(label: 'Terms & Conditions', onTap: () => context.push('/terms')),
                      if (user != null) DqMenuItem(label: 'My Questions', onTap: () => context.push('/profile/questions'), icon: Icons.question_answer_outlined),
                    ],
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 12),
                    Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () async {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) context.go('/home');
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.logout, size: 16, color: AppColors.destructive),
                              SizedBox(width: 12),
                              Text('Log Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.destructive)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(appStateProvider).user;
    _name = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).updateProfile(name: _name.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorMessages.friendly(e);
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appStateProvider).user;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
              child: Row(
                children: [
                  DqBackButton(onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  const Text('Edit profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_saving,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Signed in as ${user?.email ?? '—'}',
                    style: const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.destructive, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  DqPrimaryButton(
                    label: _saving ? 'Saving…' : 'Save changes',
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, this.trailing, this.onTap});

  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.charcoal))),
              if (trailing != null) trailing! else const Icon(Icons.chevron_right, size: 15, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageSelectScreen extends ConsumerWidget {
  const LanguageSelectScreen({super.key});

  static const _languages = [
    ('English', '🇬🇧'),
    ('Arabic', '🇸🇦'),
    ('French', '🇫🇷'),
    ('Urdu', '🇵🇰'),
    ('Bengali', '🇧🇩'),
    ('Turkish', '🇹🇷'),
    ('Malay', '🇲🇾'),
    ('Indonesian', '🇮🇩'),
    ('German', '🇩🇪'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appStateProvider).language;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
              child: Row(
                children: [
                  DqBackButton(onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  const Icon(Icons.language, size: 18, color: AppColors.muted),
                  const SizedBox(width: 8),
                  const Text('Language', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'Select your preferred language. Arabic and Urdu use RTL layout. '
                'Most UI strings are still English — full translation packs are not shipped yet.',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: _languages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final (name, flag) = _languages[i];
                  final active = current == name;
                  return Material(
                    color: active ? AppColors.yellow.withValues(alpha: 0.1) : AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: () {
                        ref.read(appStateProvider.notifier).setLanguage(name);
                        context.pop();
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: active ? AppColors.yellow : AppColors.border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 14),
                            Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal))),
                            if (active)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(color: AppColors.yellow, shape: BoxShape.circle),
                                child: const Icon(Icons.check, size: 14, color: AppColors.navy),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  int? _openIdx;

  @override
  Widget build(BuildContext context) {
    final faqAsync = ref.watch(faqProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'FAQ', onBack: () => context.pop()),
            Expanded(
              child: faqAsync.when(
                loading: () => const DqLoadingOverlay(message: 'Loading FAQ...'),
                error: (_, __) => _faqList(context, ContentService.faq),
                data: (faqs) => _faqList(context, faqs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqList(BuildContext context, List<FaqItem> faqs) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...List.generate(faqs.length, (i) {
          final f = faqs[i];
          final open = _openIdx == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => setState(() => _openIdx = open ? null : i),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: open ? AppColors.yellow.withValues(alpha: 0.35) : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(f.question, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.charcoal)),
                            ),
                            Icon(open ? Icons.remove : Icons.add, size: 18, color: AppColors.navy),
                          ],
                        ),
                      ),
                      if (open)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(f.answer, style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.muted)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => context.push('/support'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent_outlined, color: AppColors.navy),
                  SizedBox(width: 12),
                  Expanded(child: Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w600))),
                  Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AboutUsScreen extends ConsumerWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final about = ref.watch(aboutCopyProvider).valueOrNull ?? AboutCopy.fallback;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: about.title, onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      about.body,
                      style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).updatePassword(_password.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully')));
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorMessages.friendly(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSession = ref.watch(authRepositoryProvider).hasRecoverySession;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DqScreenHeader(title: 'Reset Password', onBack: () => context.go('/login')),
                const SizedBox(height: 24),
                if (!hasSession)
                  const Expanded(
                    child: DqEmptyState(
                      icon: Icons.link_off,
                      title: 'Invalid or expired link',
                      message: 'Request a new password reset email from the login screen.',
                    ),
                  )
                else ...[
                  const Text('Choose a new password for your account.', style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'New password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    decoration: const InputDecoration(labelText: 'Confirm password'),
                    validator: (v) {
                      if (v != _password.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const Spacer(),
                  DqPrimaryButton(
                    label: _loading ? 'Updating...' : 'Update Password',
                    onPressed: _loading ? null : _submit,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
