import 'dart:async'; // **[ADICIONADO]**
import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/domain/models/sub_step_model.dart'
    as domain;
import '../../../data/repositories/project_repository.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import '../../../domain/models/task_model.dart' as domain;

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _repository;
  StreamSubscription? _projectSubscription; // **[ADICIONADO]**

  ProjectViewModel({required ProjectRepository repository})
      : _repository = repository {
    // **[ADICIONADO]** Inicia a escuta assim que o ViewModel é criado
    _listenToProjects();
  }

  bool _isLoading = true; // **[MODIFICADO]** Começa como true
  bool get isLoading => _isLoading;

  String? _error; // **[ADICIONADO]**
  String? get error => _error;

  List<domain.Project> _allProjects = []; // Lista única para gerenciar

  List<domain.Project> get activeProjects =>
      _allProjects.where((p) => !p.isCompleted).toList();

  List<domain.Project> get completedProjects =>
      _allProjects.where((p) => p.isCompleted).toList();

  // ... (O restante das suas variáveis de estado permanecem iguais)
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

  // **[ADICIONADO]** Método para iniciar a escuta do Stream
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

  // **[ADICIONADO]** Cancela a inscrição ao fechar o ViewModel
  @override
  void dispose() {
    _projectSubscription?.cancel();
    super.dispose();
  }

  // --- Lógica de Timer (Modificada para chamar updateProject) ---
  // ... (NENHUMA MUDANÇA AQUI, seu código de timer já está correto)
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

    // Encontra o projeto e o item (Step ou SubStep)
    for (var project in _allProjects) {
      dynamic itemToUpdate;
      try {
        // Tenta encontrar como Step
        itemToUpdate = project.steps.firstWhere((s) => s.id == itemIdToStop);
      } catch (e) {
        // Tenta encontrar como SubStep
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
        // Salva o projeto inteiro
        await _repository.updateProject(project);
        break; // Para o loop assim que o item for encontrado e salvo
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

  // --- Lógica de CRUD (Modificada) ---

  // **[REMOVIDO]** O método loadProjects() não é mais necessário.
  /*
   Future<void> loadProjects() async {
     _isLoading = true;
     notifyListeners();
     _allProjects = await _repository.getProjects();
     _isLoading = false;
     notifyListeners();
   }
   */

  Future<void> createNewProject(String projectName) async {
    await _repository.createNewProject(projectName);
    // **[REMOVIDO]** A linha 'await loadProjects()' foi removida.
    // O Stream atualizará a UI automaticamente.
  }

  Future<void> completeProject(String projectId) async {
    if (_expansionController != null) {
      _expansionController?.collapse();
    }
    await stopTimer();
    await _repository.setProjectStatus(projectId, true);
    // A atualização local é ótima para "UI otimista",
    // mas o Stream vai confirmar essa mudança de qualquer forma.
    final project = _allProjects.firstWhere((p) => p.id == projectId);
    project.isCompleted = true;
    notifyListeners();
  }

  Future<void> activateProject(String projectId) async {
    await _repository.setProjectStatus(projectId, false);
    final project = _allProjects.firstWhere((p) => p.id == projectId);
    project.isCompleted = false;
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    await _repository.deleteProject(projectId);
    // A UI será atualizada pelo Stream, mas a remoção local é uma
    // boa prática para "UI otimista".
    _allProjects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  // --- Lógica de Tarefas (Modificada para chamar updateProject) ---
  // ... (NENHUMA MUDANÇA AQUI)
  // Seu código de "atualizar localmente e depois chamar updateProject"
  // é o padrão perfeito para o Firestore.
  // Quando 'updateProject' for chamado, o Stream será notificado
  // e todos os outros usuários verão a mudança.

  Future<void> toggleTaskStatus({
    required domain.Project project,
    required String taskId,
    required Function(domain.Project project) onProjectReached100,
    required String currentUsername,
  }) async {
    final progressBefore = project.progress;
    domain.Task? targetTask;
    List<domain.Task>? parentTaskList;

    // Lógica local para encontrar e atualizar a tarefa (igual a antes)
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
      // Salva o projeto inteiro no Firestore
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
    await _repository.updateProject(project); // Salva o projeto inteiro
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
    await _repository.updateProject(project); // Salva o projeto inteiro
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
    await _repository.updateProject(project); // Salva o projeto inteiro
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
    await _repository.updateProject(project); // Salva o projeto inteiro
  }

  // --- Lógica de Soft Delete (Modificada) ---
  // ... (NENHUMA MUDANÇA AQUI)
  // Seu código de "soft delete" (definindo 'deletedAt') e "restore"
  // (definindo 'deletedAt = null') já funciona perfeitamente com
  // o método 'updateProject', que persistirá a mudança no Firestore.

  Future<void> softDeleteStep(String projectId, String stepId) async {
    final project = _allProjects.firstWhere((p) => p.id == projectId);
    final step = project.steps.firstWhere((s) => s.id == stepId);
    // Define a data de exclusão em vez de remover da lista
    step.deletedAt = DateTime.now();
    notifyListeners();
    await _repository.updateProject(project); // Salva o projeto inteiro
  }

  Future<void> fetchDeletedSteps(String projectId) async {
    _isLoadingDeletedSteps = true;
    _deletedSteps = [];
    _selectedStepsToRestore.clear();
    notifyListeners();

    // Busca localmente no projeto já carregado
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

    // Encontra o projeto (deve haver uma forma mais segura,
    // mas assumindo que todos pertencem ao mesmo projeto)
    final project = _allProjects.firstWhere(
        (p) => p.steps.any((s) => s.id == _selectedStepsToRestore.first));

    // Restaura localmente
    for (var step in project.steps) {
      if (_selectedStepsToRestore.contains(step.id)) {
        step.deletedAt = null;
      }
    }

    await _repository.updateProject(project); // Salva o projeto inteiro

    _selectedStepsToRestore.clear();
    _deletedSteps = [];
    notifyListeners();
    // Não é preciso chamar loadProjects(), a UI já reflete a mudança
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
