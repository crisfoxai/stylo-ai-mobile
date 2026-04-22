import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/subscription_provider.dart';

class SubscriptionManageScreen extends ConsumerWidget {
  const SubscriptionManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);
    final subscription = state.subscription;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            PhosphorIconsRegular.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mi suscripción',
          style: AppTypography.headlineSmall
              .copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : subscription == null
                ? _NoPlanView(
                    onUpgrade: () => Navigator.of(context).pushNamed('/paywall'),
                  )
                : _ActivePlanView(subscription: subscription),
      ),
    );
  }
}

class _ActivePlanView extends StatelessWidget {
  final dynamic subscription;

  const _ActivePlanView({required this.subscription});

  String get _planLabel {
    final plan = subscription.plan as String? ?? 'free';
    return plan == 'premium' ? 'Premium' : 'Gratuito';
  }

  String get _renewalDate {
    final expiresAt = subscription.expiresAt as DateTime?;
    if (expiresAt == null) return 'N/A';
    return DateFormat('d MMM yyyy', 'es').format(expiresAt);
  }

  String get _platformLabel {
    final platform = subscription.platform as String? ?? '';
    if (platform == 'ios') return 'App Store';
    if (platform == 'android') return 'Google Play';
    return platform;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsFill.crown,
                      color: AppColors.accent,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Plan $_planLabel',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(label: 'Estado', value: 'Activo'),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(label: 'Renovación', value: _renewalDate),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(label: 'Plataforma', value: _platformLabel),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Gestionar suscripción',
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _ManageButton(
            icon: PhosphorIconsRegular.arrowSquareOut,
            label: 'Administrar en ${Platform.isIOS ? 'App Store' : 'Google Play'}',
            onTap: () => _openStoreManagement(),
          ),
        ],
      ),
    );
  }

  Future<void> _openStoreManagement() async {
    final uri = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _NoPlanView extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _NoPlanView({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              PhosphorIconsRegular.crown,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sin plan activo',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Actualizá a Premium para desbloquear todas las funciones.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            FilledButton(
              onPressed: onUpgrade,
              child: const Text('Ver planes Premium'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ManageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ManageButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
            const Icon(
              PhosphorIconsRegular.caretRight,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
