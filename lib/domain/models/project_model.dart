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
}
