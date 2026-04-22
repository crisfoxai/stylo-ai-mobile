import 'package:isar/isar.dart';

part 'garment_cache.g.dart';

@collection
class GarmentCache {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String garmentId;

  late String name;
  late String imageUrl;
  String? thumbnailUrl;
  late String type;
  String? color;
  String? style;
  String? material;
  String? season;
  late List<String> tags;
  late String userId;
  late DateTime createdAt;
  late DateTime updatedAt;

  GarmentCache();

  factory GarmentCache.fromJson(Map<String, dynamic> json) {
    return GarmentCache()
      ..garmentId = json['id'] as String
      ..name = json['name'] as String? ?? ''
      ..imageUrl = json['imageUrl'] as String? ?? ''
      ..thumbnailUrl = json['thumbnailUrl'] as String?
      ..type = json['type'] as String? ?? ''
      ..color = json['color'] as String?
      ..style = json['style'] as String?
      ..material = json['material'] as String?
      ..season = json['season'] as String?
      ..tags = (json['tags'] as List?)?.cast<String>() ?? []
      ..userId = json['userId'] as String? ?? ''
      ..createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now()
      ..updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now();
  }
}
