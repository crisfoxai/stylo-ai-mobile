import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class MultiSelectChipRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selected;
  final void Function(List<String>) onChanged;

  const MultiSelectChipRow({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            return FilterChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (v) {
                final updated = List<String>.from(selected);
                if (v) {
                  updated.add(opt);
                } else {
                  updated.remove(opt);
                }
                onChanged(updated);
              },
              selectedColor: AppColors.accentSubtle,
              checkmarkColor: AppColors.accent,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.border,
              ),
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs, vertical: 0),
            );
          }).toList(),
        ),
      ],
    );
  }
}
