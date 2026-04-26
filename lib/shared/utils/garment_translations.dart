abstract class GarmentTranslations {
  static const Map<String, String> _type = {
    'top': 'Remera/Top',
    'bottom': 'Pantalón',
    'shoes': 'Calzado',
    'outerwear': 'Abrigo',
    'accessory': 'Accesorio',
    'dress': 'Vestido',
  };

  static const Map<String, String> _category = {
    'shirt': 'Remera',
    'pants': 'Pantalón',
    'jacket': 'Campera',
    'sneakers': 'Zapatillas',
    'boots': 'Botas',
    'dress': 'Vestido',
    'coat': 'Abrigo',
    'skirt': 'Falda',
    'bag': 'Cartera',
    'top': 'Top',
    'jeans': 'Jeans',
    'shorts': 'Shorts',
  };

  static const Map<String, String> _color = {
    'grey': 'gris',
    'gray': 'gris',
    'white': 'blanco',
    'black': 'negro',
    'blue': 'azul',
    'red': 'rojo',
    'green': 'verde',
    'brown': 'marrón',
    'navy': 'azul marino',
    'beige': 'beige',
    'pink': 'rosa',
    'orange': 'naranja',
    'yellow': 'amarillo',
    'purple': 'violeta',
    'tan': 'beige',
  };

  static String type(String raw) => _type[raw.toLowerCase()] ?? _capitalize(raw);

  static String category(String raw) =>
      _category[raw.toLowerCase()] ?? _capitalize(raw);

  static String color(String raw) => _color[raw.toLowerCase()] ?? raw.toLowerCase();

  /// "grey" + "shirt" → "Remera gris"
  static String computedName(String? colorRaw, String? categoryRaw) {
    final colorEs = colorRaw != null && colorRaw.isNotEmpty ? color(colorRaw) : '';
    final categoryEs =
        categoryRaw != null && categoryRaw.isNotEmpty ? category(categoryRaw) : '';
    if (categoryEs.isEmpty && colorEs.isEmpty) return '';
    if (categoryEs.isEmpty) return colorEs;
    if (colorEs.isEmpty) return categoryEs;
    return '$categoryEs $colorEs';
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
