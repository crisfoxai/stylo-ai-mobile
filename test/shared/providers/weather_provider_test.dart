import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/providers/weather_provider.dart';

void main() {
  group('WeatherData', () {
    test('creates from constructor', () {
      const weather = WeatherData(
        temperature: 22.5,
        condition: 'sunny',
        location: 'Buenos Aires',
        iconCode: '01d',
      );
      expect(weather.temperature, 22.5);
      expect(weather.condition, 'sunny');
      expect(weather.location, 'Buenos Aires');
      expect(weather.iconCode, '01d');
    });

    test('fromJson parses correctly', () {
      final json = {
        'temperature': 18.3,
        'condition': 'cloudy',
        'location': 'CABA',
        'iconCode': '04d',
      };
      final weather = WeatherData.fromJson(json);
      expect(weather.temperature, 18.3);
      expect(weather.condition, 'cloudy');
      expect(weather.location, 'CABA');
      expect(weather.iconCode, '04d');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'temperature': 25,
        'condition': null,
        'location': null,
      };
      final weather = WeatherData.fromJson(json);
      expect(weather.temperature, 25.0);
      expect(weather.condition, '');
      expect(weather.location, '');
      expect(weather.iconCode, isNull);
    });

    test('temperatureDisplay rounds and adds degree symbol', () {
      const weather = WeatherData(
        temperature: 22.7,
        condition: 'clear',
        location: 'BA',
      );
      expect(weather.temperatureDisplay, '23°');
    });

    test('equality works via Equatable', () {
      const a = WeatherData(temperature: 20, condition: 'sun', location: 'BA');
      const b = WeatherData(temperature: 20, condition: 'sun', location: 'BA');
      const c = WeatherData(temperature: 21, condition: 'sun', location: 'BA');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('props returns all fields', () {
      const weather = WeatherData(
        temperature: 20,
        condition: 'rain',
        location: 'Montevideo',
        iconCode: '10d',
      );
      expect(weather.props, [20.0, 'rain', 'Montevideo', '10d']);
    });
  });
}
