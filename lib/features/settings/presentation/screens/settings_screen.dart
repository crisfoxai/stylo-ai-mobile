import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/referrals/presentation/providers/referral_provider.dart';
import '../../../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../../../shared/widgets/stylo_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Perfil',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Profile Header
          _ProfileHeader(
            name: user?.fullName ?? 'Usuario',
            email: user?.email ?? '',
            avatarUrl: user?.avatarUrl,
            initials: user?.initials ?? 'U',
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Cuenta section
          _SectionHeader(title: 'Cuenta'),
          _SettingsTile(
            icon: PhosphorIconsRegular.userCircle,
            label: 'Editar perfil',
            onTap: () {},
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.lock,
            label: 'Cambiar contraseña',
            onTap: () {},
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.bell,
            label: 'Notificaciones',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Mi Estilo section
          _SectionHeader(title: 'Mi Estilo'),
          _SettingsTile(
            icon: PhosphorIconsRegular.palette,
            label: 'Perfil de estilo',
            onTap: () => context.go('/style-quiz'),
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.tShirt,
            label: 'Guardarropa',
            onTap: () => context.go('/wardrobe'),
          ),
          Consumer(
            builder: (context, ref, _) {
              final statsAsync = ref.watch(referralStatsProvider);
              final validated = statsAsync.valueOrNull?.validated ?? 0;
              return _SettingsTile(
                icon: PhosphorIconsRegular.usersThree,
                label: 'Referidos',
                onTap: () => context.push('/referrals'),
                trailing: validated > 0
                    ? Badge(
                        label: Text('$validated'),
                        child: const SizedBox(width: 16),
                      )
                    : null,
              );
            },
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Suscripción section
          _SectionHeader(title: 'Suscripción'),
          _SettingsTile(
            icon: PhosphorIconsRegular.crown,
            label: 'Plan Premium',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'FREE',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            onTap: () => context.push('/paywall'),
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.receipt,
            label: 'Historial de compras',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xxl),

          // App section
          _SectionHeader(title: 'App'),
          _SettingsTile(
            icon: PhosphorIconsRegular.moon,
            label: 'Apariencia',
            onTap: () {},
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.translate,
            label: 'Idioma',
            trailing: Text(
              'Español',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            onTap: () {},
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.info,
            label: 'Versión',
            trailing: Text(
              '1.0.0',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            onTap: null,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Legal section
          _SectionHeader(title: 'Legal'),
          _SettingsTile(
            icon: PhosphorIconsRegular.fileText,
            label: 'Términos y condiciones',
            onTap: () {},
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.shieldCheck,
            label: 'Política de privacidad',
            onTap: () {},
          ),
          _SettingsTile(
            icon: PhosphorIconsRegular.cookie,
            label: 'Política de cookies',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Debug section — only visible in debug builds
          if (kDebugMode) ...[
            _SectionHeader(title: '[DEBUG]'),
            _DebugUpgradeButton(),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Sign out button
          StyloButton(
            label: 'Cerrar sesión',
            variant: StyloButtonVariant.destructive,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  title: Text(
                    'Cerrar sesión',
                    style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
                  ),
                  content: Text(
                    '¿Estás seguro de que querés cerrar sesión?',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(
                        'Cancelar',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(
                        'Cerrar sesión',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) context.go('/auth');
              }
            },
          ),
          const SizedBox(height: AppSpacing.xxxxl),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final String initials;

  const _ProfileHeader({
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.accentSubtle,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    initials,
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.accent,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            PhosphorIconsRegular.pencilSimple,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
        left: AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DebugUpgradeButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DebugUpgradeButton> createState() => _DebugUpgradeButtonState();
}

class _DebugUpgradeButtonState extends ConsumerState<_DebugUpgradeButton> {
  bool _loading = false;

  Future<void> _devUpgrade() async {
    setState(() => _loading = true);
    try {
      final dio = ref.read(apiClientProvider);
      await dio.post<void>(
        '/subscriptions/dev-upgrade',
        data: {'plan': 'pro_unlimited'},
      );
      await ref.read(subscriptionProvider.notifier).fetchStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan actualizado a Pro Unlimited')),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('DioException')
            ? 'Error al conectar con el servidor'
            : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B69),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFF7C3AED), width: 1),
      ),
      child: ListTile(
        onTap: _loading ? null : _devUpgrade,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        leading: const Icon(Icons.bug_report, size: 22, color: Color(0xFFA78BFA)),
        title: Text(
          'Activar Pro Unlimited (dev)',
          style: AppTypography.bodyMedium.copyWith(color: const Color(0xFFA78BFA)),
        ),
        trailing: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFA78BFA),
                ),
              )
            : const Icon(
                PhosphorIconsRegular.caretRight,
                size: 16,
                color: Color(0xFFA78BFA),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        leading: Icon(icon, size: 22, color: AppColors.textSecondary),
        title: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 16,
                    color: AppColors.textTertiary,
                  )
                : null),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
