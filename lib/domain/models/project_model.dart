import 'package:json_annotation/json_annotation.dart';
import 'step_model.dart';
import 'project_complexity.dart';

part 'project_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Project {
  String id;
  String projectName;
  List<Step> steps;
  bool isCompleted;
  String userId;

  double? squareMeters;

  ProjectComplexity? complexity;

  Project({
    required this.id,
    required this.projectName,
    required this.steps,
    required this.isCompleted,
    required this.userId,
    this.squareMeters,
    this.complexity,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get progress {
    final activeSteps = steps.where((step) => step.deletedAt == null);

    final allActiveTasks = activeSteps
        .expand((step) => [
              ...step.directTasks,
              ...step.subSteps
                  .where((subStep) => subStep.deletedAt == null)
                  .expand((subStep) => subStep.tasks)
            ])
        .toList();

    if (allActiveTasks.isEmpty) return 0.0;

    final completedActiveTasks =
        allActiveTasks.where((task) => task.isCompleted).length;
    return completedActiveTasks / allActiveTasks.length;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  int get totalDurationInSeconds {
    return steps.where((step) => step.deletedAt == null).fold<int>(0,
        (sum, step) {
      final activeSubStepsDuration = step.subSteps
          .where((subStep) => subStep.deletedAt == null)
          .fold<int>(
              0, (subSum, subStep) => subSum + subStep.durationInSeconds);
      return sum + step.durationInSeconds + activeSubStepsDuration;
    });
  }

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
