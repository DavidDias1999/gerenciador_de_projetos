import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/task_model.dart';
import '../../domain/models/step_model.dart';

final uuid = Uuid();

Future<List<Step>> createDefaultSteps() async {
  final String jsonString = await rootBundle.loadString(
    'assets/project_template.json',
  );

  final List<dynamic> jsonList = json.decode(jsonString);

  final List<Step> steps = jsonList.map((stepJson) {
    final List<dynamic> tasksJson = stepJson['tasks'];

    final List<Task> tasks = tasksJson.map((taskJson) {
      return Task(
        id: uuid.v4(),
        title: taskJson['task_name'],
        isCompleted: false,
      );
    }).toList();

    return Step(id: uuid.v4(), title: stepJson['step_name'], tasks: tasks);
  }).toList();

  return steps;
}
