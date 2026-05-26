// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.collaborator,
      isAuthorized: json['isAuthorized'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: _dateTimeFromTimestamp(json['lastSeen']),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'isAuthorized': instance.isAuthorized,
      'isActive': instance.isActive,
      'isOnline': instance.isOnline,
      'lastSeen': _dateTimeToTimestamp(instance.lastSeen),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.collaborator: 'collaborator',
};
