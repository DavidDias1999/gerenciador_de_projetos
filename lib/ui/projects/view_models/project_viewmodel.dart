import 'package:flutter/foundation.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../domain/models/project_model.dart';
import '../../../domain/models/step_model.dart';
import '../../../domain/models/sub_step_model.dart';
import '../../../domain/models/task_model.dart';

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

  bool _isLoadingDeletedSteps = false;
  bool get isLoadingDeletedSteps => _isLoadingDeletedSteps;

  List<Step> _deletedSteps = [];
  List<Step> get deletedSteps => _deletedSteps;

  final Set<String> _selectedStepsToRestore = {};
  Set<String> get selectedStepsToRestore => _selectedStepsToRestore;

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

  Future<void> softDeleteStep(String projectId, String stepId) async {
    await _repository.softDeleteStep(stepId);
    Project project;
    try {
      project = _activeProjects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      project = _completedProjects.firstWhere((p) => p.id == projectId);
    }
    project.steps.removeWhere((step) => step.id == stepId);
    notifyListeners();
  }

  void _sortTasks(SubStep subStep) {
    subStep.tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.orderIndex.compareTo(b.orderIndex);
    });
  }

  Future<void> toggleTaskStatus({
    required Project project,
    required String taskId,
    required Function(Project project) onProjectReached100,
    required int currentUserId,
    required String currentUsername,
  }) async {
    final progressBefore = project.progress;

    SubStep? targetSubStep;
    Task? targetTask;

    for (var step in project.steps) {
      for (var subStep in step.subSteps) {
        try {
          targetTask = subStep.tasks.firstWhere((t) => t.id == taskId);
          targetSubStep = subStep;
          break;
        } catch (e) {
          continue;
        }
      }
      if (targetTask != null) break;
    }

    if (targetTask != null && targetSubStep != null) {
      targetTask.isCompleted = !targetTask.isCompleted;
      if (targetTask.isCompleted) {
        targetTask.completedByUsername = currentUsername;
        targetTask.completedAt = DateTime.now();
      } else {
        targetTask.completedByUsername = null;
        targetTask.completedAt = null;
      }
      _sortTasks(targetSubStep);
      notifyListeners();

      await _repository.updateTask(
          taskId, targetTask.isCompleted, currentUserId);
    }

    final progressAfter = project.progress;
    if (progressBefore < 1.0 && progressAfter == 1.0) {
      onProjectReached100(project);
    }
  }

  Future<void> selectAllTasksInSubStep({
    required Project project,
    required String subStepId,
    required Function(Project project) onProjectReached100,
  }) async {
    final progressBefore = project.progress;

    final subStep = project.steps
        .expand((s) => s.subSteps)
        .firstWhere((ss) => ss.id == subStepId);

    for (var task in subStep.tasks) {
      task.isCompleted = true;
    }
    _sortTasks(subStep);
    notifyListeners();

    await _repository.selectAllTasksInSubStep(subStepId);

    final progressAfter = project.progress;
    if (progressBefore < 1.0 && progressAfter == 1.0) {
      onProjectReached100(project);
    }
  }

  Future<void> deselectAllTasksInSubStep(
      String projectId, String subStepId) async {
    Project project;
    try {
      project = _activeProjects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      project = _completedProjects.firstWhere((p) => p.id == projectId);
    }
    final wasProjectCompleted = project.isCompleted;
    final subStep = project.steps
        .expand((s) => s.subSteps)
        .firstWhere((ss) => ss.id == subStepId);

    for (var task in subStep.tasks) {
      task.isCompleted = false;
    }
    _sortTasks(subStep);
    notifyListeners();

    await _repository.deselectAllTasksInSubStep(subStepId);

    final isProjectNowCompleted = project.isCompleted;
    if (wasProjectCompleted && !isProjectNowCompleted) {
      await loadProjects();
    }
  }

  Future<void> fetchDeletedSteps(String projectId) async {
    _isLoadingDeletedSteps = true;
    _deletedSteps = [];
    _selectedStepsToRestore.clear();
    notifyListeners();

    _deletedSteps = await _repository.getDeletedStepsForProject(projectId);
    _isLoadingDeletedSteps = false;
    notifyListeners();
  }

  void toggleStepSelectionForRestore(String stepId) {
    if (_selectedStepsToRestore.contains(stepId)) {
      _selectedStepsToRestore.remove(stepId);
    } else {
      _selectedStepsToRestore.add(stepId);
    }
    notifyListeners();
  }

  Future<void> restoreSelectedSteps() async {
    if (_selectedStepsToRestore.isEmpty) return;
    await _repository.restoreSteps(_selectedStepsToRestore.toList());
    _selectedStepsToRestore.clear();
    _deletedSteps = [];
    await loadProjects();
  }
}
