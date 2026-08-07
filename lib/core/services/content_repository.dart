import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import 'content_service.dart';

class CmsListResult<T> {
  const CmsListResult(this.items, {this.usedFallback = false});

  final List<T> items;
  final bool usedFallback;
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

class DonateCopy {
  const DonateCopy({
    required this.tagline,
    required this.guestMessage,
  });

  final String tagline;
  final String guestMessage;

  static const fallback = DonateCopy(
    tagline: '100% of public donations go towards Quran printing.',
    guestMessage: 'No account needed — donate as a guest or sign in later to track receipts.',
  );

  factory DonateCopy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;
    return DonateCopy(
      tagline: (json['tagline'] as String?)?.trim().isNotEmpty == true
          ? json['tagline'] as String
          : fallback.tagline,
      guestMessage: (json['guest_message'] as String?)?.trim().isNotEmpty == true
          ? json['guest_message'] as String
          : fallback.guestMessage,
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

/// Shared flag set when any CMS fetch falls back to static bundles.
final cmsFallbackFlagProvider = StateProvider<bool>((ref) => false);

class OrderCatalogProduct {
  const OrderCatalogProduct({
    required this.title,
    required this.description,
    required this.routeTitle,
    required this.qtyLabel,
    required this.cta,
  });

  final String title;
  final String description;
  final String routeTitle;
  final String qtyLabel;
  final String cta;

  factory OrderCatalogProduct.fromJson(Map<String, dynamic> json) {
    return OrderCatalogProduct(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      routeTitle: json['route_title'] as String? ?? json['title'] as String? ?? '',
      qtyLabel: json['qty_label'] as String? ?? '',
      cta: json['cta'] as String? ?? 'Order',
    );
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
    heroTitle: 'Receive or share a free Quran copy',
    heroSubtitle: 'Quran copies are free. Postage and packaging may apply.',
    languages: ['English', 'Arabic'],
    deliveryNote: 'Delivery note: Allow 5–10 business days for dispatch.',
    products: [
      OrderCatalogProduct(
        title: '1 Free Quran Copy',
        description: 'For personal use or to share',
        routeTitle: '1 Free Quran Copy',
        qtyLabel: '1 copy',
        cta: 'Order Free',
      ),
      OrderCatalogProduct(
        title: '2–9 Copies',
        description: 'Share with family and friends',
        routeTitle: '2–9 Copies',
        qtyLabel: '2–9 copies',
        cta: 'Order Now',
      ),
      OrderCatalogProduct(
        title: 'Bulk Order 10+',
        description: 'For mosques and organisations',
        routeTitle: '10+ Copies',
        qtyLabel: '10+ copies',
        cta: 'Bulk Order',
      ),
      OrderCatalogProduct(
        title: 'Pallet Order',
        description: 'Large-scale distribution',
        routeTitle: 'Pallet',
        qtyLabel: '100+ copies',
        cta: 'Get in Touch',
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
    productId: 'dq_postage_399',
    displayPence: 399,
    displayLabel: '£3.99',
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
    privacy: 'https://donatequran.org/privacy',
    terms: 'https://donatequran.org/terms',
    distributor: 'https://donatequran.org/distributor',
    support: 'https://donatequran.org/support',
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
