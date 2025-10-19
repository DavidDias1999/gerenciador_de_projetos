import 'package:gerenciador_de_projetos/domain/models/sub_step_model.dart';

import '../services/project_service.dart';
import '../../domain/models/project_model.dart';
import '../../domain/models/step_model.dart';

class ProjectRepository {
  final ProjectService _projectService;

  ProjectRepository({required ProjectService projectService})
      : _projectService = projectService;

  Future<List<Project>> getProjects() => _projectService.fetchProjects();

  Future<void> createNewProject(String projectName) =>
      _projectService.createNewProject(projectName);

  Future<void> updateTask(
          String taskId, bool isCompleted, String currentUsername) =>
      _projectService.updateTask(taskId, isCompleted, currentUsername);

  Future<void> setProjectStatus(String projectId, bool isCompleted) =>
      _projectService.setProjectStatus(projectId, isCompleted);

  Future<void> deleteProject(String projectId) =>
      _projectService.deleteProject(projectId);

  Future<void> selectAllTasksInSubStep(String subStepId, String username) =>
      _projectService.selectAllTasksInSubStep(subStepId, username);

  Future<void> deselectAllTasksInSubStep(String subStepId) =>
      _projectService.deselectAllTasksInSubStep(subStepId);

  Future<void> selectAllTasksInStep(String stepId, String username) =>
      _projectService.selectAllTasksInStep(stepId, username);

  Future<void> deselectAllTasksInStep(String stepId) =>
      _projectService.deselectAllTasksInStep(stepId);

  Future<void> softDeleteStep(String stepId) =>
      _projectService.softDeleteStep(stepId);

  Future<List<Step>> getDeletedStepsForProject(String projectId) =>
      _projectService.getDeletedStepsForProject(projectId);

  Future<void> restoreSteps(List<String> stepIds) =>
      _projectService.restoreSteps(stepIds);

  Future<void> updateStepDuration(String stepId, int newDuration) =>
      _projectService.updateStepDuration(stepId, newDuration);

  Future<void> updateSubStepDuration(String subStepId, int newDuration) =>
      _projectService.updateSubStepDuration(subStepId, newDuration);
  Future<void> softDeleteSubStep(String subStepId) =>
      _projectService.softDeleteSubStep(subStepId);

  Future<List<SubStep>> getDeletedSubStepsForProject(String projectId) =>
      _projectService.getDeletedSubStepsForProject(projectId);

  Future<void> restoreSubSteps(List<String> subStepIds) =>
      _projectService.restoreSubSteps(subStepIds);
}
