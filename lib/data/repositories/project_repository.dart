import '../services/project_service.dart';
import '../../domain/models/project_model.dart';

class ProjectRepository {
  final ProjectService _projectService;

  ProjectRepository({required ProjectService projectService})
    : _projectService = projectService;

  Future<List<Project>> getProjects() => _projectService.fetchProjects();

  Future<void> createNewProject(String clientName, String projectName) =>
      _projectService.createNewProject(clientName, projectName);

  Future<void> updateTask(String taskId, bool isCompleted) =>
      _projectService.updateTask(taskId, isCompleted);

  Future<void> setProjectStatus(String projectId, bool isCompleted) =>
      _projectService.setProjectStatus(projectId, isCompleted);
}
