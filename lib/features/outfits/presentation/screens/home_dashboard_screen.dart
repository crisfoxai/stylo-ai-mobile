import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../providers/outfit_generator_provider.dart';
import '../providers/outfit_history_provider.dart';
import '../../domain/entities/outfit.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(outfitHistoryProvider.notifier).refresh();
      ref.read(favoritesProvider.notifier).refresh();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(outfitHistoryProvider.notifier).refresh(),
      ref.read(favoritesProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final historyState = ref.watch(outfitHistoryProvider);
    final favoritesState = ref.watch(favoritesProvider);

    final recentOutfits = historyState.outfits.take(5).toList();
    final recommendedOutfits = favoritesState.outfits.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      user?.firstName ?? 'Stylo',
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.accentSubtle,
                      child: Text(
                        user?.initials ?? 'S',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Outfit of the day card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: _OutfitOfTheDayCard(
                      outfit: recentOutfits.isNotEmpty
                          ? recentOutfits.first
                          : null,
                      onTap: () => context.push('/outfits/generate'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Quick actions
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Text(
                      'Acciones rápidas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _QuickActionsRow(
                    onScan: () => context.push('/scan'),
                    onNewOutfit: () => context.push('/outfits/generate'),
                    onWardrobe: () => context.push('/wardrobe'),
                    onFavorites: () => context.push('/outfits/favorites'),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // AI Stylist Chat card
                  _StylistChatCard(
                    hasChat: ref.watch(hasChatProvider),
                    onTap: () => context.push('/chat'),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Recent wardrobe outfits (horizontal)
                  if (recentOutfits.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Historial reciente',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push('/outfits/history'),
                            child: const Text(
                              'Ver todo',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        scrollDirection: Axis.horizontal,
                        itemCount: recentOutfits.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return _RecentOutfitCard(
                            outfit: recentOutfits[index],
                            onTap: () => context.push(
                                '/outfits/${recentOutfits[index].id}'),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Recommended outfits
                  if (recommendedOutfits.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Outfits favoritos',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push('/outfits/favorites'),
                            child: const Text(
                              'Ver todo',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recommendedOutfits.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return _RecommendedOutfitTile(
                          outfit: recommendedOutfits[index],
                          onTap: () => context.push(
                              '/outfits/${recommendedOutfits[index].id}'),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],

                  // Empty state when nothing to show
                  if (recentOutfits.isEmpty && recommendedOutfits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.checkroom_outlined,
                              size: 64, color: AppColors.textTertiary),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Aún no tenés outfits',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Generá tu primer outfit con IA',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textTertiary),
                          ),
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

// ---------------------------------------------------------------------------
// Outfit of the day card
// ---------------------------------------------------------------------------
class _OutfitOfTheDayCard extends StatelessWidget {
  final Outfit? outfit;
  final VoidCallback onTap;

  const _OutfitOfTheDayCard({required this.outfit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outfit del día',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    outfit?.name ?? 'Generá tu outfit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (outfit?.mood != null || outfit?.event != null)
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        if (outfit?.mood != null)
                          _SmallChip(label: outfit!.mood!),
                        if (outfit?.event != null)
                          _SmallChip(label: outfit!.event!),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        outfit != null ? 'Ver outfit' : 'Crear ahora',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.arrow_forward,
                          color: AppColors.accent, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.checkroom_outlined,
                color: AppColors.accent,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  const _SmallChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions row
// ---------------------------------------------------------------------------
class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onNewOutfit;
  final VoidCallback onWardrobe;
  final VoidCallback onFavorites;

  const _QuickActionsRow({
    required this.onScan,
    required this.onNewOutfit,
    required this.onWardrobe,
    required this.onFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QuickActionItem(
            icon: Icons.camera_alt_outlined,
            label: 'Escanear',
            onTap: onScan,
          ),
          _QuickActionItem(
            icon: Icons.auto_awesome,
            label: 'Nuevo outfit',
            onTap: onNewOutfit,
          ),
          _QuickActionItem(
            icon: Icons.checkroom_outlined,
            label: 'Guardarropa',
            onTap: onWardrobe,
          ),
          _QuickActionItem(
            icon: Icons.favorite_outline,
            label: 'Favoritos',
            onTap: onFavorites,
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.accent, size: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent outfit card (horizontal list)
// ---------------------------------------------------------------------------
class _RecentOutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback onTap;

  const _RecentOutfitCard({required this.outfit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.checkroom_outlined,
                  color: AppColors.accent, size: 28),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm),
              child: Text(
                outfit.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recommended outfit tile
// ---------------------------------------------------------------------------
class _RecommendedOutfitTile extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback onTap;

  const _RecommendedOutfitTile(
      {required this.outfit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.checkroom_outlined,
                  color: AppColors.accent, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (outfit.mood != null || outfit.event != null)
                    Text(
                      [
                        if (outfit.mood != null) outfit.mood!,
                        if (outfit.event != null) outfit.event!,
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (outfit.isFavorite)
              const Icon(Icons.favorite, color: AppColors.accent, size: 18),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StylistChatCard extends StatelessWidget {
  final bool hasChat;
  final VoidCallback onTap;

  const _StylistChatCard({required this.hasChat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Semantics(
        label: 'Mi Estilista',
        button: true,
        excludeSemantics: true,
        child: GestureDetector(
          key: const Key('stylist_chat_card'),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.15),
                  AppColors.accentSubtle,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 32)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mi Estilista',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasChat
                            ? 'Preguntale qué ponerte hoy'
                            : 'Disponible en Stylist, Pro y Pro Unlimited',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  hasChat ? Icons.chevron_right : Icons.lock_outline,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
