import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/referral_provider.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  bool _isApplyingCode = false;
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty || _isApplyingCode) return;
    setState(() => _isApplyingCode = true);
    try {
      await applyReferralCode(ref, code);
      _codeController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Código aplicado con éxito!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_referralErrorMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplyingCode = false);
    }
  }

  static String _referralErrorMessage(dynamic e) {
    try {
      final data = (e as dynamic).response?.data;
      if (data is Map) {
        switch (data['error']?.toString()) {
          case 'SELF_REFERRAL':
            return 'No podés usar tu propio código de referido';
          case 'ALREADY_REFERRED':
            return 'Ya tenés un código de referido aplicado en tu cuenta';
          case 'INVALID_CODE':
            return 'El código ingresado no es válido';
          case 'CODE_ABUSE':
            return 'No podés aplicar más códigos por ahora';
        }
      }
    } catch (_) {}
    return AppException.extractMessage(e);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(referralStatsProvider);

    return Scaffold(
      key: const Key('referral_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Referidos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppException.extractMessage(e),
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => ref.invalidate(referralStatsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (stats) => LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My code card
                  _CodeCard(
                    code: stats.referralCode,
                    referralLink: stats.referralLink,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Bonus status
                  _BonusCard(
                    bonusDaysActive: stats.bonusDaysActive,
                    premiumAccessUntil: stats.premiumAccessUntil,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats row
                  _StatsRow(
                    totalReferred: stats.totalReferred,
                    validated: stats.validated,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // How it works
                  const _HowItWorksSection(),
                  const SizedBox(height: AppSpacing.xl),

                  // Apply a code — hidden once user already has a referral applied
                  if (!stats.alreadyReferred) ...[
                    _ApplyCodeSection(
                      controller: _codeController,
                      isLoading: _isApplyingCode,
                      onApply: _applyCode,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String code;
  final String referralLink;

  const _CodeCard({required this.code, required this.referralLink});

  static bool _codeIsValid(String c) =>
      c.isNotEmpty && c != 'undefined' && c != 'null';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Tu código de referido',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.md),
          _codeIsValid(code)
              ? Text(
                  code,
                  key: const Key('referral_code_text'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                  ),
                )
              : const Text(
                  key: Key('referral_code_text'),
                  'Generando...',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                key: const Key('copy_code_btn'),
                onPressed: _codeIsValid(code)
                    ? () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código copiado')),
                        );
                      }
                    : null,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  disabledForegroundColor: Colors.white24,
                ),
              ),
              ElevatedButton.icon(
                key: const Key('share_code_btn'),
                onPressed: _codeIsValid(code)
                    ? () {
                        Share.share(
                          '¡Unite a Stylo AI con mi código $code y conseguís 30 días premium gratis! $referralLink',
                          subject: 'Invitación a Stylo AI',
                        );
                      }
                    : null,
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Compartir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BonusCard extends StatelessWidget {
  final bool bonusDaysActive;
  final String? premiumAccessUntil;

  const _BonusCard({required this.bonusDaysActive, this.premiumAccessUntil});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bonusDaysActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: bonusDaysActive ? AppColors.success : AppColors.border,
        ),
      ),
      child: bonusDaysActive
          ? Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Bonus activo!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (premiumAccessUntil != null)
                        Text(
                          'Premium gratis hasta: ${_formatDate(premiumAccessUntil!)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : const Row(
              children: [
                Text('🎁', style: TextStyle(fontSize: 24)),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '¡Conseguí 30 días premium gratis por cada amigo que se suscriba!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      const months = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _StatsRow extends StatelessWidget {
  final int totalReferred;
  final int validated;

  const _StatsRow({required this.totalReferred, required this.validated});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            value: '$totalReferred',
            label: 'Invitados',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatBox(
            value: '$validated',
            label: 'Suscritos',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatBox(
            value: '${validated * 30}d',
            label: 'Días ganados',
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cómo funciona',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StepCard(
                step: '1',
                icon: '📤',
                title: 'Compartí tu código',
                desc: 'Enviá tu link a amigos y familia',
              ),
              const SizedBox(width: AppSpacing.md),
              _StepCard(
                step: '2',
                icon: '📱',
                title: 'Se registran',
                desc: 'Usan tu código al crear su cuenta',
              ),
              const SizedBox(width: AppSpacing.md),
              _StepCard(
                step: '3',
                icon: '🎉',
                title: 'Ambos ganan',
                desc: '+30 días premium para vos y para ellos',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String icon;
  final String title;
  final String desc;

  const _StepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            desc,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyCodeSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onApply;

  const _ApplyCodeSection({
    required this.controller,
    required this.isLoading,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Tenés un código de referido?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('referral_code_input'),
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'AX4S12',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton(
              key: const Key('apply_code_btn'),
              onPressed: isLoading ? null : onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.textOnPrimary),
                    )
                  : const Text('Aplicar'),
            ),
          ],
        ),
      ],
    );
  }
}
