import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class WeatherData extends Equatable {
  final double temperature;
  final String condition;
  final String location;
  final String? iconCode;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.location,
    this.iconCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String? ?? '',
      location: json['location'] as String? ?? '',
      iconCode: json['iconCode'] as String?,
    );
  }

  String get temperatureDisplay => '${temperature.round()}°';

  @override
  List<Object?> get props => [temperature, condition, location, iconCode];
}

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get(Endpoints.weather);
  return WeatherData.fromJson(response.data['data'] as Map<String, dynamic>);
});
