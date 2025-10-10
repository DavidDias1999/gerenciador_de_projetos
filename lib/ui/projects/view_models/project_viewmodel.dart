import 'package:flutter/material.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import '../../../domain/models/task_model.dart' as domain;

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _repository;

  ProjectViewModel({required ProjectRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<domain.Project> _activeProjects = [];
  List<domain.Project> get activeProjects => _activeProjects;

  List<domain.Project> _completedProjects = [];
  List<domain.Project> get completedProjects => _completedProjects;

  bool _isLoadingDeletedSteps = false;
  bool get isLoadingDeletedSteps => _isLoadingDeletedSteps;

  List<domain.Step> _deletedSteps = [];
  List<domain.Step> get deletedSteps => _deletedSteps;

  final Set<String> _selectedStepsToRestore = {};
  Set<String> get selectedStepsToRestore => _selectedStepsToRestore;

  String? _activeTimerId;
  String? get activeTimerId => _activeTimerId;
  DateTime? _timerStartTime;

  String? _expandedItemId;
  ExpansibleController? _expansionController;

  void handleExpansionChange({
    required String itemId,
    required bool isExpanded,
    required ExpansibleController controller,
  }) {
    if (_expandedItemId != null && _expandedItemId != itemId) {
      _expansionController?.collapse();
      stopTimer();
    }

    if (isExpanded) {
      _expandedItemId = itemId;
      _expansionController = controller;
      startTimer(itemId);
    } else {
      _expandedItemId = null;
      _expansionController = null;
      stopTimer();
    }
  }

  void startTimer(String itemId) {
    if (_activeTimerId != null) {
      stopTimer();
    }
    _activeTimerId = itemId;
    _timerStartTime = DateTime.now();
    notifyListeners();
  }

  Future<void> stopTimer() async {
    if (_activeTimerId == null || _timerStartTime == null) return;

    final String itemIdToStop = _activeTimerId!;
    final elapsedSeconds =
        DateTime.now().difference(_timerStartTime!).inSeconds;

    _activeTimerId = null;
    _timerStartTime = null;
    notifyListeners();

    if (elapsedSeconds == 0) return;

    for (var project in _activeProjects) {
      dynamic itemToUpdate;
      bool isSubStep = false;
      try {
        itemToUpdate = project.steps.firstWhere((s) => s.id == itemIdToStop);
      } catch (e) {
        try {
          itemToUpdate = project.steps
              .expand((s) => s.subSteps)
              .firstWhere((ss) => ss.id == itemIdToStop);
          isSubStep = true;
        } catch (e) {}
      }

      if (itemToUpdate != null) {
        itemToUpdate.durationInSeconds += elapsedSeconds;

        if (isSubStep) {
          await _repository.updateSubStepDuration(
              itemIdToStop, itemToUpdate.durationInSeconds);
        } else {
          await _repository.updateStepDuration(
              itemIdToStop, itemToUpdate.durationInSeconds);
        }
        break;
      }
    }
  }

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
    if (_expansionController != null) {
      _expansionController?.collapse();
    }
    await stopTimer();

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
    domain.Project project;
    try {
      project = _activeProjects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      project = _completedProjects.firstWhere((p) => p.id == projectId);
    }
    project.steps.removeWhere((step) => step.id == stepId);
    notifyListeners();
  }

  Future<void> toggleTaskStatus({
    required domain.Project project,
    required String taskId,
    required Function(domain.Project project) onProjectReached100,
    required int currentUserId,
    required String currentUsername,
  }) async {
    final progressBefore = project.progress;
    domain.Task? targetTask;
    List<domain.Task>? parentTaskList;
    for (final step in project.steps) {
      try {
        targetTask = step.directTasks.firstWhere((t) => t.id == taskId);
        parentTaskList = step.directTasks;
        break;
      } catch (e) {
        for (final subStep in step.subSteps) {
          try {
            targetTask = subStep.tasks.firstWhere((t) => t.id == taskId);
            parentTaskList = subStep.tasks;
            break;
          } catch (e) {
            continue;
          }
        }
      }
      if (targetTask != null) break;
    }
    if (targetTask != null && parentTaskList != null) {
      targetTask.isCompleted = !targetTask.isCompleted;
      if (targetTask.isCompleted) {
        targetTask.completedByUsername = currentUsername;
        targetTask.completedAt = DateTime.now();
      } else {
        targetTask.completedByUsername = null;
        targetTask.completedAt = null;
      }
      parentTaskList.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return a.orderIndex.compareTo(b.orderIndex);
      });
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
    required domain.Project project,
    required String subStepId,
    required Function(domain.Project project) onProjectReached100,
    required int userId,
    required String username,
  }) async {
    final progressBefore = project.progress;
    final subStep = project.steps
        .expand((s) => s.subSteps)
        .firstWhere((ss) => ss.id == subStepId);
    for (var task in subStep.tasks) {
      task.isCompleted = true;
      task.completedByUsername = username;
      task.completedAt = DateTime.now();
    }
    notifyListeners();
    await _repository.selectAllTasksInSubStep(subStepId, userId);
    final progressAfter = project.progress;
    if (progressBefore < 1.0 && progressAfter == 1.0) {
      onProjectReached100(project);
    }
  }

  Future<void> deselectAllTasksInSubStep(
      String projectId, String subStepId) async {
    domain.Project project;
    try {
      project = _activeProjects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      project = _completedProjects.firstWhere((p) => p.id == projectId);
    }
    final subStep = project.steps
        .expand((s) => s.subSteps)
        .firstWhere((ss) => ss.id == subStepId);
    for (var task in subStep.tasks) {
      task.isCompleted = false;
      task.completedByUsername = null;
      task.completedAt = null;
    }
    notifyListeners();
    await _repository.deselectAllTasksInSubStep(subStepId);
  }

  Future<void> selectAllTasksInStep({
    required String stepId,
    required domain.Project project,
    required int userId,
    required String username,
  }) async {
    final step = project.steps.firstWhere((s) => s.id == stepId);
    for (var task in step.directTasks) {
      task.isCompleted = true;
      task.completedByUsername = username;
      task.completedAt = DateTime.now();
    }
    notifyListeners();
    await _repository.selectAllTasksInStep(stepId, userId);
  }

  Future<void> deselectAllTasksInStep(
      String stepId, domain.Project project) async {
    final step = project.steps.firstWhere((s) => s.id == stepId);
    for (var task in step.directTasks) {
      task.isCompleted = false;
      task.completedByUsername = null;
      task.completedAt = null;
    }
    notifyListeners();
    await _repository.deselectAllTasksInStep(stepId);
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
