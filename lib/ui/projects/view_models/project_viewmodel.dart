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

  Future<void> createNewProject(String projectName) async {
    await _repository.createNewProject(projectName);
    await loadProjects();
  }

  Future<void> completeProject(String projectId) async {
    await _repository.setProjectStatus(projectId, true);
    await loadProjects();
  }

  Future<void> activateProject(String projectId) async {
    await _repository.setProjectStatus(projectId, false);
    await loadProjects();
  }

  Future<void> refreshProjectLists() async {
    await loadProjects();
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await _repository.updateTask(taskId, !currentStatus);

    try {
      final project = _activeProjects.firstWhere(
        (p) => p.steps.any((s) => s.tasks.any((t) => t.id == taskId)),
      );
      final task = project.steps
          .expand((s) => s.tasks)
          .firstWhere((t) => t.id == taskId);
      task.isCompleted = !currentStatus;
    } catch (e) {
      final project = _completedProjects.firstWhere(
        (p) => p.steps.any((s) => s.tasks.any((t) => t.id == taskId)),
      );
      final task = project.steps
          .expand((s) => s.tasks)
          .firstWhere((t) => t.id == taskId);
      task.isCompleted = !currentStatus;
    }
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    await _repository.deleteProject(projectId);
    await loadProjects();
  }

  Future<void> selectAllTasksInStep(String projectId, String stepId) async {
    Project project;
    try {
      project = _activeProjects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      project = _completedProjects.firstWhere((p) => p.id == projectId);
    }
    final step = project.steps.firstWhere((s) => s.id == stepId);

    for (var task in step.tasks) {
      task.isCompleted = true;
    }
    notifyListeners();

    await _repository.selectAllTasksInStep(stepId);
  }
}
