import 'package:flutter/foundation.dart';
import '../../../domain/models/project_model.dart';
import '../../../data/repositories/project_repository.dart';

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

  Future<void> deleteProject(String projectId) async {
    await _repository.deleteProject(projectId);
    await loadProjects();
  }

  Future<void> refreshProjectLists() async {
    await loadProjects();
  }

  Future<void> deleteStep(String projectId, String stepId) async {
    await _repository.deleteStep(stepId);
    Project project;
    try {
      project = _activeProjects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      project = _completedProjects.firstWhere((p) => p.id == projectId);
    }
    project.steps.removeWhere((step) => step.id == stepId);
    notifyListeners();
  }

  Future<void> toggleTaskStatus({
    required Project project,
    required String stepId,
    required String taskId,
    required Function(Project completedProject) onProjectCompleted,
  }) async {
    final step = project.steps.firstWhere((s) => s.id == stepId);
    final task = step.tasks.firstWhere((t) => t.id == taskId);
    final wasProjectCompleted = project.isCompleted;

    task.isCompleted = !task.isCompleted;
    notifyListeners();

    await _repository.updateTask(taskId, task.isCompleted);

    final isProjectNowCompleted = project.isCompleted;

    if (wasProjectCompleted != isProjectNowCompleted) {
      if (isProjectNowCompleted) {
        onProjectCompleted(project);
      } else {
        await loadProjects();
      }
    }
  }

  Future<void> selectAllTasksInStep({
    required Project project,
    required String stepId,
    required Function(Project completedProject) onProjectCompleted,
  }) async {
    final wasProjectCompleted = project.isCompleted;

    final step = project.steps.firstWhere((s) => s.id == stepId);
    for (var task in step.tasks) {
      task.isCompleted = true;
    }
    notifyListeners();

    await _repository.selectAllTasksInStep(stepId);

    final isProjectNowCompleted = project.isCompleted;
    if (!wasProjectCompleted && isProjectNowCompleted) {
      onProjectCompleted(project);
    }
  }

  Future<void> deselectAllTasksInStep(String projectId, String stepId) async {
    Project project;
    try {
      project = _activeProjects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      project = _completedProjects.firstWhere((p) => p.id == projectId);
    }

    final wasProjectCompleted = project.isCompleted;

    final step = project.steps.firstWhere((s) => s.id == stepId);
    for (var task in step.tasks) {
      task.isCompleted = false;
    }
    notifyListeners();

    await _repository.deselectAllTasksInStep(stepId);

    final isProjectNowCompleted = project.isCompleted;
    if (wasProjectCompleted && !isProjectNowCompleted) {
      await loadProjects();
    }
  }
}
