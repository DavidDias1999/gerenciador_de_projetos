// import 'package:gerenciador_de_projetos/domain/models/sub_step_model.dart'; // REMOVIDO
import '../services/project_service.dart';
import '../../domain/models/project_model.dart';
// import '../../domain/models/step_model.dart'; // REMOVIDO

class ProjectRepository {
  final ProjectService _projectService;

  ProjectRepository({required ProjectService projectService})
      : _projectService = projectService;

  // **[MODIFICADO]** Alterado de Future para Stream
  Stream<List<Project>> getProjectsStream() =>
      _projectService.getProjectsStream();

  Future<void> createNewProject(String projectName) =>
      _projectService.createNewProject(projectName);

  Future<void> setProjectStatus(String projectId, bool isCompleted) =>
      _projectService.setProjectStatus(projectId, isCompleted);

  Future<void> deleteProject(String projectId) =>
      _projectService.deleteProject(projectId);

  /// Método unificado para salvar quaisquer alterações no projeto.
  Future<void> updateProject(Project project) =>
      _projectService.updateProject(project);

  // Todos os outros métodos (updateTask, selectAll, softDelete, restore, etc.)
  // foram removidos. O ViewModel agora fará a alteração no objeto
  // 'Project' local e chamará 'updateProject' para salvar o estado completo.
}
