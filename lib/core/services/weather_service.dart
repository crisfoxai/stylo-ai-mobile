import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class WeatherContext {
  final double temperature;
  final double feelsLike;
  final String condition;
  final bool willRainLater;
  final String city;

  const WeatherContext({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.willRainLater,
    required this.city,
  });

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'feelsLike': feelsLike,
        'condition': condition,
        'willRainLater': willRainLater,
        'city': city,
      };

  static String _mapCondition(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return 'sunny';
      case 'clouds':
        return 'cloudy';
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return 'rainy';
      case 'snow':
        return 'snowy';
      case 'wind':
        return 'windy';
      default:
        return 'cloudy';
    }
  }

  factory WeatherContext.fromOpenWeather(
    Map<String, dynamic> current,
    Map<String, dynamic> forecast,
  ) {
    final main = current['main'] as Map<String, dynamic>;
    final weather = (current['weather'] as List).first as Map<String, dynamic>;
    final cityName = current['name'] as String? ?? '';

    final forecastList = forecast['list'] as List? ?? [];
    final willRain = forecastList.any((item) {
      final w = (item['weather'] as List?)?.first as Map<String, dynamic>?;
      final mainStr = w?['main']?.toString().toLowerCase() ?? '';
      return mainStr == 'rain' || mainStr == 'drizzle' || mainStr == 'thunderstorm';
    });

    return WeatherContext(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      condition: _mapCondition(weather['main'] as String? ?? ''),
      willRainLater: willRain,
      city: cityName,
    );
  }
}

class WeatherService {
  static const _apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherContext?> getCurrentWeather(Position position) async {
    if (_apiKey.isEmpty) return null;
    try {
      final dio = Dio();
      final params = {
        'lat': position.latitude,
        'lon': position.longitude,
        'appid': _apiKey,
        'units': 'metric',
        'lang': 'es',
      };

      final results = await Future.wait([
        dio.get('$_baseUrl/weather', queryParameters: params),
        dio.get('$_baseUrl/forecast', queryParameters: {...params, 'cnt': 4}),
      ]);

      return WeatherContext.fromOpenWeather(
        results[0].data as Map<String, dynamic>,
        results[1].data as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
