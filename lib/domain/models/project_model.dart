import 'step_model.dart';

class Project {
  String id;
  String projectName;
  List<Step> steps;
  bool isCompleted;

  Project({
    required this.id,
    required this.projectName,
    required this.steps,
    required this.isCompleted,
  });

  double get progress {
    final allTasks = steps
        .expand((step) => [
              ...step.directTasks,
              ...step.subSteps.expand((subStep) => subStep.tasks)
            ])
        .toList();

    if (allTasks.isEmpty) return 0.0;

    final completedTasks = allTasks.where((task) => task.isCompleted).length;
    return completedTasks / allTasks.length;
  }
}
