// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  hasStyleProfile: json['hasStyleProfile'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'avatarUrl': instance.avatarUrl,
      'hasStyleProfile': instance.hasStyleProfile,
      'createdAt': instance.createdAt.toIso8601String(),
    };
