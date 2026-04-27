import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/outfits_list_provider.dart';
import '../widgets/outfit_grid_card.dart';

const _occasions = [
  'Todos', 'casual', 'work', 'formal', 'date', 'sport', 'party',
];

class OutfitsListScreen extends ConsumerWidget {
  const OutfitsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(outfitsListFilterProvider);
    final outfitsAsync = ref.watch(outfitsListProvider(filter));

    return Scaffold(
      key: const Key('outfits_list_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mis Outfits',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          // Sort toggle
          IconButton(
            icon: Icon(
              filter.sort == 'newest'
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: AppColors.textPrimary,
            ),
            tooltip: filter.sort == 'newest' ? 'Más reciente' : 'Más antiguo',
            onPressed: () {
              ref.read(outfitsListFilterProvider.notifier).state = filter.copyWith(
                sort: filter.sort == 'newest' ? 'oldest' : 'newest',
                page: 1,
              );
            },
          ),
          // Favorites toggle
          IconButton(
            icon: Icon(
              filter.onlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: filter.onlyFavorites ? Colors.red : AppColors.textPrimary,
            ),
            onPressed: () {
              ref.read(outfitsListFilterProvider.notifier).state = filter.copyWith(
                onlyFavorites: !filter.onlyFavorites,
                page: 1,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Occasion filter chips
          _OccasionChips(
            selected: filter.occasion,
            onSelected: (occ) {
              ref.read(outfitsListFilterProvider.notifier).state =
                  filter.copyWith(
                occasion: occ == 'Todos' ? null : occ,
                page: 1,
              );
            },
          ),
          // Grid
          Expanded(
            child: outfitsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppException.extractMessage(e),
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(outfitsListProvider(filter)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (page) {
                if (page.data.isEmpty) {
                  return const _EmptyOutfits();
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: page.data.length,
                  itemBuilder: (_, i) => OutfitGridCard(
                    outfit: page.data[i],
                    onTap: () =>
                        context.push('/outfits/${page.data[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OccasionChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _OccasionChips({this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        itemCount: _occasions.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final occ = _occasions[i];
          final isSelected =
              occ == 'Todos' ? selected == null : selected == occ;
          return ChoiceChip(
            label: Text(occ),
            selected: isSelected,
            onSelected: (_) => onSelected(occ),
            selectedColor: AppColors.accent,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }
}

class _EmptyOutfits extends StatelessWidget {
  const _EmptyOutfits();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 60, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Todavía no tenés outfits',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Generá tu primer outfit desde la pantalla de inicio.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
