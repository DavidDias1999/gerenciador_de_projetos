import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gerenciador_de_projetos/domain/models/sub_step_model.dart';
import 'package:gerenciador_de_projetos/domain/models/task_model.dart';
import 'package:gerenciador_de_projetos/domain/models/step_model.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

Future<List<Step>> createDefaultSteps() async {
  final String jsonString =
      await rootBundle.loadString('assets/project_template.json');
  final List<dynamic> jsonList = json.decode(jsonString);

  final List<Step> steps = jsonList.map((stepJson) {
    List<SubStep> subSteps = [];
    List<Task> directTasks = [];

    if (stepJson['sub_steps'] != null) {
      final List<dynamic> subStepsJson = stepJson['sub_steps'];

      for (int i = 0; i < subStepsJson.length; i++) {
        final subStepJson = subStepsJson[i];
        final List<dynamic> tasksJson = subStepJson['tasks'] ?? [];

        final List<Task> tasks = [];
        for (int j = 0; j < tasksJson.length; j++) {
          final taskJson = tasksJson[j];
          tasks.add(Task(
            id: uuid.v4(),
            title: taskJson['task_name'],
            isCompleted: false,
            orderIndex: j,
          ));
        }

        subSteps.add(SubStep(
          id: uuid.v4(),
          title: subStepJson['sub_step_name'],
          orderIndex: i,
          tasks: tasks,
        ));
      }
    } else if (stepJson['tasks'] != null) {
      final List<dynamic> tasksJson = stepJson['tasks'];
      for (int i = 0; i < tasksJson.length; i++) {
        final taskJson = tasksJson[i];
        directTasks.add(Task(
          id: uuid.v4(),
          title: taskJson['task_name'],
          isCompleted: false,
          orderIndex: i,
        ));
      }
    }

    return Step(
      id: uuid.v4(),
      title: stepJson['step_name'],
      subSteps: subSteps,
      directTasks: directTasks,
    );
  }).toList();

  return steps;
}
