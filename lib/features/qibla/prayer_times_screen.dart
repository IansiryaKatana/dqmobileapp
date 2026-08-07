import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/prayer_times_service.dart';
import '../../core/services/qibla_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/widgets/dq_buttons.dart';
import '../../shared/widgets/dq_states.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerTimes? _times;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final qibla = await QiblaService.loadLocationBearing();
      if (!qibla.hasPermission || qibla.latitude == null || qibla.longitude == null) {
        if (mounted) {
          setState(() {
            _error = qibla.errorMessage ?? 'Location permission needed';
            _loading = false;
          });
        }
        return;
      }
      final times = await PrayerTimesService.fetch(
        latitude: qibla.latitude!,
        longitude: qibla.longitude!,
      );
      if (mounted) setState(() { _times = times; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load prayer times'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(title: 'Prayer Times', onBack: () => context.pop()),
            Expanded(
              child: _loading
                  ? const DqLoadingOverlay(message: 'Loading prayer times...')
                  : _error != null
                      ? DqEmptyState(
                          icon: Icons.access_time,
                          title: _error!,
                          message: 'Enable location and try again.',
                          action: DqPrimaryButton(label: 'Retry', onPressed: _load),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(_times!.date, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ..._times!.entries.map(
                              (e) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                                  border: Border.all(color: context.dq.cardBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(e.$2, style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold, fontSize: 18)),
                                  ],
                                ),
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
