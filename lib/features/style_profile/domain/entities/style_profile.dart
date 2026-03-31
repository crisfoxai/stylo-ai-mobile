import 'package:equatable/equatable.dart';

class StyleProfile extends Equatable {
  final String id;
  final List<String> aesthetics;
  final List<String> favoriteColors;
  final List<String> occasions;
  final String adventureLevel;
  final List<String> priorities;
  final String? styleBadge;
  final DateTime createdAt;

  const StyleProfile({
    required this.id,
    required this.aesthetics,
    required this.favoriteColors,
    required this.occasions,
    required this.adventureLevel,
    required this.priorities,
    this.styleBadge,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, aesthetics, favoriteColors, occasions, adventureLevel, priorities, styleBadge];
}
