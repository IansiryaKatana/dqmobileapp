import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/content_repository.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/dq_buttons.dart';

class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
    this.linkKey,
  });

  final String title;
  final String assetPath;
  final String? linkKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(externalLinksProvider).valueOrNull ?? ExternalLinksCopy.fallback;
    final webUrl = linkKey == null ? null : links.urlFor(linkKey!);
    final docs = ref.watch(legalDocumentsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: title, onBack: () => context.pop()),
            Expanded(
              child: docs.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _BundledMarkdown(assetPath: assetPath),
                data: (legal) {
                  final cms = legal.markdownFor(linkKey);
                  if (cms != null) {
                    return _LegalMarkdown(data: cms);
                  }
                  return _BundledMarkdown(assetPath: assetPath);
                },
              ),
            ),
            if (webUrl != null && webUrl.startsWith('http'))
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: TextButton(
                  onPressed: () => launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication),
                  child: const Text('Open on website'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BundledMarkdown extends StatelessWidget {
  const _BundledMarkdown({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: rootBundle.loadString(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load this document.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _LegalMarkdown(data: snapshot.data!);
      },
    );
  }
}

class _LegalMarkdown extends StatelessWidget {
  const _LegalMarkdown({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: const TextStyle(fontSize: 15, height: 1.55, color: AppColors.muted),
        h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.charcoal),
        h2: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
      ),
      onTapLink: (text, href, title) {
        if (href == null) return;
        launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
      },
    );
  }
}
