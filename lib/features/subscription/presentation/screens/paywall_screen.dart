import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/referrals/presentation/providers/referral_provider.dart';
import '../../../../shared/widgets/stylo_button.dart';
import '../../application/iap_service.dart';
import '../../domain/entities/subscription.dart';
import '../providers/subscription_provider.dart';

enum PaywallFeature { tryon, chat, moreOutfits, unlimitedWardrobe }

extension _PaywallFeatureX on PaywallFeature {
  String get headline {
    return switch (this) {
      PaywallFeature.tryon => 'Probate la ropa antes de comprarla',
      PaywallFeature.chat => 'Tu estilista personal, disponible 24/7',
      PaywallFeature.moreOutfits => 'Outfits ilimitados para cada ocasión',
      PaywallFeature.unlimitedWardrobe => 'Guardarropa sin límites',
    };
  }

  String get subtitle {
    return switch (this) {
      PaywallFeature.tryon => 'El try-on virtual está disponible en los planes Pro y Pro Unlimited.',
      PaywallFeature.chat => 'El chat con el estilista AI está disponible en Stylist, Pro y Pro Unlimited.',
      PaywallFeature.moreOutfits => 'Outfits ilimitados con Stylist, Pro y Pro Unlimited.',
      PaywallFeature.unlimitedWardrobe => 'Guardá prendas ilimitadas con Stylist, Pro y Pro Unlimited.',
    };
  }

  SubscriptionPlan get minimumPlan {
    return switch (this) {
      PaywallFeature.tryon => SubscriptionPlan.pro,
      PaywallFeature.chat => SubscriptionPlan.stylist,
      PaywallFeature.moreOutfits => SubscriptionPlan.stylist,
      PaywallFeature.unlimitedWardrobe => SubscriptionPlan.stylist,
    };
  }
}

final _productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final service = ref.read(iapServiceProvider);
  final available = await service.isAvailable;
  if (!available) return [];
  return service.loadProducts();
});

class PaywallScreen extends ConsumerStatefulWidget {
  final PaywallFeature? feature;

  const PaywallScreen({super.key, this.feature});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenPurchases());
  }

  void _listenPurchases() {
    ref.read(iapServiceProvider).listenToPurchases((purchases) async {
      for (final purchase in purchases) {
        await _handlePurchase(purchase);
      }
    });
  }

  Future<void> _handlePurchase(PurchaseDetails details) async {
    final iapService = ref.read(iapServiceProvider);
    switch (details.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await iapService.completePurchase(details);
        await ref.read(subscriptionNotifierProvider.notifier).verifyPurchase(
              productId: details.productID,
              receiptData: iapService.receiptDataFor(details),
              platform: iapService.platform,
            );
        if (mounted) {
          Navigator.of(context).pop();
          _showReferralCta();
        }
      case PurchaseStatus.error:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                details.error?.message ?? 'Error al procesar la compra',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      case PurchaseStatus.pending:
        break;
      case PurchaseStatus.canceled:
        break;
    }
  }

  void _showReferralCta() {
    final stats = ref.read(referralStatsProvider).valueOrNull;
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.md),
              const Text(
                '¡Conseguiste Stylo AI Pro!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Compartí tu código y ganás 30 días extra por cada amigo/a que se suscriba.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('post_purchase_share_btn'),
                  onPressed: () {
                    final code = stats?.referralCode ?? '';
                    final link = stats?.referralLink ?? 'https://stylo.ai/join/$code';
                    Share.share(
                      '¡Unite a Stylo AI con mi código $code y conseguís 30 días premium gratis! $link',
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir código'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Ahora no',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Future<void> _buySelected(List<ProductDetails> products) async {
    final productId = _selectedProductId;
    if (productId == null) return;
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => products.first,
    );
    await ref.read(iapServiceProvider).buyProduct(product);
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final productsAsync = ref.watch(_productsProvider);
    final feature = widget.feature;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'STYLO',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      PhosphorIconsRegular.x,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.accentSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        PhosphorIconsFill.crown,
                        size: 48,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      feature?.headline ?? 'Desbloquea todo con\nStylo Premium',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      feature?.subtitle ??
                          'Tu asistente de moda personal, impulsado por IA',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    _TierComparisonTable(minimumPlan: feature?.minimumPlan),
                    const SizedBox(height: AppSpacing.xxxl),
                    productsAsync.when(
                      data: (products) => _ProductSelector(
                        products: products,
                        selectedId: _selectedProductId ??
                            (products.isNotEmpty ? products.first.id : null),
                        onSelected: (id) =>
                            setState(() => _selectedProductId = id),
                        minimumPlan: feature?.minimumPlan,
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const _StaticPriceCard(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  productsAsync.when(
                    data: (products) => StyloButton(
                      label: 'Empezar trial gratis',
                      isLoading: subscriptionState.isLoading,
                      onPressed: products.isEmpty
                          ? null
                          : () => _buySelected(products),
                    ),
                    loading: () => StyloButton(
                      label: 'Empezar trial gratis',
                      isLoading: true,
                      onPressed: null,
                    ),
                    error: (_, __) => StyloButton(
                      label: 'Empezar trial gratis',
                      isLoading: false,
                      onPressed: null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '7 días gratis, luego según plan elegido. Cancelá cuando quieras.',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
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

class _TierComparisonTable extends StatelessWidget {
  final SubscriptionPlan? minimumPlan;

  const _TierComparisonTable({this.minimumPlan});

  static const _features = [
    (label: 'Guardarropa digital', stylist: true, pro: true, proUnlimited: true),
    (label: 'Outfits ilimitados', stylist: true, pro: true, proUnlimited: true),
    (label: 'Chat estilista AI (30/mes)', stylist: true, pro: false, proUnlimited: false),
    (label: 'Chat estilista AI (ilimitado)', stylist: false, pro: true, proUnlimited: true),
    (label: 'Prueba virtual Try-On (20/mes)', stylist: false, pro: true, proUnlimited: false),
    (label: 'Prueba virtual Try-On (80/mes)', stylist: false, pro: false, proUnlimited: true),
  ];

  bool _isHighlighted(SubscriptionPlan plan) {
    if (minimumPlan == null) return plan == SubscriptionPlan.pro;
    return switch (minimumPlan!) {
      SubscriptionPlan.stylist => plan == SubscriptionPlan.stylist,
      SubscriptionPlan.pro => plan == SubscriptionPlan.pro,
      SubscriptionPlan.proUnlimited => plan == SubscriptionPlan.proUnlimited,
      SubscriptionPlan.free => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                _PlanHeader(label: 'Stylist', highlighted: _isHighlighted(SubscriptionPlan.stylist), price: '\$5.99'),
                _PlanHeader(label: 'Pro', highlighted: _isHighlighted(SubscriptionPlan.pro), price: '\$11.99'),
                _PlanHeader(label: 'Pro ∞', highlighted: _isHighlighted(SubscriptionPlan.proUnlimited), price: '\$19.99'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ..._features.asMap().entries.map((entry) {
            final isLast = entry.key == _features.length - 1;
            final f = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          f.label,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      _CheckCell(value: f.stylist, highlighted: _isHighlighted(SubscriptionPlan.stylist)),
                      _CheckCell(value: f.pro, highlighted: _isHighlighted(SubscriptionPlan.pro)),
                      _CheckCell(value: f.proUnlimited, highlighted: _isHighlighted(SubscriptionPlan.proUnlimited)),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
          // Pricing row
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Plan mensual',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                _PriceCell(price: '\$5.99', highlighted: _isHighlighted(SubscriptionPlan.stylist)),
                _PriceCell(price: '\$11.99', highlighted: _isHighlighted(SubscriptionPlan.pro)),
                _PriceCell(price: '\$19.99', highlighted: _isHighlighted(SubscriptionPlan.proUnlimited)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  final String label;
  final String price;
  final bool highlighted;

  const _PlanHeader({required this.label, required this.highlighted, required this.price});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: highlighted ? AppColors.accent : AppColors.textSecondary,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          if (highlighted)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              color: AppColors.accent,
            ),
        ],
      ),
    );
  }
}

class _CheckCell extends StatelessWidget {
  final bool value;
  final bool highlighted;

  const _CheckCell({required this.value, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Center(
        child: Icon(
          value ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.xCircle,
          size: 18,
          color: value
              ? (highlighted ? AppColors.accent : AppColors.success)
              : AppColors.border,
        ),
      ),
    );
  }
}

class _PriceCell extends StatelessWidget {
  final String price;
  final bool highlighted;

  const _PriceCell({required this.price, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Text(
        price,
        style: AppTypography.labelSmall.copyWith(
          color: highlighted ? AppColors.accent : AppColors.textSecondary,
          fontWeight: highlighted ? FontWeight.w700 : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ProductSelector extends StatelessWidget {
  final List<ProductDetails> products;
  final String? selectedId;
  final void Function(String) onSelected;
  final SubscriptionPlan? minimumPlan;

  const _ProductSelector({
    required this.products,
    required this.selectedId,
    required this.onSelected,
    this.minimumPlan,
  });

  bool _isRecommended(ProductDetails product) {
    final plan = kProductTierMap[product.id];
    if (plan == null) return false;
    return plan == (minimumPlan ?? SubscriptionPlan.pro);
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const _StaticPriceCard();
    return Column(
      children: products
          .map(
            (p) => GestureDetector(
              onTap: () => onSelected(p.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: selectedId == p.id
                      ? AppColors.accentSubtle
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: selectedId == p.id
                        ? AppColors.accent
                        : AppColors.border,
                    width: selectedId == p.id ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p.title,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_isRecommended(p)) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'RECOMENDADO',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            p.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      p.price,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StaticPriceCard extends StatelessWidget {
  const _StaticPriceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.12),
            AppColors.accentSubtle,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan mensual',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$11.99',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '/mes',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'POPULAR',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
