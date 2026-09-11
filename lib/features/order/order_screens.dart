import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/checkout_args.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/services/content_repository.dart';
import '../../core/services/order_pricing.dart';
import '../../core/services/paypal_payment_service.dart';
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
            DqScreenHeader(title: 'Order Quran', onBack: () => context.pop()),
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
                  ...catalog.products.map((p) => _productCard(context, p)),
                  TextButton(
                    onPressed: () => context.push('/ask-scholar'),
                    child: const Text('Need 160+ copies? Contact us'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context, OrderCatalogProduct product) {
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
                Text(product.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.charcoal)),
                const SizedBox(height: 4),
                Text(product.description, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(20)),
                  child: Text(product.qtyLabel, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => context.push(
                '/order/detail',
                extra: OrderProductArgs(
                  title: product.title,
                  kind: product.kind,
                  minQuantity: product.minQuantity,
                  maxQuantity: product.maxQuantity,
                ),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(product.cta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onBrand)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.product});
  final OrderProductArgs product;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  String? _language;
  late int _quantity = widget.product.minQuantity;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(orderCatalogProvider).valueOrNull ?? OrderCatalogCopy.fallback;
    final languages = catalog.languages.isNotEmpty ? catalog.languages : OrderCatalogCopy.fallback.languages;
    final language = _language ?? languages.first;
    final product = widget.product;
    final quote = OrderPricing.tryQuote(product.kind, _quantity);
    final locked = product.minQuantity == product.maxQuantity;
    final qtyLabel = product.kind == OrderPackKind.boxes ? 'Boxes' : 'Quantity';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: product.title, onBack: () => context.pop()),
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
                      Text(qtyLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: !locked && _quantity > product.minQuantity
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            product.kind == OrderPackKind.boxes ? '$_quantity × 10' : '$_quantity',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          IconButton(
                            onPressed: !locked && _quantity < product.maxQuantity
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (product.kind == OrderPackKind.boxes)
                    Text(
                      '${quote?.quranCount ?? _quantity * OrderPricing.copiesPerBox} Qurans',
                      style: TextStyle(color: context.dq.muted, fontSize: 12),
                    ),
                  const SizedBox(height: 16),
                  if (quote != null) _PriceBreakdown(quote: quote),
                  const SizedBox(height: 12),
                  Text(catalog.deliveryNote, style: TextStyle(color: context.dq.muted, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  DqPrimaryButton(
                    label: quote == null ? 'Unavailable' : 'Continue — ${OrderPricing.formatPence(quote.totalPence)}',
                    onPressed: quote == null
                        ? null
                        : () => context.push(
                              '/order/checkout',
                              extra: OrderCheckoutArgs(
                                title: product.title,
                                language: language,
                                quantity: _quantity,
                                kind: product.kind,
                              ),
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
    required this.kind,
  });

  final String title;
  final String language;
  final int quantity;
  final OrderPackKind kind;

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
    final quote = OrderPricing.tryQuote(widget.kind, widget.quantity);
    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This quantity is not available.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = ref.read(appStateProvider).user;
      final reference = await PaypalPaymentService.payAndCreateOrder(
        context: context,
        title: widget.title,
        quantity: widget.quantity,
        kind: widget.kind,
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
    final quote = OrderPricing.quote(widget.kind, widget.quantity);

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
                    _PriceBreakdown(
                      quote: quote,
                      quantityLabel: widget.kind == OrderPackKind.boxes
                          ? '${widget.quantity} boxes (${quote.quranCount} Qurans)'
                          : '${quote.quranCount} Quran${quote.quranCount == 1 ? '' : 's'}',
                    ),
                    const SizedBox(height: 16),
                    DqCard(
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, color: AppColors.yellow),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Paid securely with PayPal (not the App Store / Play Store).',
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
              child: DqPrimaryButton(
                label: _loading ? 'Placing order...' : 'Pay ${OrderPricing.formatPence(quote.totalPence)}',
                onPressed: _loading ? null : _placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.quote, this.quantityLabel});

  final OrderPriceQuote quote;
  final String? quantityLabel;

  @override
  Widget build(BuildContext context) {
    return DqCard(
      child: Column(
        children: [
          if (quantityLabel != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity'),
                Text(quantityLabel!),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cost'),
              Text(quote.costPence == 0 ? 'Free' : OrderPricing.formatPence(quote.costPence)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Postage and Packaging'),
              Text(OrderPricing.formatPence(quote.postagePence)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                OrderPricing.formatPence(quote.totalPence),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.yellow),
              ),
            ],
          ),
        ],
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
