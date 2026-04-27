import 'package:flutter/material.dart';

const _moods = [
  ('🔥', 'bold', 'Audaz'),
  ('😎', 'casual', 'Casual'),
  ('💼', 'professional', 'Profesional'),
  ('🌿', 'relaxed', 'Relajado'),
  ('✨', 'special', 'Especial'),
];

const _occasions = [
  ('work', 'Trabajo'),
  ('casual', 'Casual'),
  ('party', 'Salida'),
  ('sport', 'Deporte'),
  ('event', 'Evento'),
  ('home', 'En casa'),
];

class MoodOccasionSelector extends StatelessWidget {
  final String? selectedMood;
  final String? selectedOccasion;
  final ValueChanged<String?> onMoodChanged;
  final ValueChanged<String?> onOccasionChanged;

  const MoodOccasionSelector({
    super.key,
    required this.selectedMood,
    required this.selectedOccasion,
    required this.onMoodChanged,
    required this.onOccasionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Estado de ánimo'),
        const SizedBox(height: 8),
        _ChipRow<(String, String, String)>(
          items: _moods,
          selectedValue: selectedMood,
          keyOf: (m) => m.$2,
          labelOf: (m) => '${m.$1} ${m.$3}',
          onSelected: onMoodChanged,
        ),
        const SizedBox(height: 12),
        _SectionLabel('Ocasión'),
        const SizedBox(height: 8),
        _ChipRow<(String, String)>(
          items: _occasions,
          selectedValue: selectedOccasion,
          keyOf: (o) => o.$1,
          labelOf: (o) => o.$2,
          onSelected: onOccasionChanged,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _ChipRow<T> extends StatelessWidget {
  final List<T> items;
  final String? selectedValue;
  final String Function(T) keyOf;
  final String Function(T) labelOf;
  final ValueChanged<String?> onSelected;

  const _ChipRow({
    required this.items,
    required this.selectedValue,
    required this.keyOf,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final key = keyOf(item);
          final isSelected = selectedValue == key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              key: Key('chip_$key'),
              label: Text(labelOf(item)),
              selected: isSelected,
              onSelected: (_) => onSelected(isSelected ? null : key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
