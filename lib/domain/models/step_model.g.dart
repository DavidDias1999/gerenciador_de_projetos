// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Step _$StepFromJson(Map<String, dynamic> json) => Step(
      id: json['id'] as String,
      title: json['title'] as String,
      subSteps: (json['subSteps'] as List<dynamic>)
          .map((e) => SubStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      directTasks: (json['directTasks'] as List<dynamic>)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      deletedAt: const TimestampConverter().fromJson(json['deletedAt']),
      durationInSeconds: (json['durationInSeconds'] as num).toInt(),
    );

Map<String, dynamic> _$StepToJson(Step instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'directTasks': instance.directTasks.map((e) => e.toJson()).toList(),
      'subSteps': instance.subSteps.map((e) => e.toJson()).toList(),
      'deletedAt': const TimestampConverter().toJson(instance.deletedAt),
      'durationInSeconds': instance.durationInSeconds,
    };
