import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/stylo_button.dart';
import '../../application/iap_service.dart';
import '../providers/subscription_provider.dart';

final _productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final service = ref.read(iapServiceProvider);
  final available = await service.isAvailable;
  if (!available) return [];
  return service.loadProducts();
});

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

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
        if (mounted) Navigator.of(context).pop();
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
                      'Desbloquea todo con\nStylo Premium',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tu asistente de moda personal, impulsado por IA',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    const _ComparisonTable(),
                    const SizedBox(height: AppSpacing.xxxl),
                    // Product selector
                    productsAsync.when(
                      data: (products) => _ProductSelector(
                        products: products,
                        selectedId: _selectedProductId ??
                            (products.isNotEmpty ? products.first.id : null),
                        onSelected: (id) =>
                            setState(() => _selectedProductId = id),
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

class _ProductSelector extends StatelessWidget {
  final List<ProductDetails> products;
  final String? selectedId;
  final void Function(String) onSelected;

  const _ProductSelector({
    required this.products,
    required this.selectedId,
    required this.onSelected,
  });

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
                          Text(
                            p.title,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
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
            AppColors.accent.withOpacity(0.12),
            AppColors.accentSubtle,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
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
                      '\$7.99',
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

class _ComparisonTable extends StatelessWidget {
  static const _features = [
    _FeatureRow(label: 'Guardarropa digital', free: true, premium: true),
    _FeatureRow(label: 'Escaneo de prendas', free: true, premium: true),
    _FeatureRow(label: 'Generación de outfits', free: false, premium: true),
    _FeatureRow(label: 'Outfits ilimitados', free: false, premium: true),
    _FeatureRow(label: 'Sugerencias por clima', free: false, premium: true),
    _FeatureRow(
      label: 'Prueba virtual (Try-On)',
      free: false,
      premium: true,
    ),
    _FeatureRow(label: 'Análisis de estilo IA', free: false, premium: true),
  ];

  const _ComparisonTable();

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
                SizedBox(
                  width: 64,
                  child: Text(
                    'Free',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    'Premium',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ..._features.asMap().entries.map((entry) {
            final isLast = entry.key == _features.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.value.label,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        child: Center(
                          child: Icon(
                            entry.value.free
                                ? PhosphorIconsFill.checkCircle
                                : PhosphorIconsRegular.xCircle,
                            size: 20,
                            color: entry.value.free
                                ? AppColors.success
                                : AppColors.border,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        child: Center(
                          child: Icon(
                            entry.value.premium
                                ? PhosphorIconsFill.checkCircle
                                : PhosphorIconsRegular.xCircle,
                            size: 20,
                            color: entry.value.premium
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureRow {
  final String label;
  final bool free;
  final bool premium;

  const _FeatureRow({
    required this.label,
    required this.free,
    required this.premium,
  });
}
