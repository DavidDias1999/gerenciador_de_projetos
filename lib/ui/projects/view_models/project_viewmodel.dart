import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/data/repositories/project_repository.dart';

import '../../../domain/models/project_model.dart';

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _repository;

  ProjectViewModel({required ProjectRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Project> _activeProjects = [];
  List<Project> get activeProjects => _activeProjects;

  List<Project> _completedProjects = [];
  List<Project> get completedProjects => _completedProjects;

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    final allProjects = await _repository.getProjects();

    _activeProjects = allProjects.where((p) => !p.isCompleted).toList();
    _completedProjects = allProjects.where((p) => p.isCompleted).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewProject(String clienteName, String projectName) async {
    await _repository.createNewProject(clienteName, projectName);
    await loadProjects();
  }

  Future<void> toggleTaskStatus(
    Project project,
    String stepId,
    String taskId,
  ) async {
    final step = project.steps.firstWhere((s) => s.id == stepId);
    final task = step.tasks.firstWhere((t) => t.id == taskId);

    final wasProjectCompleted = project.isCompleted;

    task.isCompleted = !task.isCompleted;

    final isProjectNowCompleted = project.isCompleted;

    await _repository.updateTask(taskId, task.isCompleted);

    if (wasProjectCompleted != isProjectNowCompleted) {
      await loadProjects();
    } else {
      notifyListeners();
    }
  }
}
