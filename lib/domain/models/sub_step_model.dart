import 'package:json_annotation/json_annotation.dart';
import 'task_model.dart';

part 'sub_step_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SubStep {
  String id;
  String title;
  int orderIndex;
  List<Task> tasks;
  int durationInSeconds;

  @TimestampConverter()
  DateTime? deletedAt;

  SubStep({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.tasks,
    required this.durationInSeconds,
    this.deletedAt,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  // Métodos de serialização
  factory SubStep.fromJson(Map<String, dynamic> json) =>
      _$SubStepFromJson(json);
  Map<String, dynamic> toJson() => _$SubStepToJson(this);
}
