import '../services/project_service.dart';
import '../../domain/models/project_model.dart';

class ProjectRepository {
  final ProjectService _projectService;

  ProjectRepository({required ProjectService projectService})
    : _projectService = projectService;

  Future<List<Project>> getProjects() => _projectService.fetchProjects();

  Future<void> createNewProject(String projectName) =>
      _projectService.createNewProject(projectName);

  Future<void> updateTask(String taskId, bool isCompleted) =>
      _projectService.updateTask(taskId, isCompleted);

  Future<void> setProjectStatus(String projectId, bool isCompleted) =>
      _projectService.setProjectStatus(projectId, isCompleted);

  Future<void> deleteProject(String projectId) =>
      _projectService.deleteProject(projectId);

  Future<void> selectAllTasksInStep(String stepId) =>
      _projectService.selectAllTasksInStep(stepId);

  Future<void> deselectAllTasksInStep(String stepId) =>
      _projectService.deselectAllTasksInStep(stepId);

  Future<void> deleteStep(String stepId) => _projectService.deleteStep(stepId);
}
