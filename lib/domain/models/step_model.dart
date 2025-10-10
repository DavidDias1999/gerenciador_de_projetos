import 'package:gerenciador_de_projetos/domain/models/task_model.dart';

import 'sub_step_model.dart';

class Step {
  String id;
  String title;
  List<Task> directTasks;
  List<SubStep> subSteps;
  DateTime? deletedAt;
  int durationInSeconds;

  Step(
      {required this.id,
      required this.title,
      required this.subSteps,
      required this.directTasks,
      this.deletedAt,
      required this.durationInSeconds});

  double get progress {
    final allTasks = [
      ...directTasks,
      ...subSteps.expand((subStep) => subStep.tasks),
    ];

    if (allTasks.isEmpty) return 0.0;

    final completedTasks = allTasks.where((task) => task.isCompleted).length;
    return completedTasks / allTasks.length;
  }
}
