class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El email es obligatorio';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Ingresá un email válido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe incluir una mayúscula';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Debe incluir un número';
    return null;
  }

  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) return '$fieldName es obligatorio';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'El nombre es obligatorio';
    if (value.length > 50) return 'Máximo 50 caracteres';
    return null;
  }
}
