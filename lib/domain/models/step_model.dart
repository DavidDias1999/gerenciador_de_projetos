import 'task_model.dart';

class Step {
  String id;
  String title;
  List<Task> tasks;

  Step({required this.id, required this.title, required this.tasks});
}
