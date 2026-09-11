import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/app_state_provider.dart';
import '../../core/models/checkout_args.dart';
import '../../core/services/bookmark_service.dart';
import '../../core/router/root_nav.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/services/scholar_repository.dart';
import '../../core/services/user_data_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';
import '../../shared/widgets/figma_components.dart';

class DonationHistoryScreen extends ConsumerWidget {
  const DonationHistoryScreen({super.key, this.receiptsOnly = false});

  /// When true, shows receipt-focused copy (Profile → Receipts).
  final bool receiptsOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appStateProvider.select((s) => s.user));
    final localAsync = ref.watch(bookmarkServiceProvider);
    final title = receiptsOnly ? 'Receipts' : 'Donation History';

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          DqNavyHeader(
            title: title,
            subtitle: receiptsOnly ? 'Download or share your receipts' : 'Your giving journey',
            onBack: () => context.pop(),
          ),
          Expanded(
              child: user?.id == null
                  ? localAsync.when(
                      loading: () => const DqLoadingOverlay(),
                      error: (_, __) => _emptyState(context, signedIn: false),
                      data: (service) => _localReceiptList(context, service.receipts),
                    )
                  : FutureBuilder(
                      future: ref.read(userDataRepositoryProvider).fetchDonations(user!.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return DqLoadingOverlay(message: receiptsOnly ? 'Loading receipts...' : 'Loading donations...');
                        }
                        final rows = snapshot.data ?? [];
                        if (rows.isEmpty) return _emptyState(context, signedIn: true);
                        return _remoteReceiptList(context, rows);
                      },
                    ),
            ),
          ],
        ),
    );
  }

  Widget _emptyState(BuildContext context, {required bool signedIn}) {
    if (receiptsOnly) {
      return DqEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No receipts yet',
        message: signedIn
            ? 'You haven\'t made a donation yet. Once you donate, your receipts will be saved here for easy access.'
            : 'Sign in to sync donation receipts, or make a donation as a guest to save a receipt on this device.',
        action: DqPrimaryButton(
          label: 'Make a Donation',
          onPressed: () => pushRootRoute(context, '/donate'),
        ),
      );
    }
    return DqEmptyState(
      icon: Icons.volunteer_activism_outlined,
      title: 'No donations yet',
      message: signedIn
          ? 'You haven\'t made a donation yet. When you do, your giving history will appear here.'
          : 'Sign in to sync your donation history across devices.',
      action: signedIn
          ? DqPrimaryButton(
              label: 'Donate Now',
              onPressed: () => pushRootRoute(context, '/donate'),
            )
          : null,
    );
  }

  Widget _localReceiptList(BuildContext context, List<DonationReceipt> receipts) {
    if (receipts.isEmpty) return _emptyState(context, signedIn: false);
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: receipts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = receipts[i];
        return _receiptTile(
          context,
          receiptId: r.receiptId,
          amountPence: r.amountPence,
          frequency: 'once',
          status: 'completed',
          createdAt: r.createdAt,
        );
      },
    );
  }

  Widget _remoteReceiptList(BuildContext context, List<DonationRecord> rows) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = rows[i];
        return _receiptTile(
          context,
          receiptId: r.receiptId ?? '—',
          amountPence: r.amountPence,
          frequency: r.frequency,
          status: r.status,
          createdAt: r.createdAt,
        );
      },
    );
  }

  Widget _receiptTile(
    BuildContext context, {
    required String receiptId,
    required int amountPence,
    required String frequency,
    required String status,
    required DateTime createdAt,
  }) {
    return DqCard(
      onTap: () => context.push(
        '/profile/receipt',
        extra: ReceiptDetailArgs(
          receiptId: receiptId,
          amountPence: amountPence,
          frequency: frequency,
          status: status,
          createdAt: createdAt,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#$receiptId', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(createdAt.toLocal().toString().split('.').first, style: TextStyle(fontSize: 12, color: context.dq.muted)),
          ]),
          Row(
            children: [
              Text('£${(amountPence / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: context.dq.muted, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class ReceiptDetailScreen extends StatelessWidget {
  const ReceiptDetailScreen({super.key, required this.args});

  final ReceiptDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final amount = '£${(args.amountPence / 100).toStringAsFixed(2)}';
    final shareText =
        'Donate Quran Receipt\n#${args.receiptId}\nAmount: $amount\nFrequency: ${args.frequency}\nStatus: ${args.status}\nDate: ${args.createdAt.toLocal()}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Receipt', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DqCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${args.receiptId}', style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 16),
                        _row(context, 'Amount', amount),
                        _row(context, 'Frequency', args.frequency),
                        _row(context, 'Status', args.status),
                        _row(context, 'Date', args.createdAt.toLocal().toString().split('.').first),
                        const SizedBox(height: 12),
                        const Text('Your donation funds Quran printing. Store processing fees may apply.', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DqPrimaryButton(
                label: 'Share Receipt',
                onPressed: () => Share.share(shareText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.dq.muted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appStateProvider.select((s) => s.user));
    if (user?.id == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              DqScreenHeader(title: 'Order History', onBack: () => context.pop()),
              const Expanded(
                child: DqEmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'Sign in required',
                  message: 'Sign in to view your Quran orders.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          DqNavyHeader(
            title: 'Order History',
            subtitle: 'Your Quran orders',
            onBack: () => context.pop(),
          ),
          Expanded(
              child: FutureBuilder(
                future: ref.read(userDataRepositoryProvider).fetchOrders(user!.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const DqLoadingOverlay(message: 'Loading orders...');
                  }
                  final rows = snapshot.data ?? [];
                  if (rows.isEmpty) {
                    return DqEmptyState(
                      icon: Icons.local_shipping_outlined,
                      title: 'No orders yet',
                      message: 'You haven\'t ordered a free Quran yet. When you do, your orders will appear here.',
                      action: DqPrimaryButton(
                        label: 'Order Free Quran',
                        onPressed: () => pushRootRoute(context, '/order'),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final o = rows[i];
                      return DqCard(
                        onTap: () => context.push(
                          '/profile/order',
                          extra: OrderDetailArgs(
                            reference: o.reference,
                            quantity: o.quantity,
                            language: o.language,
                            status: o.status,
                            createdAt: o.createdAt,
                            address: o.address,
                            postagePence: o.postagePence,
                            costPence: o.costPence,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('#${o.reference}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${o.quantity} × ${o.language} · ${o.status}', style: TextStyle(color: context.dq.muted, fontSize: 13)),
                                  Text(o.createdAt.toLocal().toString().split('.').first, style: TextStyle(color: context.dq.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: context.dq.muted),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}

class OrderDetailHistoryScreen extends StatelessWidget {
  const OrderDetailHistoryScreen({super.key, required this.args});

  final OrderDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final address = args.address;
    final addressText = address != null
        ? '${address['line1'] ?? ''}, ${address['city'] ?? ''}, ${address['postcode'] ?? ''}'
        : 'Not available';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Order Details', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DqCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${args.reference}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 16),
                        _row(context, 'Status', args.status),
                        _row(context, 'Quantity', '${args.quantity}'),
                        _row(context, 'Language', args.language),
                        _row(context, 'Cost', args.costPence == 0 ? 'Free' : '£${(args.costPence / 100).toStringAsFixed(2)}'),
                        _row(context, 'Postage', '£${(args.postagePence / 100).toStringAsFixed(2)}'),
                        _row(context, 'Total', '£${((args.costPence + args.postagePence) / 100).toStringAsFixed(2)}'),
                        _row(context, 'Ordered', args.createdAt.toLocal().toString().split('.').first),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  DqCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(addressText, style: TextStyle(color: context.dq.muted, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  DqCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _timelineStep(context, 'Order placed', args.createdAt, done: true),
                        _timelineStep(context, 'Processing', args.createdAt, done: args.status != 'pending'),
                        _timelineStep(context, 'Dispatched', args.createdAt, done: args.status == 'shipped' || args.status == 'delivered'),
                        _timelineStep(context, 'Delivered', args.createdAt, done: args.status == 'delivered'),
                      ],
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

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.dq.muted)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _timelineStep(BuildContext context, String label, DateTime date, {required bool done}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? AppColors.yellow : context.dq.muted, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: done ? FontWeight.w600 : FontWeight.normal))),
        ],
      ),
    );
  }
}

class MyQuestionsScreen extends ConsumerWidget {
  const MyQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appStateProvider.select((s) => s.user));
    if (user?.id == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              DqScreenHeader(title: 'My Questions', onBack: () => context.pop()),
              const Expanded(
                child: DqEmptyState(
                  icon: Icons.question_answer_outlined,
                  title: 'Sign in required',
                  message: 'Sign in to view your scholar questions.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'My Questions', onBack: () => context.pop()),
            Expanded(
              child: FutureBuilder(
                future: ref.read(scholarRepositoryProvider).fetchQuestions(user!.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const DqLoadingOverlay(message: 'Loading questions...');
                  }
                  final rows = snapshot.data ?? [];
                  if (rows.isEmpty) {
                    return DqEmptyState(
                      icon: Icons.question_answer_outlined,
                      title: 'No questions yet',
                      message: 'Ask a scholar from the More tab.',
                      action: DqPrimaryButton(label: 'Ask a Scholar', onPressed: () => context.push('/ask-scholar')),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final q = rows[i];
                      return DqCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(q.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(q.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(q.question, style: TextStyle(color: context.dq.muted, height: 1.4)),
                            if (q.hasAnswer) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Answer',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                q.answer!,
                                style: const TextStyle(height: 1.45),
                              ),
                              if (q.answeredAt != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Answered ${q.answeredAt!.toLocal().toString().split('.').first}',
                                  style: TextStyle(fontSize: 11, color: context.dq.muted),
                                ),
                              ],
                            ],
                            const SizedBox(height: 8),
                            Text(q.createdAt.toLocal().toString().split('.').first, style: TextStyle(fontSize: 12, color: context.dq.muted)),
                          ],
                        ),
                      );
                    },
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

class SavedAddressesScreen extends ConsumerStatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  ConsumerState<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends ConsumerState<SavedAddressesScreen> {
  final _label = TextEditingController(text: 'Home');
  final _line1 = TextEditingController();
  final _city = TextEditingController();
  final _postcode = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
    _line1.dispose();
    _city.dispose();
    _postcode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(appStateProvider).user;
    if (user?.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to save addresses')));
      }
      return;
    }
    if (_line1.text.trim().isEmpty || _city.text.trim().isEmpty || _postcode.text.trim().isEmpty) return;
    await ref.read(userDataRepositoryProvider).saveAddress(
          userId: user!.id!,
          label: _label.text.trim(),
          line1: _line1.text.trim(),
          city: _city.text.trim(),
          postcode: _postcode.text.trim(),
        );
    setState(() {});
    _line1.clear();
    _city.clear();
    _postcode.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appStateProvider.select((s) => s.user));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Saved Addresses', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (user?.id != null)
                    FutureBuilder(
                      future: ref.read(userDataRepositoryProvider).fetchAddresses(user!.id!),
                      builder: (context, snapshot) {
                        final rows = snapshot.data ?? [];
                        if (rows.isEmpty) {
                          return const DqEmptyState(icon: Icons.location_on_outlined, title: 'No saved addresses', message: 'Add an address below for faster checkout.');
                        }
                        return Column(
                          children: rows
                              .map(
                                (a) => DqCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(a.formatted, style: TextStyle(color: context.dq.muted)),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    )
                  else
                    const DqEmptyState(icon: Icons.login, title: 'Sign in required', message: 'Sign in to save delivery addresses.'),
                  const SizedBox(height: 24),
                  if (user?.id != null) ...[
                    TextField(controller: _label, decoration: const InputDecoration(labelText: 'Label')),
                    const SizedBox(height: 8),
                    TextField(controller: _line1, decoration: const InputDecoration(labelText: 'Address line')),
                    const SizedBox(height: 8),
                    TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
                    const SizedBox(height: 8),
                    TextField(controller: _postcode, decoration: const InputDecoration(labelText: 'Postcode')),
                    const SizedBox(height: 16),
                    DqPrimaryButton(label: 'Save Address', onPressed: _save),
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

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!PushNotificationService.isAvailable &&
        PushNotificationService.status == PushServiceStatus.notConfigured) {
      if (mounted) setState(() { _enabled = false; _loading = false; });
      return;
    }
    final enabled = await PushNotificationService.hasOsPermission();
    if (mounted) setState(() { _enabled = enabled; _loading = false; });
  }

  Future<void> _toggle(bool value) async {
    if (!PushNotificationService.isAvailable &&
        PushNotificationService.status == PushServiceStatus.notConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PushNotificationService.statusMessage)),
        );
      }
      return;
    }
    if (value) {
      setState(() => _loading = true);
      final granted = await PushNotificationService.requestPermission();
      final user = ref.read(appStateProvider).user;
      if (granted && user?.id != null) {
        await PushNotificationService.syncTokenForUser(user!.id!);
      }
      if (mounted) {
        setState(() { _enabled = granted; _loading = false; });
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                PushNotificationService.status == PushServiceStatus.notConfigured
                    ? PushNotificationService.statusMessage
                    : 'Notification permission was denied. You can enable it in system settings.',
              ),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('To disable notifications, turn them off in your device settings.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Notifications', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Stay updated on your orders, donations, and scholar replies.',
                    style: TextStyle(color: context.dq.muted, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                  else
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Push notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        PushNotificationService.status == PushServiceStatus.notConfigured
                            ? PushNotificationService.statusMessage
                            : (_enabled ? 'Enabled on this device' : 'Tap to allow notifications'),
                      ),
                      value: _enabled && PushNotificationService.status != PushServiceStatus.notConfigured,
                      activeThumbColor: AppColors.yellow,
                      onChanged: PushNotificationService.status == PushServiceStatus.notConfigured
                          ? (_) => _toggle(true)
                          : _toggle,
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
