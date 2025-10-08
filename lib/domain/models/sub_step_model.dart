import 'task_model.dart';

class SubStep {
  String id;
  String title;
  int orderIndex;
  List<Task> tasks;

  SubStep({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.tasks,
  });

  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }
}
