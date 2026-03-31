import 'package:equatable/equatable.dart';

class OutfitGarment extends Equatable {
  final String garmentId;
  final String? thumbnailUrl;
  final String type;
  final String color;
  final String style;

  const OutfitGarment({
    required this.garmentId,
    this.thumbnailUrl,
    required this.type,
    required this.color,
    required this.style,
  });

  @override
  List<Object?> get props => [garmentId, thumbnailUrl, type, color, style];
}

class Outfit extends Equatable {
  final String id;
  final String name;
  final List<OutfitGarment> garments;
  final String? mood;
  final String? event;
  final String? weatherContext;
  final double? score;
  final String? rationale;
  final bool isFavorite;
  final DateTime? wornAt;
  final DateTime createdAt;

  const Outfit({
    required this.id,
    required this.name,
    required this.garments,
    this.mood,
    this.event,
    this.weatherContext,
    this.score,
    this.rationale,
    this.isFavorite = false,
    this.wornAt,
    required this.createdAt,
  });

  Outfit copyWith({
    String? id,
    String? name,
    List<OutfitGarment>? garments,
    String? mood,
    String? event,
    String? weatherContext,
    double? score,
    String? rationale,
    bool? isFavorite,
    DateTime? wornAt,
    DateTime? createdAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      garments: garments ?? this.garments,
      mood: mood ?? this.mood,
      event: event ?? this.event,
      weatherContext: weatherContext ?? this.weatherContext,
      score: score ?? this.score,
      rationale: rationale ?? this.rationale,
      isFavorite: isFavorite ?? this.isFavorite,
      wornAt: wornAt ?? this.wornAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        garments,
        mood,
        event,
        weatherContext,
        score,
        rationale,
        isFavorite,
        wornAt,
        createdAt,
      ];
}
