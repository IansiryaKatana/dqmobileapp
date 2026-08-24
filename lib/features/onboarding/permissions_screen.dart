import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_state_provider.dart';
import '../../core/services/content_repository.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dq_theme.dart';
import '../../shared/widgets/dq_buttons.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _notificationsGranted = false;
  bool _locationGranted = false;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final notif = await PushNotificationService.hasOsPermission();
    var loc = false;
    final perm = await Geolocator.checkPermission();
    loc = perm == LocationPermission.always || perm == LocationPermission.whileInUse;
    if (mounted) {
      setState(() {
        _notificationsGranted = notif;
        _locationGranted = loc;
      });
    }
  }

  Future<void> _enableNotifications() async {
    setState(() => _requesting = true);
    final granted = await PushNotificationService.requestPermission();
    final user = ref.read(appStateProvider).user;
    if (granted && user?.id != null) {
      await PushNotificationService.syncTokenForUser(user!.id!);
    }
    if (mounted) {
      setState(() {
        _notificationsGranted = granted;
        _requesting = false;
      });
    }
  }

  Future<void> _enableLocation() async {
    setState(() => _requesting = true);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (mounted) {
      setState(() {
        _locationGranted =
            permission == LocationPermission.always || permission == LocationPermission.whileInUse;
        _requesting = false;
      });
    }
  }

  Future<void> _continue() async {
    await ref.read(appStateProvider.notifier).completePermissionsPrompt();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final copy = ref.watch(permissionsCopyProvider).valueOrNull ?? PermissionsCopy.fallback;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                copy.title,
                style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                copy.subtitle,
                style: context.text.bodyMedium?.copyWith(color: context.dq.muted, height: 1.5),
              ),
              const SizedBox(height: 32),
              _PermissionCard(
                icon: Icons.notifications_outlined,
                title: copy.notificationsTitle,
                description: copy.notificationsDescription,
                granted: _notificationsGranted,
                onEnable: _requesting ? null : _enableNotifications,
              ),
              const SizedBox(height: 12),
              _PermissionCard(
                icon: Icons.explore_outlined,
                title: copy.locationTitle,
                description: copy.locationDescription,
                granted: _locationGranted,
                onEnable: _requesting ? null : _enableLocation,
              ),
              const Spacer(),
              DqPrimaryButton(
                label: copy.continueLabel,
                onPressed: _requesting ? null : _continue,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _requesting ? null : _continue,
                  child: Text(copy.skipLabel, style: TextStyle(color: context.dq.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.onEnable,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final VoidCallback? onEnable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.dq.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.navy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: context.dq.muted, height: 1.4)),
                const SizedBox(height: 10),
                if (granted)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.yellow, size: 18),
                      SizedBox(width: 6),
                      Text('Enabled', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
                    ],
                  )
                else
                  TextButton(
                    onPressed: onEnable,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Enable', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
