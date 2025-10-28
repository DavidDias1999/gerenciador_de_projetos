import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/domain/models/sub_step_model.dart'
    as domain;
import '../../../data/repositories/project_repository.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import '../../../domain/models/task_model.dart' as domain;
import '../../../domain/models/project_complexity.dart' as domain;

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _repository;
  StreamSubscription? _projectSubscription;

  ProjectViewModel({required ProjectRepository repository})
      : _repository = repository {
    _listenToProjects();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<domain.Project> _allProjects = [];

  List<domain.Project> get activeProjects =>
      _allProjects.where((p) => !p.isCompleted).toList();

  List<domain.Project> get completedProjects =>
      _allProjects.where((p) => p.isCompleted).toList();

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
  dynamic _expansionController;
  bool _isLoadingDeletedSubSteps = false;
  bool get isLoadingDeletedSubSteps => _isLoadingDeletedSubSteps;
  List<domain.SubStep> _deletedSubSteps = [];
  List<domain.SubStep> get deletedSubSteps => _deletedSubSteps;
  final Set<String> _selectedSubStepsToRestore = {};
  Set<String> get selectedSubStepsToRestore => _selectedSubStepsToRestore;

  void _listenToProjects() {
    _projectSubscription = _repository.getProjectsStream().listen((projects) {
      _allProjects = projects;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e, stackTrace) {
      debugPrint('Erro no stream de projetos: $e');
      _error = 'Erro ao carregar projetos: $e';
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _projectSubscription?.cancel();
    super.dispose();
  }

  void handleExpansionChange({
    required String itemId,
    required bool isExpanded,
    required dynamic controller,
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

    for (var project in _allProjects) {
      dynamic itemToUpdate;
      try {
        itemToUpdate = project.steps.firstWhere((s) => s.id == itemIdToStop);
      } catch (e) {
        for (var step in project.steps) {
          try {
            itemToUpdate =
                step.subSteps.firstWhere((ss) => ss.id == itemIdToStop);
            if (itemToUpdate != null) break;
          } catch (e) {}
        }
      }

      if (itemToUpdate != null) {
        itemToUpdate.durationInSeconds += elapsedSeconds;

        await _repository.updateProject(project);
        break;
      }
    }
  }

  Future<void> stopTimerAndCollapse() async {
    await stopTimer();
    if (_expansionController != null) {
      _expansionController?.collapse();
      _expansionController = null;
    }
    _expandedItemId = null;
  }

  Future<void> createNewProject(
      String projectName, double? squareMeters) async {
    await _repository.createNewProject(projectName, squareMeters);
  }

  Future<void> finalizeProject(
      String projectId, domain.ProjectComplexity complexity) async {
    if (_expansionController != null) {
      _expansionController?.collapse();
    }
    await stopTimer();

    final project = _allProjects.firstWhere((p) => p.id == projectId);
    project.isCompleted = true;
    project.complexity = complexity;
    project.finalizedAt = DateTime.now();
    project.finalProgress = project.progress;
    project.finalTotalDurationInSeconds = project.totalDurationInSeconds;
    notifyListeners();

    await _repository.updateProject(project);
  }

  Future<void> activateProject(String projectId) async {
    await _repository.setProjectStatus(projectId, false);
    final project = _allProjects.firstWhere((p) => p.id == projectId);
    project.isCompleted = false;
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    await _repository.deleteProject(projectId);
    _allProjects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  Future<void> toggleTaskStatus({
    required domain.Project project,
    required String taskId,
    required Function(domain.Project project) onProjectReached100,
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
      await _repository.updateProject(project);
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
    await _repository.updateProject(project);
    final progressAfter = project.progress;
    if (progressBefore < 1.0 && progressAfter == 1.0) {
      onProjectReached100(project);
    }
  }

  Future<void> deselectAllTasksInSubStep(
      String projectId, String subStepId) async {
    final project = _allProjects.firstWhere((p) => p.id == projectId);
    final subStep = project.steps
        .expand((s) => s.subSteps)
        .firstWhere((ss) => ss.id == subStepId);
    for (var task in subStep.tasks) {
      task.isCompleted = false;
      task.completedByUsername = null;
      task.completedAt = null;
    }
    notifyListeners();
    await _repository.updateProject(project);
  }

  Future<void> selectAllTasksInStep({
    required String stepId,
    required domain.Project project,
    required String username,
  }) async {
    final step = project.steps.firstWhere((s) => s.id == stepId);
    for (var task in step.directTasks) {
      task.isCompleted = true;
      task.completedByUsername = username;
      task.completedAt = DateTime.now();
    }
    notifyListeners();
    await _repository.updateProject(project);
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
    await _repository.updateProject(project);
  }

  Future<void> softDeleteStep(String projectId, String stepId) async {
    final project = _allProjects.firstWhere((p) => p.id == projectId);
    final step = project.steps.firstWhere((s) => s.id == stepId);

    step.deletedAt = DateTime.now();
    notifyListeners();
    await _repository.updateProject(project);
  }

  Future<void> fetchDeletedSteps(String projectId) async {
    _isLoadingDeletedSteps = true;
    _deletedSteps = [];
    _selectedStepsToRestore.clear();
    notifyListeners();

    final project = _allProjects.firstWhere((p) => p.id == projectId);
    _deletedSteps = project.steps.where((s) => s.deletedAt != null).toList();

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

    final project = _allProjects.firstWhere(
        (p) => p.steps.any((s) => s.id == _selectedStepsToRestore.first));

    for (var step in project.steps) {
      if (_selectedStepsToRestore.contains(step.id)) {
        step.deletedAt = null;
      }
    }

    await _repository.updateProject(project);

    _selectedStepsToRestore.clear();
    _deletedSteps = [];
    notifyListeners();
  }

  Future<void> softDeleteSubStep(String projectId, String subStepId) async {
    final project = _allProjects.firstWhere((p) => p.id == projectId);
    for (var step in project.steps) {
      for (var subStep in step.subSteps) {
        if (subStep.id == subStepId) {
          subStep.deletedAt = DateTime.now();
          notifyListeners();
          await _repository.updateProject(project);
          return;
        }
      }
    }
  }

  Future<void> fetchDeletedSubSteps(String projectId) async {
    _isLoadingDeletedSubSteps = true;
    _deletedSubSteps = [];
    _selectedSubStepsToRestore.clear();
    notifyListeners();

    final project = _allProjects.firstWhere((p) => p.id == projectId);
    _deletedSubSteps = project.steps
        .expand((s) => s.subSteps)
        .where((ss) => ss.deletedAt != null)
        .toList();

    _isLoadingDeletedSubSteps = false;
    notifyListeners();
  }

  void toggleSubStepSelectionForRestore(String subStepId) {
    if (_selectedSubStepsToRestore.contains(subStepId)) {
      _selectedSubStepsToRestore.remove(subStepId);
    } else {
      _selectedSubStepsToRestore.add(subStepId);
    }
    notifyListeners();
  }

  Future<void> restoreSelectedSubSteps() async {
    if (_selectedSubStepsToRestore.isEmpty) return;

    final project = _allProjects.firstWhere((p) => p.steps
        .expand((s) => s.subSteps)
        .any((ss) => ss.id == _selectedSubStepsToRestore.first));

    for (var step in project.steps) {
      for (var subStep in step.subSteps) {
        if (_selectedSubStepsToRestore.contains(subStep.id)) {
          subStep.deletedAt = null;
        }
      }
    }

    await _repository.updateProject(project);

    _selectedSubStepsToRestore.clear();
    _deletedSubSteps = [];
    notifyListeners();
  }
}
