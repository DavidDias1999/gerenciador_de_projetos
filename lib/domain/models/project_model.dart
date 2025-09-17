import 'step_model.dart';

class Project {
  String id;
  String clientName;
  String projectName;
  List<Step> steps;
  bool isCompleted;

  Project({
    required this.id,
    required this.clientName,
    required this.projectName,
    required this.steps,
    required this.isCompleted,
  });

  double get progress {
    final totalTasks = steps.fold<int>(
      0,
      (sum, step) => sum + step.tasks.length,
    );
    if (totalTasks == 0) {
      return 0.0;
    }

    final completedTasks = steps.fold<int>(
      0,
      (sum, step) => sum + step.tasks.where((task) => task.isCompleted).length,
    );
    return completedTasks / totalTasks;
  }
}
