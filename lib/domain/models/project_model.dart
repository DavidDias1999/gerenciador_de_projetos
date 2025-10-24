import 'package:json_annotation/json_annotation.dart';
import 'step_model.dart';

part 'project_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Project {
  String id;
  String projectName;
  List<Step> steps;
  bool isCompleted;
  String userId;

  Project({
    required this.id,
    required this.projectName,
    required this.steps,
    required this.isCompleted,
    required this.userId,
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  double get progress {
    // MODIFICADO: Considera apenas etapas ATIVAS (não deletadas)
    final activeSteps = steps.where((step) => step.deletedAt == null);

    // Lista de todas as tarefas ATIVAS dentro das etapas ativas
    // (considerando também as subetapas ativas dentro delas)
    final allActiveTasks = activeSteps
        .expand((step) => [
              ...step.directTasks,
              // Filtra subetapas deletadas DENTRO da etapa ativa
              ...step.subSteps
                  .where((subStep) => subStep.deletedAt == null)
                  .expand((subStep) => subStep.tasks)
            ])
        .toList();

    if (allActiveTasks.isEmpty)
      return 0.0; // Se não houver tarefas ativas, progresso é 0

    // Calcula progresso baseado apenas nas tarefas ativas
    final completedActiveTasks =
        allActiveTasks.where((task) => task.isCompleted).length;
    return completedActiveTasks / allActiveTasks.length;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  int get totalDurationInSeconds {
    // MODIFICADO: Soma duração apenas de etapas e subetapas ATIVAS
    return steps
        .where((step) => step.deletedAt == null) // Filtra etapas deletadas
        .fold<int>(0, (sum, step) {
      final activeSubStepsDuration = step.subSteps
          .where((subStep) =>
              subStep.deletedAt == null) // Filtra subetapas deletadas
          .fold<int>(
              0, (subSum, subStep) => subSum + subStep.durationInSeconds);
      return sum + step.durationInSeconds + activeSubStepsDuration;
    });
  }

  // Métodos de serialização (inalterados)
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
