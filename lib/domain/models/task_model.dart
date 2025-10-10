class Task {
  String id;
  String title;
  bool isCompleted;
  int orderIndex;
  String? completedByUsername;
  DateTime? completedAt;
  Task(
      {required this.id,
      required this.title,
      this.isCompleted = false,
      required this.orderIndex,
      this.completedByUsername,
      this.completedAt});
}
