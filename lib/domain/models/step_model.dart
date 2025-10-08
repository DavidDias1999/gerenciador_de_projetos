import 'sub_step_model.dart';

class Step {
  String id;
  String title;
  List<SubStep> subSteps;
  DateTime? deletedAt;

  Step({
    required this.id,
    required this.title,
    required this.subSteps,
    this.deletedAt,
  });

  double get progress {
    if (subSteps.isEmpty) return 0.0;
    final totalProgress =
        subSteps.fold<double>(0.0, (sum, subStep) => sum + subStep.progress);
    return totalProgress / subSteps.length;
  }
}
