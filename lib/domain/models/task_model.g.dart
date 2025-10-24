// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      orderIndex: (json['orderIndex'] as num).toInt(),
      completedByUsername: json['completedByUsername'] as String?,
      completedAt: const TimestampConverter().fromJson(json['completedAt']),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isCompleted': instance.isCompleted,
      'orderIndex': instance.orderIndex,
      'completedByUsername': instance.completedByUsername,
      'completedAt': const TimestampConverter().toJson(instance.completedAt),
    };
