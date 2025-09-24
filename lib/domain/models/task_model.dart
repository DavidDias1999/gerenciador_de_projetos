class Task {
  String id;
  String title;
  bool isCompleted;
  int orderIndex;
  Task(
      {required this.id,
      required this.title,
      this.isCompleted = false,
      required this.orderIndex});
}
