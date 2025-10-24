// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubStep _$SubStepFromJson(Map<String, dynamic> json) => SubStep(
      id: json['id'] as String,
      title: json['title'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      durationInSeconds: (json['durationInSeconds'] as num).toInt(),
      deletedAt: const TimestampConverter().fromJson(json['deletedAt']),
    );

Map<String, dynamic> _$SubStepToJson(SubStep instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'orderIndex': instance.orderIndex,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
      'durationInSeconds': instance.durationInSeconds,
      'deletedAt': const TimestampConverter().toJson(instance.deletedAt),
    };
