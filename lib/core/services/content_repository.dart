import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import 'content_service.dart';
import 'order_pricing.dart';

class CmsListResult<T> {
  const CmsListResult(this.items, {this.usedFallback = false});

  final List<T> items;
  final bool usedFallback;
}

String _cmsString(Map<String, dynamic>? json, String key, String fallback) {
  if (json == null) return fallback;
  final v = json[key];
  if (v is! String) return fallback;
  return v.trim().isEmpty ? fallback : v;
}

/// Replaces `{{amount}}`, `{{receipt_id}}`, and `{{donor_name}}` in CMS templates.
String interpolateCmsCopy(
  String template, {
  int? amount,
  String? receiptId,
  String? donorName,
}) {
  var out = template;
  if (amount != null) {
    out = out.replaceAll('{{amount}}', '£$amount');
  }
  if (receiptId != null) {
    out = out.replaceAll('{{receipt_id}}', receiptId);
  }
  if (donorName != null) {
    out = out.replaceAll('{{donor_name}}', donorName);
  }
  return out;
}

class ContentRepository {
  ContentRepository(this._client);

  final SupabaseClient? _client;

  Future<CmsListResult<Article>> fetchArticles() async {
    final remote = await _fetchByKind('article');
    if (remote.isNotEmpty) return CmsListResult(remote);
    return CmsListResult(ContentService.articles, usedFallback: true);
  }

  Future<CmsListResult<Article>> fetchBooks() async {
    final remote = await _fetchByKind('book');
    if (remote.isNotEmpty) return CmsListResult(remote);
    return CmsListResult(ContentService.books, usedFallback: true);
  }

  Future<CmsListResult<QuranTopic>> fetchQuranTopics() async {
    final client = _client;
    if (client == null) {
      return CmsListResult(ContentService.quranTopics, usedFallback: true);
    }

    try {
      final rows = await client
          .from('quran_topics')
          .select('name, description, surah_numbers')
          .eq('published', true)
          .order('sort_order');

      if (rows.isEmpty) {
        return CmsListResult(ContentService.quranTopics, usedFallback: true);
      }

      return CmsListResult(
        rows
            .map(
              (row) => QuranTopic(
                name: row['name'] as String,
                description: row['description'] as String? ?? '',
                surahNumbers: List<int>.from(row['surah_numbers'] as List? ?? []),
              ),
            )
            .toList(),
      );
    } catch (e, st) {
      debugPrint('ContentRepository.fetchQuranTopics: $e\n$st');
      return CmsListResult(ContentService.quranTopics, usedFallback: true);
    }
  }

  Future<CmsListResult<FaqItem>> fetchFaq() async {
    final client = _client;
    if (client == null) {
      return CmsListResult(ContentService.faq, usedFallback: true);
    }

    try {
      final rows = await client
          .from('faq_items')
          .select('question, answer')
          .eq('published', true)
          .order('sort_order');

      if (rows.isEmpty) {
        return CmsListResult(ContentService.faq, usedFallback: true);
      }

      return CmsListResult(
        rows
            .map(
              (row) => FaqItem(
                question: row['question'] as String,
                answer: row['answer'] as String,
              ),
            )
            .toList(),
      );
    } catch (e, st) {
      debugPrint('ContentRepository.fetchFaq: $e\n$st');
      return CmsListResult(ContentService.faq, usedFallback: true);
    }
  }

  Future<Article?> fetchArticleBySlug(String slug) async {
    final client = _client;
    if (client == null) return ContentService.articleById(slug);

    try {
      final row = await client
          .from('content_items')
          .select('slug, title, summary, body, topic')
          .eq('slug', slug)
          .eq('published', true)
          .maybeSingle();

      if (row == null) return ContentService.articleById(slug);
      return _articleFromRow(row);
    } catch (e, st) {
      debugPrint('ContentRepository.fetchArticleBySlug: $e\n$st');
      return ContentService.articleById(slug);
    }
  }

  Future<Map<String, dynamic>?> fetchAppSetting(String key) async {
    final client = _client;
    if (client == null) return null;

    try {
      final row = await client.from('app_settings').select('value').eq('key', key).maybeSingle();
      return row?['value'] as Map<String, dynamic>?;
    } catch (e, st) {
      debugPrint('ContentRepository.fetchAppSetting: $e\n$st');
      return null;
    }
  }

  Future<List<Article>> _fetchByKind(String kind) async {
    final client = _client;
    if (client == null) return [];

    try {
      final rows = await client
          .from('content_items')
          .select('slug, title, summary, body, topic')
          .eq('kind', kind)
          .eq('published', true)
          .order('sort_order');

      return rows.map(_articleFromRow).toList();
    } catch (e, st) {
      debugPrint('ContentRepository._fetchByKind($kind): $e\n$st');
      return [];
    }
  }

  Article _articleFromRow(Map<String, dynamic> row) {
    return Article(
      id: row['slug'] as String,
      title: row['title'] as String,
      summary: row['summary'] as String? ?? '',
      body: row['body'] as String? ?? '',
      topic: row['topic'] as String? ?? 'General',
    );
  }

  Future<HomeCampaignCopy> fetchHomeCampaign() async {
    final value = await fetchAppSetting('home_campaign');
    return HomeCampaignCopy.fromJson(value);
  }

  Future<DonateCopy> fetchDonateCopy() async {
    final value = await fetchAppSetting('donate_copy');
    return DonateCopy.fromJson(value);
  }

  Future<OrderCatalogCopy> fetchOrderCatalog() async {
    final value = await fetchAppSetting('order_catalog');
    return OrderCatalogCopy.fromJson(value);
  }

  Future<PostageCopy> fetchPostage() async {
    final value = await fetchAppSetting('postage');
    return PostageCopy.fromJson(value);
  }

  Future<AboutCopy> fetchAbout() async {
    final value = await fetchAppSetting('about');
    return AboutCopy.fromJson(value);
  }

  Future<ExternalLinksCopy> fetchExternalLinks() async {
    final value = await fetchAppSetting('external_links');
    return ExternalLinksCopy.fromJson(value);
  }

  Future<ImpactOverrides> fetchImpactOverrides() async {
    final value = await fetchAppSetting('impact_overrides');
    return ImpactOverrides.fromJson(value);
  }

  Future<LegalDocumentsCopy> fetchLegalDocuments() async {
    final value = await fetchAppSetting('legal_documents');
    return LegalDocumentsCopy.fromJson(value);
  }

  Future<OnboardingCopy> fetchOnboarding() async {
    final value = await fetchAppSetting('onboarding');
    return OnboardingCopy.fromJson(value);
  }

  Future<PermissionsCopy> fetchPermissions() async {
    final value = await fetchAppSetting('permissions');
    return PermissionsCopy.fromJson(value);
  }

  Future<LogisticsCopy> fetchLogistics() async {
    final value = await fetchAppSetting('logistics');
    return LogisticsCopy.fromJson(value);
  }

  Future<RevenueCatSettings> fetchRevenueCat() async {
    final value = await fetchAppSetting('revenuecat');
    return RevenueCatSettings.fromJson(value);
  }

  Future<DonationEmailCopy> fetchDonationEmailCopy() async {
    final value = await fetchAppSetting('donation_email_copy');
    return DonationEmailCopy.fromJson(value);
  }
}

class HomeCampaignCopy {
  const HomeCampaignCopy({
    required this.title,
    required this.subtitle,
    this.link,
  });

  final String title;
  final String subtitle;
  final String? link;

  static const fallback = HomeCampaignCopy(
    title: 'Support Quran Printing',
    subtitle: '2,340 copies funded so far',
  );

  factory HomeCampaignCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    return HomeCampaignCopy(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : fallback.title,
      subtitle: (json['subtitle'] as String?)?.trim().isNotEmpty == true
          ? json['subtitle'] as String
          : fallback.subtitle,
      link: json['link'] as String?,
    );
  }
}

class DonateImpactCard {
  const DonateImpactCard({required this.label, required this.amountLabel});

  final String label;
  final String amountLabel;

  factory DonateImpactCard.fromJson(Map<String, dynamic> json) {
    return DonateImpactCard(
      label: json['label'] as String? ?? '',
      amountLabel: json['amount_label'] as String? ?? '',
    );
  }
}

class DonateCopy {
  const DonateCopy({
    required this.tagline,
    required this.guestMessage,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.impactCards,
    required this.checkoutStoreNote,
    required this.monthlyRenewNote,
    required this.successTitle,
    required this.successSubtitle,
  });

  final String tagline;
  final String guestMessage;
  final String heroTitle;
  final String heroSubtitle;
  final List<DonateImpactCard> impactCards;
  final String checkoutStoreNote;
  final String monthlyRenewNote;
  final String successTitle;
  final String successSubtitle;

  static const fallback = DonateCopy(
    tagline:
        'Donations fund Quran printing. App Store and Play Store processing fees may apply; the remainder goes to printing.',
    guestMessage: 'No account needed — donate as a guest or sign in later to track receipts.',
    heroTitle: 'Fund Quran printing today',
    heroSubtitle: 'Every £5 funds one Quran copy.',
    impactCards: [
      DonateImpactCard(label: 'Sponsor 1 Quran', amountLabel: '£5'),
      DonateImpactCard(label: 'Sponsor 5 Qurans', amountLabel: '£25'),
      DonateImpactCard(label: 'Sponsor 10 Qurans', amountLabel: '£50'),
      DonateImpactCard(label: 'Sponsor a Box', amountLabel: '£250'),
    ],
    checkoutStoreNote:
        'Payment uses the App Store / Play Store checkout via RevenueCat. '
        'Supported amounts: £5, £10, £25, £50, £100.',
    monthlyRenewNote:
        'Monthly donations auto-renew at {{amount}} until you cancel in your Apple ID or Google Play subscription settings. Restore purchases from Profile if a receipt is missing.',
    successTitle: 'May Allah reward you',
    successSubtitle: 'Your donation of {{amount}} has been received.',
  );

  factory DonateCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    final cardsRaw = json['impact_cards'] as List?;
    final cards = cardsRaw
            ?.whereType<Map>()
            .map((e) => DonateImpactCard.fromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.label.isNotEmpty)
            .toList() ??
        const <DonateImpactCard>[];
    return DonateCopy(
      tagline: _cmsString(json, 'tagline', fallback.tagline),
      guestMessage: _cmsString(json, 'guest_message', fallback.guestMessage),
      heroTitle: _cmsString(json, 'hero_title', fallback.heroTitle),
      heroSubtitle: _cmsString(json, 'hero_subtitle', fallback.heroSubtitle),
      impactCards: cards.isNotEmpty ? cards : fallback.impactCards,
      checkoutStoreNote: _cmsString(json, 'checkout_store_note', fallback.checkoutStoreNote),
      monthlyRenewNote: _cmsString(json, 'monthly_renew_note', fallback.monthlyRenewNote),
      successTitle: _cmsString(json, 'success_title', fallback.successTitle),
      successSubtitle: _cmsString(json, 'success_subtitle', fallback.successSubtitle),
    );
  }
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(EnvConfig.supabase);
});

final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final result = await ref.watch(contentRepositoryProvider).fetchArticles();
  if (result.usedFallback) {
    ref.read(cmsFallbackFlagProvider.notifier).state = true;
  }
  return result.items;
});

final booksProvider = FutureProvider<List<Article>>((ref) async {
  final result = await ref.watch(contentRepositoryProvider).fetchBooks();
  if (result.usedFallback) {
    ref.read(cmsFallbackFlagProvider.notifier).state = true;
  }
  return result.items;
});

final quranTopicsProvider = FutureProvider<List<QuranTopic>>((ref) async {
  final result = await ref.watch(contentRepositoryProvider).fetchQuranTopics();
  if (result.usedFallback) {
    ref.read(cmsFallbackFlagProvider.notifier).state = true;
  }
  return result.items;
});

final faqProvider = FutureProvider<List<FaqItem>>((ref) async {
  final result = await ref.watch(contentRepositoryProvider).fetchFaq();
  if (result.usedFallback) {
    ref.read(cmsFallbackFlagProvider.notifier).state = true;
  }
  return result.items;
});

final articleByIdProvider = FutureProvider.family<Article?, String>((ref, id) {
  return ref.watch(contentRepositoryProvider).fetchArticleBySlug(id);
});

final homeCampaignProvider = FutureProvider<HomeCampaignCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchHomeCampaign();
});

final donateCopyProvider = FutureProvider<DonateCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchDonateCopy();
});

final orderCatalogProvider = FutureProvider<OrderCatalogCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchOrderCatalog();
});

final postageCopyProvider = FutureProvider<PostageCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchPostage();
});

final aboutCopyProvider = FutureProvider<AboutCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchAbout();
});

final externalLinksProvider = FutureProvider<ExternalLinksCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchExternalLinks();
});

final impactOverridesProvider = FutureProvider<ImpactOverrides>((ref) {
  return ref.watch(contentRepositoryProvider).fetchImpactOverrides();
});

final legalDocumentsProvider = FutureProvider<LegalDocumentsCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchLegalDocuments();
});

final onboardingCopyProvider = FutureProvider<OnboardingCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchOnboarding();
});

final permissionsCopyProvider = FutureProvider<PermissionsCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchPermissions();
});

final logisticsCopyProvider = FutureProvider<LogisticsCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchLogistics();
});

final donationEmailCopyProvider = FutureProvider<DonationEmailCopy>((ref) {
  return ref.watch(contentRepositoryProvider).fetchDonationEmailCopy();
});

/// Shared flag set when any CMS fetch falls back to static bundles.
final cmsFallbackFlagProvider = StateProvider<bool>((ref) => false);

class OrderCatalogProduct {
  const OrderCatalogProduct({
    required this.title,
    required this.description,
    required this.routeTitle,
    required this.qtyLabel,
    required this.cta,
    required this.kind,
    required this.minQuantity,
    required this.maxQuantity,
  });

  final String title;
  final String description;
  final String routeTitle;
  final String qtyLabel;
  final String cta;
  final OrderPackKind kind;
  final int minQuantity;
  final int maxQuantity;

  factory OrderCatalogProduct.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    final routeTitle = json['route_title'] as String? ?? title;
    final kind = OrderPackKind.tryParse(json['pack_kind'] as String?) ??
        _inferKind(routeTitle, title);
    final inferred = _inferRange(kind, routeTitle, title);
    final minQty = json['min_qty'];
    final maxQty = json['max_qty'];
    return OrderCatalogProduct(
      title: title,
      description: json['description'] as String? ?? '',
      routeTitle: routeTitle,
      qtyLabel: json['qty_label'] as String? ?? '',
      cta: json['cta'] as String? ?? 'Order',
      kind: kind,
      minQuantity: minQty is int ? minQty : int.tryParse('$minQty') ?? inferred.$1,
      maxQuantity: maxQty is int ? maxQty : int.tryParse('$maxQty') ?? inferred.$2,
    );
  }

  static OrderPackKind _inferKind(String routeTitle, String title) {
    final blob = '${routeTitle.toLowerCase()} ${title.toLowerCase()}';
    if (blob.contains('box') || blob.contains('bulk') || blob.contains('pallet') || blob.contains('10+')) {
      return OrderPackKind.boxes;
    }
    return OrderPackKind.copies;
  }

  static (int, int) _inferRange(OrderPackKind kind, String routeTitle, String title) {
    if (kind == OrderPackKind.boxes) {
      return (OrderPricing.minBoxQuantity, OrderPricing.maxBoxQuantity);
    }
    final blob = '$routeTitle $title';
    if (blob.contains('2') && (blob.contains('9') || blob.contains('–') || blob.contains('-'))) {
      return (2, OrderPricing.maxCopyQuantity);
    }
    return (1, 1);
  }
}

class OrderCatalogCopy {
  const OrderCatalogCopy({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.languages,
    required this.deliveryNote,
    required this.products,
  });

  final String heroTitle;
  final String heroSubtitle;
  final List<String> languages;
  final String deliveryNote;
  final List<OrderCatalogProduct> products;

  static const fallback = OrderCatalogCopy(
    heroTitle: 'Order a Quran copy',
    heroSubtitle: 'The first Quran is free. Extra copies include a contribution plus postage.',
    languages: ['English', 'Arabic'],
    deliveryNote: 'Allow 5–10 business days for dispatch.',
    products: [
      OrderCatalogProduct(
        title: '1 Quran',
        description: 'Free copy. You pay postage and packaging.',
        routeTitle: '1 Quran',
        qtyLabel: '1 copy · £7.50 total',
        cta: 'Order Free',
        kind: OrderPackKind.copies,
        minQuantity: 1,
        maxQuantity: 1,
      ),
      OrderCatalogProduct(
        title: '2–9 Qurans',
        description: 'Share with family and friends',
        routeTitle: '2–9 Qurans',
        qtyLabel: '2–9 copies',
        cta: 'Order Now',
        kind: OrderPackKind.copies,
        minQuantity: 2,
        maxQuantity: 9,
      ),
      OrderCatalogProduct(
        title: 'Boxes',
        description: '10 Qurans per box, for mosques and organisations',
        routeTitle: 'Boxes',
        qtyLabel: '1–15 boxes',
        cta: 'Order Boxes',
        kind: OrderPackKind.boxes,
        minQuantity: 1,
        maxQuantity: 15,
      ),
    ],
  );

  factory OrderCatalogCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    final productsRaw = json['products'] as List?;
    final products = productsRaw
            ?.whereType<Map>()
            .map((e) => OrderCatalogProduct.fromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.title.isNotEmpty)
            .toList() ??
        const <OrderCatalogProduct>[];
    final langs = (json['languages'] as List?)?.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    return OrderCatalogCopy(
      heroTitle: (json['hero_title'] as String?)?.trim().isNotEmpty == true
          ? json['hero_title'] as String
          : fallback.heroTitle,
      heroSubtitle: (json['hero_subtitle'] as String?)?.trim().isNotEmpty == true
          ? json['hero_subtitle'] as String
          : fallback.heroSubtitle,
      languages: (langs != null && langs.isNotEmpty) ? langs : fallback.languages,
      deliveryNote: (json['delivery_note'] as String?)?.trim().isNotEmpty == true
          ? json['delivery_note'] as String
          : fallback.deliveryNote,
      products: products.isNotEmpty ? products : fallback.products,
    );
  }
}

class PostageCopy {
  const PostageCopy({
    required this.productId,
    required this.displayPence,
    required this.displayLabel,
  });

  final String productId;
  final int displayPence;
  final String displayLabel;

  static const fallback = PostageCopy(
    productId: 'paypal_order_total',
    displayPence: 750,
    displayLabel: '£7.50',
  );

  factory PostageCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    final pence = json['display_pence'];
    return PostageCopy(
      productId: (json['product_id'] as String?)?.trim().isNotEmpty == true
          ? json['product_id'] as String
          : fallback.productId,
      displayPence: pence is int ? pence : int.tryParse('$pence') ?? fallback.displayPence,
      displayLabel: (json['display_label'] as String?)?.trim().isNotEmpty == true
          ? json['display_label'] as String
          : fallback.displayLabel,
    );
  }
}

class AboutCopy {
  const AboutCopy({required this.title, required this.body});

  final String title;
  final String body;

  static const fallback = AboutCopy(
    title: 'About Us',
    body:
        'Donate Quran is dedicated to printing and distributing English Quran copies worldwide. '
        'Through your generous donations, we fund Quran printing and help share the message of Islam.',
  );

  factory AboutCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    return AboutCopy(
      title: (json['title'] as String?)?.trim().isNotEmpty == true ? json['title'] as String : fallback.title,
      body: (json['body'] as String?)?.trim().isNotEmpty == true ? json['body'] as String : fallback.body,
    );
  }
}

class ExternalLinksCopy {
  const ExternalLinksCopy({
    required this.privacy,
    required this.terms,
    required this.distributor,
    required this.support,
  });

  final String privacy;
  final String terms;
  final String distributor;
  final String support;

  static const fallback = ExternalLinksCopy(
    privacy: 'https://donatequran.com/privacy',
    terms: 'https://donatequran.com/terms',
    distributor: 'https://donatequran.com/distributor',
    support: 'https://donatequran.com/support',
  );

  factory ExternalLinksCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    String pick(String key, String fb) {
      final v = (json[key] as String?)?.trim();
      return (v != null && v.isNotEmpty) ? v : fb;
    }

    return ExternalLinksCopy(
      privacy: pick('privacy', fallback.privacy),
      terms: pick('terms', fallback.terms),
      distributor: pick('distributor', fallback.distributor),
      support: pick('support', fallback.support),
    );
  }

  String urlFor(String key) {
    return switch (key) {
      'privacy' => privacy,
      'terms' => terms,
      'distributor' => distributor,
      'support' => support,
      _ => privacy,
    };
  }
}

class ImpactOverrides {
  const ImpactOverrides({
    this.quransFunded,
    this.ordersPlaced,
    this.countries,
  });

  final int? quransFunded;
  final int? ordersPlaced;
  final int? countries;

  static const none = ImpactOverrides();

  factory ImpactOverrides.fromJson(Map<String, dynamic>? json) {
    if (json == null) return none;
    int? n(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse('$v');
    }

    return ImpactOverrides(
      quransFunded: n(json['qurans_funded']),
      ordersPlaced: n(json['orders_placed']),
      countries: n(json['countries']),
    );
  }
}

class LegalDocumentsCopy {
  const LegalDocumentsCopy({
    required this.privacyMd,
    required this.termsMd,
    required this.supportMd,
  });

  final String privacyMd;
  final String termsMd;
  final String supportMd;

  /// Empty markdown means the screen should load the bundled asset.
  static const fallback = LegalDocumentsCopy(privacyMd: '', termsMd: '', supportMd: '');

  factory LegalDocumentsCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    return LegalDocumentsCopy(
      privacyMd: json['privacy_md'] is String ? json['privacy_md'] as String : '',
      termsMd: json['terms_md'] is String ? json['terms_md'] as String : '',
      supportMd: json['support_md'] is String ? json['support_md'] as String : '',
    );
  }

  String? markdownFor(String? linkKey) {
    final v = switch (linkKey) {
      'privacy' => privacyMd,
      'terms' => termsMd,
      'support' => supportMd,
      _ => '',
    };
    return v.trim().isEmpty ? null : v;
  }
}

class OnboardingCopy {
  const OnboardingCopy({
    required this.brand,
    required this.introTitle,
    required this.introSubtitle,
    required this.introCta,
    required this.whyTitle,
    required this.whySubtitle,
    required this.skipLabel,
    required this.createAccountCta,
    required this.signInCta,
  });

  final String brand;
  final String introTitle;
  final String introSubtitle;
  final String introCta;
  final String whyTitle;
  final String whySubtitle;
  final String skipLabel;
  final String createAccountCta;
  final String signInCta;

  static const fallback = OnboardingCopy(
    brand: 'Donate Quran',
    introTitle: 'Give the gift\nof Quran',
    introSubtitle: 'Donate, order, read and share the Quran\nthrough one trusted app.',
    introCta: 'GET STARTED',
    whyTitle: 'Why\nDonate Quran?',
    whySubtitle:
        'Your donation helps provide free Qurans to those who need them most. Together, we can spread the message and bring guidance to every heart.',
    skipLabel: 'Skip',
    createAccountCta: 'Create Account',
    signInCta: 'Sign In',
  );

  factory OnboardingCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    return OnboardingCopy(
      brand: _cmsString(json, 'brand', fallback.brand),
      introTitle: _cmsString(json, 'intro_title', fallback.introTitle),
      introSubtitle: _cmsString(json, 'intro_subtitle', fallback.introSubtitle),
      introCta: _cmsString(json, 'intro_cta', fallback.introCta),
      whyTitle: _cmsString(json, 'why_title', fallback.whyTitle),
      whySubtitle: _cmsString(json, 'why_subtitle', fallback.whySubtitle),
      skipLabel: _cmsString(json, 'skip_label', fallback.skipLabel),
      createAccountCta: _cmsString(json, 'create_account_cta', fallback.createAccountCta),
      signInCta: _cmsString(json, 'sign_in_cta', fallback.signInCta),
    );
  }
}

class PermissionsCopy {
  const PermissionsCopy({
    required this.title,
    required this.subtitle,
    required this.notificationsTitle,
    required this.notificationsDescription,
    required this.locationTitle,
    required this.locationDescription,
    required this.continueLabel,
    required this.skipLabel,
  });

  final String title;
  final String subtitle;
  final String notificationsTitle;
  final String notificationsDescription;
  final String locationTitle;
  final String locationDescription;
  final String continueLabel;
  final String skipLabel;

  static const fallback = PermissionsCopy(
    title: 'Allow permissions',
    subtitle:
        'Enable notifications and location for the best experience — order updates, donation receipts, and accurate Qibla direction.',
    notificationsTitle: 'Notifications',
    notificationsDescription: 'Order updates, donation confirmations, and scholar replies.',
    locationTitle: 'Location',
    locationDescription: 'Used for Qibla direction and prayer times near you.',
    continueLabel: 'Continue to app',
    skipLabel: 'Not now',
  );

  factory PermissionsCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    return PermissionsCopy(
      title: _cmsString(json, 'title', fallback.title),
      subtitle: _cmsString(json, 'subtitle', fallback.subtitle),
      notificationsTitle: _cmsString(json, 'notifications_title', fallback.notificationsTitle),
      notificationsDescription: _cmsString(json, 'notifications_description', fallback.notificationsDescription),
      locationTitle: _cmsString(json, 'location_title', fallback.locationTitle),
      locationDescription: _cmsString(json, 'location_description', fallback.locationDescription),
      continueLabel: _cmsString(json, 'continue_label', fallback.continueLabel),
      skipLabel: _cmsString(json, 'skip_label', fallback.skipLabel),
    );
  }
}

class DonationEmailCopy {
  const DonationEmailCopy({
    required this.subjectTemplate,
    required this.intro,
    required this.footer,
  });

  final String subjectTemplate;
  final String intro;
  final String footer;

  static const fallback = DonationEmailCopy(
    subjectTemplate: 'Donation receipt {{receipt_id}}',
    intro: 'Your gift of {{amount}} helps print and distribute Qurans.',
    footer: 'Donations fund Quran printing. Store processing fees may apply; the remainder goes to printing.',
  );

  factory DonationEmailCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    return DonationEmailCopy(
      subjectTemplate: _cmsString(json, 'subject_template', fallback.subjectTemplate),
      intro: _cmsString(json, 'intro', fallback.intro),
      footer: _cmsString(json, 'footer', fallback.footer),
    );
  }
}

class RevenueCatSettings {
  const RevenueCatSettings({required this.offeringId});

  final String offeringId;

  static const fallback = RevenueCatSettings(offeringId: 'default');

  factory RevenueCatSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    return RevenueCatSettings(offeringId: _cmsString(json, 'offering_id', fallback.offeringId));
  }
}

enum LogisticsBodyKind { visaGrid, ihramSteps, emojiTips }

class LogisticsVisaCard {
  const LogisticsVisaCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  factory LogisticsVisaCard.fromJson(Map<String, dynamic> json) {
    final lines = (json['lines'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    return LogisticsVisaCard(title: json['title'] as String? ?? '', lines: lines);
  }
}

class LogisticsTip {
  const LogisticsTip({required this.emoji, required this.text});

  final String emoji;
  final String text;

  factory LogisticsTip.fromJson(Map<String, dynamic> json) {
    return LogisticsTip(
      emoji: json['emoji'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

class LogisticsIhramStep {
  const LogisticsIhramStep({required this.n, required this.title, required this.desc});

  final String n;
  final String title;
  final String desc;

  factory LogisticsIhramStep.fromJson(Map<String, dynamic> json) {
    return LogisticsIhramStep(
      n: json['n'] as String? ?? '',
      title: json['title'] as String? ?? '',
      desc: json['desc'] as String? ?? json['description'] as String? ?? '',
    );
  }
}

class LogisticsItem {
  const LogisticsItem({
    required this.title,
    required this.snippet,
    required this.icon,
    required this.kind,
    this.tips,
    this.ihramSteps,
    this.visaCards,
  });

  final String title;
  final String snippet;
  final String icon;
  final LogisticsBodyKind kind;
  final List<LogisticsTip>? tips;
  final List<LogisticsIhramStep>? ihramSteps;
  final List<LogisticsVisaCard>? visaCards;

  factory LogisticsItem.fromJson(Map<String, dynamic> json) {
    final kindRaw = json['kind'] as String? ?? 'emojiTips';
    final kind = switch (kindRaw) {
      'visaGrid' || 'visa_grid' => LogisticsBodyKind.visaGrid,
      'ihramSteps' || 'ihram_steps' => LogisticsBodyKind.ihramSteps,
      _ => LogisticsBodyKind.emojiTips,
    };
    final tipsRaw = json['tips'] as List?;
    final stepsRaw = json['ihram_steps'] as List?;
    final visaRaw = json['visa_cards'] as List?;
    return LogisticsItem(
      title: json['title'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      icon: json['icon'] as String? ?? 'info_outline',
      kind: kind,
      tips: tipsRaw
          ?.whereType<Map>()
          .map((e) => LogisticsTip.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      ihramSteps: stepsRaw
          ?.whereType<Map>()
          .map((e) => LogisticsIhramStep.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      visaCards: visaRaw
          ?.whereType<Map>()
          .map((e) => LogisticsVisaCard.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class LogisticsGroup {
  const LogisticsGroup({required this.label, required this.items});

  final String label;
  final List<LogisticsItem> items;

  factory LogisticsGroup.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List?;
    return LogisticsGroup(
      label: json['label'] as String? ?? '',
      items: itemsRaw
              ?.whereType<Map>()
              .map((e) => LogisticsItem.fromJson(Map<String, dynamic>.from(e)))
              .where((i) => i.title.isNotEmpty)
              .toList() ??
          const <LogisticsItem>[],
    );
  }
}

class LogisticsCopy {
  const LogisticsCopy({required this.groups});

  final List<LogisticsGroup> groups;

  static const fallback = LogisticsCopy(
    groups: [
      LogisticsGroup(
        label: 'Before You Travel',
        items: [
          LogisticsItem(
            title: 'Umrah Visa',
            snippet: 'e-Visa SAR 535 · Visa on arrival SAR 480',
            icon: 'assignment_turned_in_outlined',
            kind: LogisticsBodyKind.visaGrid,
            visaCards: [
              LogisticsVisaCard(title: 'e-Visa', lines: ['SAR 535 (~£114)', 'Application & insurance included']),
              LogisticsVisaCard(title: 'On Arrival', lines: ['SAR 480 (~£102)', '+ SAR 180 medical (~£38)']),
            ],
          ),
          LogisticsItem(
            title: 'Ihram — What to Know',
            snippet: 'Ghusl · Niyyah · Two unstitched cloths',
            icon: 'checkroom_outlined',
            kind: LogisticsBodyKind.ihramSteps,
            ihramSteps: [
              LogisticsIhramStep(
                n: '1',
                title: 'Ghusl & Prayer',
                desc: 'Perform ghusl (bath) and 2 rakat nafl salah before entering Ihram.',
              ),
              LogisticsIhramStep(
                n: '2',
                title: 'Enter before Meeqat',
                desc:
                    'Ihram must be entered before the meeqat boundary. On a flight, the airline will announce the crossing point.',
              ),
              LogisticsIhramStep(
                n: '3',
                title: 'Wear the Garments',
                desc:
                    'Two white unstitched cloths — izar (lower) and rida (upper). Slippers must leave the middle bone uncovered.',
              ),
            ],
          ),
        ],
      ),
      LogisticsGroup(
        label: 'Holy Sites',
        items: [
          LogisticsItem(
            title: 'Masjid al-Haram, Makkah',
            snippet: 'Grand Mosque tips · Arrive 30 min early',
            icon: 'account_balance_outlined',
            kind: LogisticsBodyKind.emojiTips,
            tips: [
              LogisticsTip(emoji: '🏨', text: 'Take a hotel card so you can find your way back.'),
              LogisticsTip(emoji: '🚪', text: 'Identify the closest door to the Haram from your hotel.'),
              LogisticsTip(emoji: '⏰', text: 'Arrive at least 30 min before salaah time to find a spot.'),
              LogisticsTip(emoji: '🕌', text: "For Jumu'ah, arrive no later than 10am in off-peak seasons."),
            ],
          ),
          LogisticsItem(
            title: 'Masjid an-Nabawi, Madinah',
            snippet: 'Rawdah booking · Respectful adab',
            icon: 'mosque_outlined',
            kind: LogisticsBodyKind.emojiTips,
            tips: [
              LogisticsTip(emoji: '📱', text: 'Book Rawdah visit slots via the Nusuk app in advance.'),
              LogisticsTip(emoji: '🤲', text: "Make du'a quietly and avoid blocking walkways."),
              LogisticsTip(emoji: '👟', text: 'Wear comfortable shoes — you will walk significant distances.'),
            ],
          ),
          LogisticsItem(
            title: 'Jannat al-Baqi',
            snippet: 'Visiting the blessed cemetery',
            icon: 'park_outlined',
            kind: LogisticsBodyKind.emojiTips,
            tips: [
              LogisticsTip(emoji: '🕊️', text: "Visit with humility and make du'a for the deceased companions."),
              LogisticsTip(emoji: '📵', text: 'Photography is discouraged — focus on reflection and prayer.'),
            ],
          ),
        ],
      ),
      LogisticsGroup(
        label: 'Apps & Booking',
        items: [
          LogisticsItem(
            title: 'Nusuk App',
            snippet: 'Official Saudi pilgrimage platform',
            icon: 'smartphone_outlined',
            kind: LogisticsBodyKind.emojiTips,
            tips: [
              LogisticsTip(emoji: '📲', text: 'Download Nusuk for Umrah permits, Rawdah slots, and transport.'),
              LogisticsTip(emoji: '🪪', text: 'Link your passport and visa for seamless check-in.'),
            ],
          ),
          LogisticsItem(
            title: 'Money & Payments',
            snippet: 'SAR cash · Cards widely accepted',
            icon: 'payments_outlined',
            kind: LogisticsBodyKind.emojiTips,
            tips: [
              LogisticsTip(emoji: '💳', text: 'Major credit cards work in hotels and malls.'),
              LogisticsTip(emoji: '💵', text: 'Keep some Saudi Riyals for taxis and small vendors.'),
            ],
          ),
          LogisticsItem(
            title: 'Mobile & Internet',
            snippet: 'eSIM · Local SIM at airport',
            icon: 'wifi_outlined',
            kind: LogisticsBodyKind.emojiTips,
            tips: [
              LogisticsTip(emoji: '📶', text: 'Purchase a local SIM or eSIM at the airport for maps and Nusuk.'),
              LogisticsTip(emoji: '🔋', text: 'Carry a power bank — you will use your phone heavily.'),
            ],
          ),
          LogisticsItem(
            title: 'Haramain Train',
            snippet: 'Makkah ↔ Madinah high-speed rail',
            icon: 'train_outlined',
            kind: LogisticsBodyKind.emojiTips,
            tips: [
              LogisticsTip(emoji: '🚄', text: 'Book train tickets early during peak Hajj and Ramadan seasons.'),
              LogisticsTip(emoji: '🧳', text: 'Arrive at the station at least 60 minutes before departure.'),
            ],
          ),
        ],
      ),
    ],
  );

  factory LogisticsCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    final groupsRaw = json['groups'] as List?;
    final groups = groupsRaw
            ?.whereType<Map>()
            .map((e) => LogisticsGroup.fromJson(Map<String, dynamic>.from(e)))
            .where((g) => g.items.isNotEmpty)
            .toList() ??
        const <LogisticsGroup>[];
    return groups.isNotEmpty ? LogisticsCopy(groups: groups) : fallback;
  }
}
