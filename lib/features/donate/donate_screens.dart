import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/checkout_args.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/services/bookmark_service.dart';
import '../../core/services/content_repository.dart';
import '../../core/services/donation_repository.dart';
import '../../core/services/purchase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/utils/error_messages.dart';
import '../../shared/utils/haptics.dart';
import '../../shared/utils/validators.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';
import '../../shared/widgets/geo_pattern.dart';

class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key});

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  int _amount = 25;
  String _custom = '';
  String _freq = 'once';
  final _amounts = [5, 10, 25, 50, 100];

  int get _selectedAmount => _custom.isNotEmpty ? int.tryParse(_custom) ?? _amount : _amount;

  @override
  Widget build(BuildContext context) {
    final copy = ref.watch(donateCopyProvider).valueOrNull ?? DonateCopy.fallback;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Donate', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          color: AppColors.navy,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(copy.heroTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                              Text(copy.heroSubtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                            ],
                          ),
                        ),
                        const Positioned.fill(child: IgnorePointer(child: GeoPattern())),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _freqToggle(),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [..._amounts.map(_amountChip), _customChip()],
                  ),
                  const SizedBox(height: 20),
                  ..._impactCards(copy),
                  const SizedBox(height: 16),
                  DqCard(
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppColors.yellow),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            copy.guestMessage,
                            style: TextStyle(fontSize: 13, color: context.dq.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DqCard(
                    child: Row(
                      children: [
                        const Icon(Icons.verified_outlined, color: AppColors.yellow),
                        const SizedBox(width: 12),
                        Expanded(child: Text(copy.tagline, style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DqPrimaryButton(
                label: 'Continue Donation — £$_selectedAmount',
                onPressed: () => context.push(
                  '/donate/checkout',
                  extra: DonateCheckoutArgs(amount: _selectedAmount, frequency: _freq),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _freqToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: context.dq.surfaceAlt, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.dq.cardBorder)),
      child: Row(
        children: ['once', 'monthly'].map((f) {
          final selected = _freq == f;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _freq = f),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? context.colors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  f == 'once' ? 'One-time' : 'Monthly',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: selected ? context.colors.primary : context.dq.muted),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _amountChip(int amount) {
    final selected = _custom.isEmpty && _amount == amount;
    return ChoiceChip(
      label: Text('£$amount'),
      selected: selected,
      onSelected: (_) => setState(() { _amount = amount; _custom = ''; }),
      selectedColor: AppColors.yellow,
      checkmarkColor: AppColors.onBrand,
      labelStyle: TextStyle(
        color: selected ? AppColors.onBrand : null,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _customChip() {
    return ActionChip(
      label: const Text('Custom'),
      onPressed: () async {
        final controller = TextEditingController();
        final value = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Custom amount'),
            content: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: '£'),
              validator: (v) => Validators.amount(v),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('OK')),
            ],
          ),
        );
        if (value != null && Validators.amount(value) == null) setState(() => _custom = value);
      },
    );
  }

  List<Widget> _impactCards(DonateCopy copy) {
    return copy.impactCards.map((i) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.dq.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(i.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(i.amountLabel, style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }).toList();
  }
}

class DonateCheckoutScreen extends ConsumerStatefulWidget {
  const DonateCheckoutScreen({super.key, required this.amount, required this.frequency});

  final int amount;
  final String frequency;

  @override
  ConsumerState<DonateCheckoutScreen> createState() => _DonateCheckoutScreenState();
}

class _DonateCheckoutScreenState extends ConsumerState<DonateCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _behalfNameController = TextEditingController();
  bool _onBehalf = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _behalfNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(appStateProvider).user;
      final purchased = await PurchaseService.processDonation(
        amountPence: widget.amount * 100,
        monthly: widget.frequency == 'monthly',
      );
      // Debug-only path: RC not configured → pending local stub (release throws above).
      if (!purchased && kReleaseMode) {
        throw Exception('Payment was not completed. Please try again.');
      }
      final metadata = <String, dynamic>{
        'donor_name': _nameController.text.trim(),
        'donor_email': _emailController.text.trim(),
        if (_onBehalf) 'on_behalf_of': _behalfNameController.text.trim(),
      };
      final receiptId = await ref.read(donationRepositoryProvider).createDonation(
            amountPence: widget.amount * 100,
            frequency: widget.frequency,
            userId: user?.id,
            status: purchased ? 'completed' : 'pending',
            metadata: metadata,
          );
      final bookmarks = await ref.read(bookmarkServiceProvider.future);
      await bookmarks.addReceipt(DonationReceipt(
        receiptId: receiptId,
        amountPence: widget.amount * 100,
        createdAt: DateTime.now(),
      ));
      if (!mounted) return;
      await DqHaptics.success();
      context.go('/donate/success', extra: DonateSuccessArgs(amount: widget.amount, receiptId: receiptId, email: _emailController.text.trim()));
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
    final copy = ref.watch(donateCopyProvider).valueOrNull ?? DonateCopy.fallback;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Checkout', onBack: () => context.pop()),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    DqCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Donation Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Amount: £${widget.amount}', style: const TextStyle(fontSize: 18, color: AppColors.yellow, fontWeight: FontWeight.w800)),
                          Text('Frequency: ${widget.frequency == 'monthly' ? 'Monthly' : 'One-time'}', style: TextStyle(color: context.dq.muted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      autofillHints: const [AutofillHints.name],
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _onBehalf,
                      onChanged: (v) => setState(() => _onBehalf = v),
                      title: const Text('Donate on behalf of someone'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_onBehalf) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _behalfNameController,
                        decoration: const InputDecoration(labelText: 'On behalf of (name)'),
                        validator: (v) => _onBehalf ? Validators.name(v) : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    DqCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            copy.checkoutStoreNote,
                            style: TextStyle(fontSize: 13, color: context.dq.muted),
                          ),
                          if (widget.frequency == 'monthly') ...[
                            const SizedBox(height: 12),
                            Text(
                              interpolateCmsCopy(copy.monthlyRenewNote, amount: widget.amount),
                              style: TextStyle(fontSize: 13, color: context.dq.muted),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            children: [
                              TextButton(
                                onPressed: () => context.push('/terms'),
                                child: const Text('Terms'),
                              ),
                              TextButton(
                                onPressed: () => context.push('/privacy'),
                                child: const Text('Privacy Policy'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DqPrimaryButton(
                label: _loading ? 'Processing...' : 'Donate Now',
                onPressed: _loading ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonateSuccessScreen extends ConsumerWidget {
  const DonateSuccessScreen({super.key, required this.amount, required this.receiptId, this.email});

  final int amount;
  final String receiptId;
  // Kept for checkout routing; the screen does not claim an email was sent.
  // ignore: unused_field
  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = ref.watch(donateCopyProvider).valueOrNull ?? DonateCopy.fallback;
    final emailCopy = ref.watch(donationEmailCopyProvider).valueOrNull ?? DonationEmailCopy.fallback;
    final intro = interpolateCmsCopy(emailCopy.intro, amount: amount, receiptId: receiptId);
    final footer = interpolateCmsCopy(emailCopy.footer, amount: amount, receiptId: receiptId);
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: IgnorePointer(child: GeoPattern())),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    interpolateCmsCopy(copy.successTitle, amount: amount, receiptId: receiptId),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    interpolateCmsCopy(copy.successSubtitle, amount: amount, receiptId: receiptId),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Text('Receipt #$receiptId', style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          intro,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          footer,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Receipt saved in the Saved tab on this device.',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  DqPrimaryButton(label: 'Back to Home', onPressed: () => context.go('/home')),
                  const SizedBox(height: 12),
                  DqGhostButton(
                    label: 'Share Receipt',
                    onPressed: () => Share.share('Donate Quran receipt #$receiptId — £$amount donation. Thank you for supporting Quran printing.'),
                  ),
                  const SizedBox(height: 8),
                  DqGhostButton(
                    label: 'Share Campaign',
                    onPressed: () => Share.share('I just donated £$amount to fund Quran printing via Donate Quran. Join me: https://donatequran.com'),
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
