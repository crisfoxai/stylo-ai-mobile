import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/outfit.dart';
import '../providers/outfit_history_provider.dart';

class OutfitHistoryScreen extends ConsumerStatefulWidget {
  const OutfitHistoryScreen({super.key});

  @override
  ConsumerState<OutfitHistoryScreen> createState() =>
      _OutfitHistoryScreenState();
}

class _OutfitHistoryScreenState
    extends ConsumerState<OutfitHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(outfitHistoryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outfitHistoryProvider);
    final notifier = ref.read(outfitHistoryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Historial',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: notifier.refresh,
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OutfitHistoryState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (state.outfits.isEmpty) {
      return _EmptyHistoryState(
        onCreateOutfit: () => context.push('/outfits'),
      );
    }

    final grouped = _groupByDate(state.outfits);
    final dateKeys = grouped.keys.toList();

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      itemCount: dateKeys.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == dateKeys.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child:
                  CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        final dateLabel = dateKeys[index];
        final outfits = grouped[dateLabel]!;

        return _DateGroup(
          dateLabel: dateLabel,
          outfits: outfits,
          onOutfitTap: (id) => context.push('/outfits/$id'),
        );
      },
    );
  }

  Map<String, List<Outfit>> _groupByDate(List<Outfit> outfits) {
    final map = <String, List<Outfit>>{};
    for (final outfit in outfits) {
      final date = outfit.wornAt ?? outfit.createdAt;
      final key = _formatDateKey(date);
      map.putIfAbsent(key, () => []).add(outfit);
    }
    return map;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Hoy';
    if (target == yesterday) return 'Ayer';

    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

class _DateGroup extends StatelessWidget {
  final String dateLabel;
  final List<Outfit> outfits;
  final ValueChanged<String> onOutfitTap;

  const _DateGroup({
    required this.dateLabel,
    required this.outfits,
    required this.onOutfitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              top: AppSpacing.lg, bottom: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Divider(color: AppColors.border),
              ),
            ],
          ),
        ),
        ...outfits.map((outfit) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _OutfitHistoryTile(
                outfit: outfit,
                onTap: () => onOutfitTap(outfit.id),
              ),
            )),
      ],
    );
  }
}

class _OutfitHistoryTile extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback onTap;

  const _OutfitHistoryTile({required this.outfit, required this.onTap});

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
            // Left timeline indicator
            Container(
              width: 4,
              height: 60,
              margin: const EdgeInsets.only(right: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),

            // Outfit icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.checkroom_outlined,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
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
                  const SizedBox(height: AppSpacing.xs),
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${outfit.garments.length} prendas',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Score + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (outfit.isFavorite)
                  const Icon(Icons.favorite,
                      color: AppColors.accent, size: 16),
                const SizedBox(height: AppSpacing.xs),
                const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  final VoidCallback onCreateOutfit;

  const _EmptyHistoryState({required this.onCreateOutfit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.accentSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                color: AppColors.accent,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Sin historial aún',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cuando uses un outfit, aparecerá aquí con la fecha en que lo llevaste puesto',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            ElevatedButton(
              onPressed: onCreateOutfit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl, vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Generar un outfit',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
