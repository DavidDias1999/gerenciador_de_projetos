import 'package:json_annotation/json_annotation.dart';
import 'package:gerenciador_de_projetos/domain/models/task_model.dart';
import 'sub_step_model.dart';

part 'step_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Step {
  String id;
  String title;
  List<Task> directTasks;
  List<SubStep> subSteps;

  @TimestampConverter()
  DateTime? deletedAt;
  int durationInSeconds;

  Step({
    required this.id,
    required this.title,
    required this.subSteps,
    required this.directTasks,
    this.deletedAt,
    required this.durationInSeconds,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get progress {
    final activeSubSteps =
        subSteps.where((subStep) => subStep.deletedAt == null);

    final allActiveTasks = [
      ...directTasks,
      ...activeSubSteps.expand((subStep) => subStep.tasks),
    ];

    if (allActiveTasks.isEmpty) return 0.0;

    final completedActiveTasks =
        allActiveTasks.where((task) => task.isCompleted).length;
    return completedActiveTasks / allActiveTasks.length;
  }

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);
  Map<String, dynamic> toJson() => _$StepToJson(this);
}
