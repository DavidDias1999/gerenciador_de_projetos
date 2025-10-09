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

  Future<void> updateTask(String taskId, bool isCompleted, int currentUserId) =>
      _projectService.updateTask(taskId, isCompleted, currentUserId);

  Future<void> setProjectStatus(String projectId, bool isCompleted) =>
      _projectService.setProjectStatus(projectId, isCompleted);

  Future<void> deleteProject(String projectId) =>
      _projectService.deleteProject(projectId);

  Future<void> selectAllTasksInSubStep(String subStepId, int userId) =>
      _projectService.selectAllTasksInSubStep(subStepId, userId);

  Future<void> deselectAllTasksInSubStep(String subStepId) =>
      _projectService.deselectAllTasksInSubStep(subStepId);

  Future<void> selectAllTasksInStep(String stepId, int userId) =>
      _projectService.selectAllTasksInStep(stepId, userId);

  Future<void> deselectAllTasksInStep(String stepId) =>
      _projectService.deselectAllTasksInStep(stepId);

  Future<void> softDeleteStep(String stepId) =>
      _projectService.softDeleteStep(stepId);

  Future<List<Step>> getDeletedStepsForProject(String projectId) =>
      _projectService.getDeletedStepsForProject(projectId);

  Future<void> restoreSteps(List<String> stepIds) =>
      _projectService.restoreSteps(stepIds);
}
