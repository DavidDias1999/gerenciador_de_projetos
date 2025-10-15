import 'task_model.dart';

class SubStep {
  String id;
  String title;
  int orderIndex;
  List<Task> tasks;
  int durationInSeconds;
  DateTime? deletedAt;

  SubStep({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.tasks,
    required this.durationInSeconds,
    this.deletedAt,
  });

  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }
}
