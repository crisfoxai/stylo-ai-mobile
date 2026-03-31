import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/outfit.dart';
import '../providers/outfit_generator_provider.dart';

class OutfitGeneratorScreen extends ConsumerWidget {
  const OutfitGeneratorScreen({super.key});

  static const List<String> _moods = [
    'Casual',
    'Formal',
    'Atrevido',
    'Relajado',
    'Energético',
  ];

  static const List<String> _events = [
    'Trabajo',
    'Cita',
    'Brunch',
    'Gym',
    'Fiesta',
    'Día libre',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(outfitGeneratorProvider);
    final notifier = ref.read(outfitGeneratorProvider.notifier);

    ref.listen<OutfitGeneratorState>(outfitGeneratorProvider, (_, next) {
      if (next.step == OutfitGeneratorStep.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Generador de Outfits',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        leading: state.step == OutfitGeneratorStep.result
            ? IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textPrimary),
                onPressed: () => notifier.regenerateOutfit(),
              )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: state.step == OutfitGeneratorStep.generating
            ? const _GeneratingView(key: ValueKey('generating'))
            : state.step == OutfitGeneratorStep.result &&
                    state.generatedOutfit != null
                ? _ResultView(
                    key: const ValueKey('result'),
                    outfit: state.generatedOutfit!,
                    isFavoriting: state.isFavoriting,
                    isLoggingWorn: state.isLoggingWorn,
                    onRegenerate: () => notifier.regenerateOutfit(),
                    onFavorite: () => notifier.favoriteOutfit(),
                    onLogWorn: () => notifier.logAsWorn(),
                    onSwapGarment: (id) => notifier.swapGarment(id),
                    onViewDetail: () => context
                        .push('/outfits/${state.generatedOutfit!.id}'),
                  )
                : _SelectorView(
                    key: const ValueKey('selector'),
                    moods: _moods,
                    events: _events,
                    selectedMood: state.selectedMood,
                    selectedEvent: state.selectedEvent,
                    canGenerate: state.canGenerate,
                    onMoodSelected: notifier.setMood,
                    onEventSelected: notifier.setEvent,
                    onGenerate: () => notifier.generateOutfit(),
                  ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selector view
// ---------------------------------------------------------------------------
class _SelectorView extends StatelessWidget {
  final List<String> moods;
  final List<String> events;
  final String? selectedMood;
  final String? selectedEvent;
  final bool canGenerate;
  final ValueChanged<String> onMoodSelected;
  final ValueChanged<String> onEventSelected;
  final VoidCallback onGenerate;

  const _SelectorView({
    super.key,
    required this.moods,
    required this.events,
    required this.selectedMood,
    required this.selectedEvent,
    required this.canGenerate,
    required this.onMoodSelected,
    required this.onEventSelected,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo te sentís hoy?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Seleccioná tu estado de ánimo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: moods.map((mood) {
              final selected = mood == selectedMood;
              return _SelectableChip(
                label: mood,
                selected: selected,
                onTap: () => onMoodSelected(mood),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          Text(
            '¿Para qué ocasión?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Seleccioná el evento',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: events.map((event) {
              final selected = event == selectedEvent;
              return _SelectableChip(
                label: event,
                selected: selected,
                onTap: () => onEventSelected(event),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xxxxl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canGenerate ? onGenerate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                disabledBackgroundColor: AppColors.border,
                foregroundColor: AppColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppRadius.full),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Generar outfit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.textOnPrimary
                : AppColors.textPrimary,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generating view
// ---------------------------------------------------------------------------
class _GeneratingView extends StatelessWidget {
  const _GeneratingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Creando tu outfit perfecto...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'La IA está eligiendo las mejores prendas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result view
// ---------------------------------------------------------------------------
class _ResultView extends StatelessWidget {
  final Outfit outfit;
  final bool isFavoriting;
  final bool isLoggingWorn;
  final VoidCallback onRegenerate;
  final VoidCallback onFavorite;
  final VoidCallback onLogWorn;
  final ValueChanged<String> onSwapGarment;
  final VoidCallback onViewDetail;

  const _ResultView({
    super.key,
    required this.outfit,
    required this.isFavoriting,
    required this.isLoggingWorn,
    required this.onRegenerate,
    required this.onFavorite,
    required this.onLogWorn,
    required this.onSwapGarment,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (outfit.mood != null || outfit.event != null)
                      const SizedBox(height: AppSpacing.xs),
                    if (outfit.mood != null || outfit.event != null)
                      Text(
                        [
                          if (outfit.mood != null) outfit.mood!,
                          if (outfit.event != null) outfit.event!,
                        ].join(' · '),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              if (outfit.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.accentSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.accent, size: 14),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        outfit.score!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Rationale
          if (outfit.rationale != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      outfit.rationale!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          Text(
            'Prendas del outfit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Garments list
          ...outfit.garments.map((garment) {
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.md),
              child: _GarmentRow(
                garment: garment,
                onSwap: () => onSwapGarment(garment.garmentId),
              ),
            );
          }),

          const SizedBox(height: AppSpacing.xxl),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRegenerate,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh,
                          size: 16, color: AppColors.textPrimary),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Regenerar',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                onPressed: isFavoriting ? null : onFavorite,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  side:
                      const BorderSide(color: AppColors.border),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                ),
                icon: isFavoriting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent),
                      )
                    : Icon(
                        outfit.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: outfit.isFavorite
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        size: 22,
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoggingWorn ? null : onLogWorn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                elevation: 0,
              ),
              child: isLoggingWorn
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary),
                    )
                  : const Text(
                      'Usar hoy',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onViewDetail,
              child: const Text(
                'Ver detalle completo',
                style: TextStyle(color: AppColors.accent, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _GarmentRow extends StatelessWidget {
  final OutfitGarment garment;
  final VoidCallback onSwap;

  const _GarmentRow({required this.garment, required this.onSwap});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: garment.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.network(
                      garment.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.checkroom_outlined,
                          color: AppColors.accent),
                    ),
                  )
                : const Icon(Icons.checkroom_outlined,
                    color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  garment.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${garment.color} · ${garment.style}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSwap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm),
            ),
            child: const Text('Cambiar', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
