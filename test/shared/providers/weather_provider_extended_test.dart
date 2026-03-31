import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/providers/weather_provider.dart';

void main() {
  group('WeatherData', () {
    test('fromJson parses all fields', () {
      final json = {
        'temperature': 22.5,
        'condition': 'Sunny',
        'location': 'Buenos Aires',
        'iconCode': '01d',
      };
      final weather = WeatherData.fromJson(json);
      expect(weather.temperature, 22.5);
      expect(weather.condition, 'Sunny');
      expect(weather.location, 'Buenos Aires');
      expect(weather.iconCode, '01d');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'temperature': 15,
        'condition': null,
        'location': null,
      };
      final weather = WeatherData.fromJson(json);
      expect(weather.temperature, 15.0);
      expect(weather.condition, '');
      expect(weather.location, '');
      expect(weather.iconCode, isNull);
    });

    test('fromJson handles int temperature', () {
      final json = {
        'temperature': 20,
        'condition': 'Cloudy',
        'location': 'Córdoba',
      };
      final weather = WeatherData.fromJson(json);
      expect(weather.temperature, 20.0);
    });

    test('temperatureDisplay rounds to nearest integer', () {
      const weather = WeatherData(
        temperature: 22.7,
        condition: 'Sunny',
        location: 'Test',
      );
      expect(weather.temperatureDisplay, '23°');
    });

    test('temperatureDisplay with negative temperature', () {
      const weather = WeatherData(
        temperature: -5.3,
        condition: 'Snow',
        location: 'Test',
      );
      expect(weather.temperatureDisplay, '-5°');
    });

    test('equatable works correctly', () {
      const a = WeatherData(
        temperature: 20,
        condition: 'Sunny',
        location: 'BA',
        iconCode: '01d',
      );
      const b = WeatherData(
        temperature: 20,
        condition: 'Sunny',
        location: 'BA',
        iconCode: '01d',
      );
      expect(a, b);
    });

    test('different instances are not equal', () {
      const a = WeatherData(
        temperature: 20,
        condition: 'Sunny',
        location: 'BA',
      );
      const b = WeatherData(
        temperature: 25,
        condition: 'Cloudy',
        location: 'BA',
      );
      expect(a, isNot(b));
    });
  });
}
