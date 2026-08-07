import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_spacing.dart';
import 'dq_buttons.dart';

class DqWebScreen extends StatelessWidget {
  const DqWebScreen({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  static Future<void> open(BuildContext context, {required String title, required String url}) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: title, onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    const Icon(Icons.open_in_new, size: 48),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'This page opens in your browser.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    DqPrimaryButton(
                      label: 'Open $title',
                      onPressed: () => open(context, title: title, url: url),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
