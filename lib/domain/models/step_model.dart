import 'task_model.dart';

class Step {
  String id;
  String title;
  List<Task> tasks;
  DateTime? deletedAt;

  Step(
      {required this.id,
      required this.title,
      required this.tasks,
      this.deletedAt});

  double get progress {
    if (tasks.isEmpty) {
      return 0.0;
    }
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  bool get areAllTasksCompleted {
    if (tasks.isEmpty) {
      return true;
    }
    return tasks.every((task) => task.isCompleted);
  }
}
