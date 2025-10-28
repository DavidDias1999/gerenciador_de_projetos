import '../services/project_service.dart';
import '../../domain/models/project_model.dart';

class ProjectRepository {
  final ProjectService _projectService;

  ProjectRepository({required ProjectService projectService})
      : _projectService = projectService;

  Stream<List<Project>> getProjectsStream() =>
      _projectService.getProjectsStream();

  Future<void> createNewProject(String projectName, double? squareMeters) =>
      _projectService.createNewProject(projectName, squareMeters);

  Future<void> setProjectStatus(String projectId, bool isCompleted) =>
      _projectService.setProjectStatus(projectId, isCompleted);

  Future<void> deleteProject(String projectId) =>
      _projectService.deleteProject(projectId);

  Future<void> updateProject(Project project) =>
      _projectService.updateProject(project);
}
