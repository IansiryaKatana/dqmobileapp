import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/checkout_args.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/router/root_nav.dart';
import '../../core/services/content_repository.dart';
import '../../core/services/content_service.dart';
import '../../core/services/bookmark_service.dart';
import '../../core/services/navigation_repository.dart';
import '../../core/services/scholar_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/widgets/dq_featured_guide_card.dart';
import '../../shared/widgets/kaaba_icon.dart';
import '../../shared/utils/dq_refresh.dart';
import '../../shared/utils/error_messages.dart';
import '../../shared/utils/validators.dart';
import '../../shared/widgets/cms_fallback_banner.dart';
import '../../shared/widgets/figma_components.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appStateProvider).user;
    final menuAsync = ref.watch(moreMenuProvider);

    return Column(
      children: [
        const CmsFallbackBanner(),
        Expanded(
          child: menuAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _MoreBody(menu: NavigationMenuFallback.menu, user: user),
            data: (menu) => _MoreBody(menu: menu, user: user),
          ),
        ),
      ],
    );
  }
}

class _MoreBody extends ConsumerWidget {
  const _MoreBody({required this.menu, required this.user});

  final MoreMenuData menu;
  final AppUser? user;

  Future<void> _onRefresh(WidgetRef ref) {
    return dqPullRefresh(
      ref,
      invalidate: [moreMenuProvider],
      awaitExtras: () => ref.read(moreMenuProvider.future).then((_) {}),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = [
      ('Actions', menu.actions),
      ('Learn', menu.learn),
      ('Support', menu.support),
      ('Account', menu.account),
    ];

    final featured = menu.featured;

    return RefreshIndicator(
      onRefresh: () => _onRefresh(ref),
      child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Material(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => pushRootRoute(context, user == null ? '/login' : '/profile'),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.yellow.withValues(alpha: 0.12),
                      border: Border.all(color: AppColors.yellow.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.person_outline, color: AppColors.yellow, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest User',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          user?.email ?? 'Sign in to track donations',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 18),
                ],
              ),
            ),
          ),
        ),
        if (featured != null) ...[
          const SizedBox(height: 16),
          DqFeaturedGuideCard(
            badge: featured.badge ?? 'Featured Guide',
            title: featured.label,
            subtitle: featured.subtitle ?? '',
            leading: const KaabaIcon(size: 42),
            onTap: () => pushRootRoute(context, featured.route),
          ),
        ],
        const SizedBox(height: 16),
        ...sections.map((section) {
          final (title, items) = section;
          if (items.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: context.dq.muted,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.dq.cardBorder),
                  ),
                  child: Column(
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => pushRootRoute(context, item.route),
                          child: Container(
                            decoration: BoxDecoration(
                              border: i > 0 ? Border(top: BorderSide(color: context.dq.cardBorder)) : null,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(item.iconData, color: context.colors.onSurface, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(item.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.onSurface)),
                                ),
                                Icon(Icons.chevron_right, color: context.dq.muted, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }),
        if (user == null)
          Center(
            child: TextButton(
              onPressed: () => pushRootRoute(context, '/login'),
              child: const Text('Sign In', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    ),
    );
  }
}

class AskScholarScreen extends ConsumerStatefulWidget {
  const AskScholarScreen({super.key});

  @override
  ConsumerState<AskScholarScreen> createState() => _AskScholarScreenState();
}

class _AskScholarScreenState extends ConsumerState<AskScholarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _question = TextEditingController();
  String _topic = 'General';
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _question.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(appStateProvider).user;
      final referenceId = await ref.read(scholarRepositoryProvider).submitQuestion(
            name: _name.text.trim(),
            email: _email.text.trim(),
            topic: _topic,
            question: _question.text.trim(),
            userId: user?.id,
          );
      if (!mounted) return;
      context.go('/ask-scholar/success', extra: ScholarSuccessArgs(referenceId: referenceId));
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
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Ask A Scholar', onBack: () => context.pop()),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('Have a question about Islam or living life as a Muslim?', style: TextStyle(fontSize: 15, color: context.dq.muted, height: 1.5)),
                    const SizedBox(height: 20),
                    TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: Validators.name),
                    const SizedBox(height: 12),
                    TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: Validators.email),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _topic,
                      decoration: const InputDecoration(labelText: 'Topic'),
                      items: ['General', 'Prayer', 'Quran', 'New Muslim'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _topic = v ?? 'General'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _question,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Your question', alignLabelWithHint: true),
                      validator: (v) => Validators.required(v, field: 'Question'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DqPrimaryButton(label: _loading ? 'Submitting...' : 'Submit Question', onPressed: _loading ? null : _submit),
            ),
          ],
        ),
      ),
    );
  }
}

class ScholarSuccessScreen extends StatelessWidget {
  const ScholarSuccessScreen({super.key, required this.referenceId});
  final String referenceId;

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
              Text('Question submitted', style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Reference: $referenceId', style: TextStyle(color: context.dq.muted)),
              const Spacer(),
              DqPrimaryButton(label: 'Back to Home', onPressed: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }
}

class NewMuslimScreen extends StatelessWidget {
  const NewMuslimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DqScreenHeader(title: 'New to Islam', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const DqSectionLabel('Start Here'),
                  DqMenuGroup(
                    items: [
                      DqMenuItem(label: 'What is Islam?', onTap: () => context.push('/what-is-islam'), icon: Icons.mosque_outlined),
                      DqMenuItem(label: 'What is the Quran?', onTap: () => context.push('/what-is-quran'), icon: Icons.menu_book_outlined),
                      DqMenuItem(label: 'Who is Prophet Muhammad ﷺ?', onTap: () => context.push('/who-is-prophet'), icon: Icons.person_outline),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const DqSectionLabel('Practice'),
                  DqMenuGroup(
                    items: [
                      DqMenuItem(label: 'How to Pray', onTap: () => context.push('/how-to-pray'), icon: Icons.self_improvement_outlined),
                      DqMenuItem(label: 'How to Make Wudu', onTap: () => context.push('/wudu-guide'), icon: Icons.water_drop_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const DqSectionLabel('Resources'),
                  DqMenuGroup(
                    items: [
                      DqMenuItem(label: 'Umrah & Hajj Guide', onTap: () => context.push('/umrah-hajj'), icon: Icons.flight_takeoff),
                      DqMenuItem(label: 'Order a Free Quran', onTap: () => context.push('/order'), icon: Icons.inventory_2_outlined),
                      DqMenuItem(label: 'Ask a Scholar', onTap: () => context.push('/ask-scholar'), icon: Icons.chat_bubble_outline),
                    ],
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

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) {
    return dqPullRefresh(
      ref,
      invalidate: [articlesProvider, booksProvider],
      awaitExtras: () async {
        await Future.wait([
          ref.read(articlesProvider.future),
          ref.read(booksProvider.future),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);
    final booksAsync = ref.watch(booksProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Learn', onBack: () => context.pop()),
            const CmsFallbackBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _onRefresh(ref),
                child: articlesAsync.when(
                  loading: () => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  error: (_, __) => _learnList(context, ContentService.articles, ContentService.books),
                  data: (articles) => booksAsync.when(
                    loading: () => _learnList(context, articles, const []),
                    error: (_, __) => _learnList(context, articles, ContentService.books),
                    data: (books) => _learnList(context, articles, books),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _learnList(BuildContext context, List<Article> articles, List<Article> books) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const DqSectionLabel('Foundations of Faith'),
        DqMenuGroup(
          items: [
            DqMenuItem(label: 'New Muslim Guide', onTap: () => context.push('/new-muslim'), icon: Icons.public_outlined),
            DqMenuItem(label: 'What is Islam?', onTap: () => context.push('/what-is-islam'), icon: Icons.mosque_outlined),
            DqMenuItem(label: 'What is the Quran?', onTap: () => context.push('/what-is-quran'), icon: Icons.menu_book_outlined),
            DqMenuItem(label: 'Who is Prophet Muhammad ﷺ?', onTap: () => context.push('/who-is-prophet'), icon: Icons.person_outline),
          ],
        ),
        const SizedBox(height: 16),
        const DqSectionLabel('Articles'),
        ...articles.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => context.push('/learn/article', extra: a.id),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.dq.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: context.colors.onSurface)),
                      const SizedBox(height: 4),
                      Text(a.summary, style: TextStyle(color: context.dq.muted, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 8),
                      const Text('Read →', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const DqSectionLabel('Books & Articles'),
        ...books.map(
          (book) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => context.push('/learn/article', extra: book.id),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.dq.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: context.colors.onSurface)),
                            Text(book.summary, style: TextStyle(color: context.dq.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.dq.muted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleByIdProvider(articleId));
    return articleAsync.when(
      loading: () => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              DqScreenHeader(title: 'Article', onBack: () => context.pop()),
              const Expanded(child: DqLoadingOverlay(message: 'Loading article...')),
            ],
          ),
        ),
      ),
      error: (_, __) => _articleScaffold(context, ref, ContentService.articleById(articleId)),
      data: (article) => _articleScaffold(context, ref, article),
    );
  }

  Widget _articleScaffold(BuildContext context, WidgetRef ref, Article? article) {
    if (article == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              DqScreenHeader(title: 'Article', onBack: () => context.pop()),
              const Expanded(child: DqEmptyState(icon: Icons.article_outlined, title: 'Not found', message: 'This article is unavailable.')),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: article.title, onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(article.summary, style: TextStyle(color: context.dq.muted)),
                  const SizedBox(height: 16),
                  Text(article.body, style: const TextStyle(height: 1.6, fontSize: 15)),
                  const SizedBox(height: 24),
                  DqPrimaryButton(
                    label: article.topic == 'Books' ? 'Save Book' : 'Save Article',
                    onPressed: () async {
                      final service = await ref.read(bookmarkServiceProvider.future);
                      if (article.topic == 'Books') {
                        await service.addBook(SavedBook(bookId: article.id, title: article.title, savedAt: DateTime.now()));
                      } else {
                        await service.addArticle(SavedArticle(articleId: article.id, title: article.title, savedAt: DateTime.now()));
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to your library')));
                      }
                    },
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
