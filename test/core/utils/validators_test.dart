import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email validator', () {
      test('returns error when value is null', () {
        expect(Validators.email(null), 'El email es obligatorio');
      });

      test('returns error when value is empty', () {
        expect(Validators.email(''), 'El email es obligatorio');
      });

      test('returns error for invalid email without @', () {
        expect(Validators.email('invalidemail'), 'Ingresá un email válido');
      });

      test('returns error for email without domain', () {
        expect(Validators.email('user@'), 'Ingresá un email válido');
      });

      test('returns error for email with invalid TLD', () {
        expect(Validators.email('user@domain.'), 'Ingresá un email válido');
      });

      test('returns null for valid simple email', () {
        expect(Validators.email('user@example.com'), isNull);
      });

      test('returns null for valid email with subdomain', () {
        expect(Validators.email('user@mail.example.com'), isNull);
      });

      test('returns null for valid email with dots in local part', () {
        expect(Validators.email('first.last@example.com'), isNull);
      });

      test('returns null for valid email with dashes', () {
        expect(Validators.email('user-name@my-domain.com'), isNull);
      });

      test('returns null for valid email with numbers', () {
        expect(Validators.email('user123@example123.org'), isNull);
      });

      test('returns error for email with spaces', () {
        expect(Validators.email('user @example.com'), 'Ingresá un email válido');
      });

      test('returns error for email with double @', () {
        expect(Validators.email('user@@example.com'), 'Ingresá un email válido');
      });
    });

    group('password validator', () {
      test('returns error when value is null', () {
        expect(Validators.password(null), 'La contraseña es obligatoria');
      });

      test('returns error when value is empty', () {
        expect(Validators.password(''), 'La contraseña es obligatoria');
      });

      test('returns error when password is too short (less than 8 chars)', () {
        expect(Validators.password('Abc123'), 'Mínimo 8 caracteres');
      });

      test('returns error when password has exactly 7 chars', () {
        expect(Validators.password('Abcd123'), 'Mínimo 8 caracteres');
      });

      test('returns error when password has no uppercase letter', () {
        expect(Validators.password('password123'), 'Debe incluir una mayúscula');
      });

      test('returns error when password has no number', () {
        expect(Validators.password('Password'), 'Debe incluir un número');
      });

      test('returns null for valid password with uppercase and number', () {
        expect(Validators.password('Password1'), isNull);
      });

      test('returns null for valid complex password', () {
        expect(Validators.password('Str0ngP@ss!'), isNull);
      });

      test('returns null for valid password with exactly 8 chars', () {
        expect(Validators.password('Passw0rd'), isNull);
      });

      test('returns null for valid long password', () {
        expect(Validators.password('MyVeryLongPassword123'), isNull);
      });

      test('returns length error before uppercase error', () {
        // Short password without uppercase - length check comes first
        expect(Validators.password('abc12'), 'Mínimo 8 caracteres');
      });
    });

    group('required validator', () {
      test('returns error when value is null', () {
        expect(Validators.required(null), 'Este campo es obligatorio');
      });

      test('returns error when value is empty', () {
        expect(Validators.required(''), 'Este campo es obligatorio');
      });

      test('returns error when value is only whitespace', () {
        expect(Validators.required('   '), 'Este campo es obligatorio');
      });

      test('returns null when value has content', () {
        expect(Validators.required('some value'), isNull);
      });

      test('uses custom field name in error message', () {
        expect(Validators.required(null, 'El nombre'), 'El nombre es obligatorio');
      });

      test('uses custom field name in error for empty string', () {
        expect(Validators.required('', 'El email'), 'El email es obligatorio');
      });

      test('uses custom field name in error for whitespace', () {
        expect(Validators.required('  ', 'La ciudad'), 'La ciudad es obligatorio');
      });

      test('returns null with custom field name when value has content', () {
        expect(Validators.required('John', 'El nombre'), isNull);
      });
    });

    group('name validator', () {
      test('returns error when value is null', () {
        expect(Validators.name(null), 'El nombre es obligatorio');
      });

      test('returns error when value is empty', () {
        expect(Validators.name(''), 'El nombre es obligatorio');
      });

      test('returns error when value is only whitespace', () {
        expect(Validators.name('   '), 'El nombre es obligatorio');
      });

      test('returns error when name exceeds 50 characters', () {
        final longName = 'A' * 51;
        expect(Validators.name(longName), 'Máximo 50 caracteres');
      });

      test('returns null for name with exactly 50 characters', () {
        final exactName = 'A' * 50;
        expect(Validators.name(exactName), isNull);
      });

      test('returns null for valid short name', () {
        expect(Validators.name('John'), isNull);
      });

      test('returns null for valid name with spaces', () {
        expect(Validators.name('John Doe'), isNull);
      });

      test('returns null for valid name with accents', () {
        expect(Validators.name('José María'), isNull);
      });

      test('returns null for single character name', () {
        expect(Validators.name('A'), isNull);
      });

      test('length error takes priority over empty check for 51+ char names', () {
        final longName = 'B' * 51;
        expect(Validators.name(longName), 'Máximo 50 caracteres');
      });
    });
  });
}
