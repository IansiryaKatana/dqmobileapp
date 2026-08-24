import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/checkout_args.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/services/content_repository.dart';
import '../../core/services/postage_payment_service.dart';
import '../../core/services/user_data_repository.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/app_media_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/utils/error_messages.dart';
import '../../shared/utils/validators.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';
import '../../shared/widgets/geo_pattern.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(orderCatalogProvider);
    final catalog = catalogAsync.valueOrNull ?? OrderCatalogCopy.fallback;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Order Free Quran', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
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
                              Text(
                                catalog.heroTitle,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                catalog.heroSubtitle,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Positioned.fill(child: IgnorePointer(child: GeoPattern())),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...catalog.products.map(
                    (p) => _productCard(context, p.title, p.description, p.routeTitle, p.qtyLabel, p.cta),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context, String title, String desc, String routeTitle, String qty, String cta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.charcoal)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(20)),
                  child: Text(qty, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => context.push('/order/detail', extra: routeTitle),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(cta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onBrand)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.title});
  final String title;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  String? _language;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(orderCatalogProvider).valueOrNull ?? OrderCatalogCopy.fallback;
    final languages = catalog.languages.isNotEmpty ? catalog.languages : OrderCatalogCopy.fallback.languages;
    final language = _language ?? languages.first;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: widget.title, onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: AppMediaImage(
                        pageKey: 'order',
                        slotKey: 'product',
                        fit: BoxFit.cover,
                        height: 200,
                        fallbackAsset: AppAssets.quranBookshot,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: languages.contains(language) ? language : languages.first,
                    decoration: const InputDecoration(labelText: 'Language'),
                    items: languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => _language = v ?? languages.first),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove_circle_outline)),
                          Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add_circle_outline)),
                        ],
                      ),
                    ],
                  ),
                  Text(catalog.deliveryNote, style: TextStyle(color: context.dq.muted, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  DqPrimaryButton(
                    label: 'Add to Order',
                    onPressed: () => context.push(
                      '/order/checkout',
                      extra: OrderCheckoutArgs(title: widget.title, language: language, quantity: _quantity),
                    ),
                  ),
                  TextButton(onPressed: () => context.push('/ask-scholar'), child: const Text('Ask a Question')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCheckoutScreen extends ConsumerStatefulWidget {
  const OrderCheckoutScreen({
    super.key,
    required this.title,
    required this.language,
    required this.quantity,
  });

  final String title;
  final String language;
  final int quantity;

  @override
  ConsumerState<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends ConsumerState<OrderCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postcode = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _address.dispose();
    _city.dispose();
    _postcode.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(appStateProvider).user;
      final reference = await PostagePaymentService.payAndCreateOrder(
        title: widget.title,
        quantity: widget.quantity,
        language: widget.language,
        userId: user?.id,
        line1: _address.text.trim(),
        city: _city.text.trim(),
        postcode: _postcode.text.trim(),
      );
      if (user?.id != null) {
        await ref.read(userDataRepositoryProvider).saveAddress(
              userId: user!.id!,
              label: 'Order ${DateTime.now().year}',
              line1: _address.text.trim(),
              city: _city.text.trim(),
              postcode: _postcode.text.trim(),
            );
      }
      if (!mounted) return;
      context.go('/order/success', extra: OrderSuccessArgs(reference: reference));
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
    final postage = ref.watch(postageCopyProvider).valueOrNull ?? PostageCopy.fallback;
    final label = postage.displayLabel;

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
                    TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address'), validator: (v) => Validators.required(v, field: 'Address')),
                    const SizedBox(height: 12),
                    TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City'), validator: (v) => Validators.required(v, field: 'City')),
                    const SizedBox(height: 12),
                    TextFormField(controller: _postcode, decoration: const InputDecoration(labelText: 'Postcode'), validator: Validators.postcode),
                    const SizedBox(height: 20),
                    DqCard(
                      child: Column(
                        children: [
                          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Subtotal'), Text('£0.00')]),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Postage & Packaging'), Text(label)]),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.yellow)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DqCard(
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, color: AppColors.yellow),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Postage is paid securely with Stripe (not the App Store / Play Store).',
                              style: TextStyle(fontSize: 13, color: context.dq.muted),
                            ),
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
              child: DqPrimaryButton(label: _loading ? 'Placing order...' : 'Place Order', onPressed: _loading ? null : _placeOrder),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.reference});
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.check_circle, color: AppColors.yellow, size: 72),
              const SizedBox(height: 16),
              Text('Your Quran order has been received', textAlign: TextAlign.center, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('We will keep you updated on your order.', textAlign: TextAlign.center, style: TextStyle(color: context.dq.muted)),
              const SizedBox(height: 24),
              DqCard(
                child: Column(
                  children: [
                    Text('Order Reference', style: TextStyle(color: context.dq.muted, fontSize: 12)),
                    Text(reference, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const Spacer(),
              DqPrimaryButton(label: 'Back to Home', onPressed: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }
}
