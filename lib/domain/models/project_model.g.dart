// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String,
      projectName: json['projectName'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => Step.fromJson(e as Map<String, dynamic>))
          .toList(),
      isCompleted: json['isCompleted'] as bool,
      userId: json['userId'] as String,
      squareMeters: (json['squareMeters'] as num?)?.toDouble(),
      complexity:
          $enumDecodeNullable(_$ProjectComplexityEnumMap, json['complexity']),
      finalizedAt: const TimestampConverter().fromJson(json['finalizedAt']),
      finalProgress: (json['finalProgress'] as num?)?.toDouble(),
      finalTotalDurationInSeconds:
          (json['finalTotalDurationInSeconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'projectName': instance.projectName,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
      'isCompleted': instance.isCompleted,
      'userId': instance.userId,
      'squareMeters': instance.squareMeters,
      'complexity': _$ProjectComplexityEnumMap[instance.complexity],
      'finalizedAt': const TimestampConverter().toJson(instance.finalizedAt),
      'finalProgress': instance.finalProgress,
      'finalTotalDurationInSeconds': instance.finalTotalDurationInSeconds,
    };

const _$ProjectComplexityEnumMap = {
  ProjectComplexity.baixa: 'baixa',
  ProjectComplexity.media: 'media',
  ProjectComplexity.alta: 'alta',
};
