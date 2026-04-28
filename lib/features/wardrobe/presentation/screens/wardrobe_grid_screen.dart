import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/utils/garment_translations.dart';
import '../../../../shared/widgets/garment_tile.dart';
import '../../../../shared/widgets/stylo_chip.dart';
import '../../domain/entities/garment.dart';
import '../providers/wardrobe_provider.dart';

class WardrobeGridScreen extends ConsumerStatefulWidget {
  const WardrobeGridScreen({super.key});

  @override
  ConsumerState<WardrobeGridScreen> createState() => _WardrobeGridScreenState();
}

class _WardrobeGridScreenState extends ConsumerState<WardrobeGridScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  static const _filters = [
    (label: 'Todas', value: null),
    (label: 'Tops', value: 'top'),
    (label: 'Bottoms', value: 'bottom'),
    (label: 'Zapatos', value: 'shoes'),
    (label: 'Accesorios', value: 'accessory'),
    (label: 'Abrigos', value: 'outerwear'),
  ];

  static const _categoryFilterOptions = [
    'shirt', 'pants', 'jacket', 'sneakers', 'boots', 'dress', 'coat', 'skirt',
  ];

  static const _colorFilterOptions = [
    'grey', 'white', 'black', 'blue', 'red', 'green', 'brown', 'navy',
    'beige', 'pink', 'orange', 'yellow', 'purple',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wardrobeNotifierProvider.notifier).loadGarments();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(wardrobeNotifierProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    ref.read(wardrobeNotifierProvider.notifier).search(query);
  }

  Future<void> _onRefresh() async {
    await ref.read(wardrobeNotifierProvider.notifier).loadGarments(refresh: true);
  }

  void _showFilterSheet() {
    final state = ref.read(wardrobeNotifierProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => _FilterSheet(
        selectedCategory: state.activeFilter,
        selectedColor: state.activeColorFilter,
        onCategoryChanged: (v) =>
            ref.read(wardrobeNotifierProvider.notifier).setFilter(v),
        onColorChanged: (v) =>
            ref.read(wardrobeNotifierProvider.notifier).setColorFilter(v),
        onClear: () {
          ref.read(wardrobeNotifierProvider.notifier).setFilter(null);
          ref.read(wardrobeNotifierProvider.notifier).setColorFilter(null);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wardrobeNotifierProvider);
    final garments = ref.watch(filteredWardrobeProvider);

    return Scaffold(
      key: const Key('wardrobe_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Mi Guardarropa',
          style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: AppColors.textPrimary),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar prendas...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.textTertiary),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(wardrobeNotifierProvider.notifier).search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.lg,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = state.activeFilter == filter.value;
                return StyloChip(
                  label: filter.label,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(wardrobeNotifierProvider.notifier).setFilter(filter.value);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Count indicator
          if (!state.isLoading && garments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    '${state.total} ${state.total == 1 ? 'prenda' : 'prendas'}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          if (!state.isLoading && garments.isNotEmpty)
            const SizedBox(height: AppSpacing.sm),

          // Grid
          Expanded(
            child: _buildContent(state, garments),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        identifier: 'upload_garment_fab',
        child: FloatingActionButton(
          key: const Key('upload_garment_fab'),
          onPressed: () => context.pushNamed('scan'),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.camera_alt_outlined),
        ),
      ),
    );
  }

  Widget _buildContent(WardrobeState state, List<Garment> garments) {
    if (state.isLoading && garments.isEmpty) {
      return _buildLoadingGrid();
    }

    if (state.errorMessage != null && garments.isEmpty) {
      return _buildErrorState(state.errorMessage!);
    }

    if (garments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.accent,
      child: GridView.builder(
        key: const Key('garment_grid'),
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxxxl,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.72,
        ),
        itemCount: garments.length + (state.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= garments.length) {
            return _buildShimmerTile();
          }
          final garment = garments[index];
          return Semantics(
            identifier: 'garment_tile_$index',
            label: garment.name,
            button: true,
            child: GarmentTile(
              key: Key('garment_tile_$index'),
              imageUrl: garment.thumbnailUrl ?? garment.imageUrl,
              category: garment.type,
              garmentCategory: garment.category,
              name: garment.name,
              color: garment.color,
              onTap: () => context.pushNamed(
                'garment-detail',
                pathParameters: {'id': garment.id},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _buildShimmerTile(),
    );
  }

  Widget _buildShimmerTile() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.checkroom_outlined,
                size: 40,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              hasSearch ? 'Sin resultados' : 'Tu guardarropa está vacío',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasSearch
                  ? 'No encontramos prendas que coincidan con tu búsqueda.'
                  : 'Agregá tu primera prenda escaneándola con la cámara.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: AppSpacing.xxxl),
              FilledButton.icon(
                onPressed: () => context.pushNamed('scan'),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Escanear prenda'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Algo salió mal',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxl),
            OutlinedButton(
              onPressed: _onRefresh,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedColor;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onColorChanged;
  final VoidCallback onClear;

  const _FilterSheet({
    this.selectedCategory,
    this.selectedColor,
    required this.onCategoryChanged,
    required this.onColorChanged,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const _categories = [
    'shirt', 'pants', 'jacket', 'sneakers', 'boots', 'dress', 'coat', 'skirt',
  ];

  static const _colors = [
    'grey', 'white', 'black', 'blue', 'red', 'green', 'brown', 'navy',
    'beige', 'pink', 'orange', 'yellow', 'purple',
  ];

  late String? _category;
  late String? _color;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _color = widget.selectedColor;
  }

  void _apply() {
    widget.onCategoryChanged(_category);
    widget.onColorChanged(_color);
    Navigator.pop(context);
  }

  void _clear() {
    widget.onClear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: _clear,
                  child: Text(
                    'Limpiar',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Categoría',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                return StyloChip(
                  label: GarmentTranslations.category(cat),
                  isSelected: isSelected,
                  onTap: () => setState(() => _category = isSelected ? null : cat),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Color',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _colors.map((col) {
                final isSelected = _color == col;
                return StyloChip(
                  label: GarmentTranslations.color(col),
                  isSelected: isSelected,
                  onTap: () => setState(() => _color = isSelected ? null : col),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _apply,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
