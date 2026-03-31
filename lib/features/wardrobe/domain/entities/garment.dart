import 'package:equatable/equatable.dart';

class Garment extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String? thumbnailUrl;
  final String type;
  final String? color;
  final String? style;
  final String? material;
  final String? season;
  final List<String> tags;
  final String userId;
  final Map<String, double>? confidences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Garment({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.type,
    this.color,
    this.style,
    this.material,
    this.season,
    this.tags = const [],
    required this.userId,
    this.confidences,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        thumbnailUrl,
        type,
        color,
        style,
        material,
        season,
        tags,
        userId,
        confidences,
        createdAt,
        updatedAt,
      ];
}
