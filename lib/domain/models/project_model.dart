import 'step_model.dart';

class Project {
  String id;
  String clientName;
  String projectName;
  List<Step> steps;
  Project({
    required this.id,
    required this.clientName,
    required this.projectName,
    required this.steps,
  });

  bool get isCompleted {
    if (steps.isEmpty) return false;
    return steps.every((step) => step.tasks.every((task) => task.isCompleted));
  }
}
