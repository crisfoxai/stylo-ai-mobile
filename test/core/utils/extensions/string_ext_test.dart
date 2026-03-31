import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/utils/extensions/string_ext.dart';

void main() {
  group('StringExt.capitalize', () {
    test('capitalizes first letter', () {
      expect('hello'.capitalize, 'Hello');
    });

    test('returns empty string for empty input', () {
      expect(''.capitalize, '');
    });

    test('preserves already capitalized string', () {
      expect('Hello'.capitalize, 'Hello');
    });

    test('handles single character', () {
      expect('a'.capitalize, 'A');
    });
  });

  group('StringExt.initials', () {
    test('returns two initials from two words', () {
      expect('Juan Pérez'.initials, 'JP');
    });

    test('returns single initial from one word', () {
      expect('Juan'.initials, 'J');
    });

    test('handles extra whitespace', () {
      expect('  Juan   Pérez  '.initials, 'JP');
    });

    test('returns uppercase initials', () {
      expect('ana lópez'.initials, 'AL');
    });

    test('uses first two words for three-word name', () {
      expect('María José López'.initials, 'MJ');
    });
  });
}
