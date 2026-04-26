import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class StyloBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const StyloBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static final List<_NavItem> _items = [
    _NavItem(label: 'Home', icon: PhosphorIconsRegular.house, activeIcon: PhosphorIconsFill.house, keyName: 'tab_home'),
    _NavItem(label: 'Guardarropa', icon: PhosphorIconsRegular.tShirt, activeIcon: PhosphorIconsFill.tShirt, keyName: 'tab_wardrobe'),
    _NavItem(label: 'Escanear', icon: PhosphorIconsRegular.scan, activeIcon: PhosphorIconsFill.scan, isFab: true, keyName: 'tab_scan'),
    _NavItem(label: 'Outfits', icon: PhosphorIconsRegular.sparkle, activeIcon: PhosphorIconsFill.sparkle, keyName: 'tab_outfits'),
    _NavItem(label: 'Perfil', icon: PhosphorIconsRegular.user, activeIcon: PhosphorIconsFill.user, keyName: 'tab_profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              if (item.isFab) {
                return _buildFabItem(index, item);
              }
              return _buildNavItem(index, item);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItem item) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        key: Key(item.keyName),
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 24,
              color: isSelected ? AppColors.accent : AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabItem(int index, _NavItem item) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        key: Key(item.keyName),
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? AppColors.accent : AppColors.primary).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isFab;
  final String keyName;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.keyName,
    this.isFab = false,
  });
}
