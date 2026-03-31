import 'package:equatable/equatable.dart';

class GarmentTag extends Equatable {
  final String category;
  final String value;
  final double confidence;

  const GarmentTag({
    required this.category,
    required this.value,
    required this.confidence,
  });

  @override
  List<Object?> get props => [category, value, confidence];
}
