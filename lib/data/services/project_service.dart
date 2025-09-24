import '../local/database.dart';

import '../../domain/models/project_model.dart' as domain;
import '../../domain/models/step_model.dart' as domain;
import '../../domain/models/task_model.dart' as domain;

class ProjectService {
  final AppDatabase _db;

  ProjectService({required AppDatabase database}) : _db = database;

  domain.Project _mapFullProjectToDomain(FullProject fullProject) {
    return domain.Project(
      id: fullProject.project.id,
      projectName: fullProject.project.projectName,
      isCompleted: fullProject.project.isCompleted,
      steps: fullProject.steps.map((fullStep) {
        return domain.Step(
          id: fullStep.step.id,
          title: fullStep.step.title,
          tasks: fullStep.tasks.map((task) {
            return domain.Task(
                id: task.id,
                title: task.title,
                isCompleted: task.isCompleted,
                orderIndex: task.orderIndex);
          }).toList(),
        );
      }).toList(),
    );
  }

  Future<List<domain.Project>> fetchProjects() async {
    final fullProjects = await _db.getAllProjects();
    return fullProjects.map(_mapFullProjectToDomain).toList();
  }

  Future<void> createNewProject(String projectName) async {
    await _db.createNewProject(projectName);
  }

  Future<void> updateTask(String taskId, bool isCompleted) async {
    await _db.updateTaskStatus(taskId, isCompleted);
  }

  Future<void> setProjectStatus(String projectId, bool isCompleted) async {
    await _db.setProjectCompletionStatus(projectId, isCompleted);
  }

  Future<void> deleteProject(String projectId) async {
    await _db.deleteProject(projectId);
  }

  Future<void> selectAllTasksInStep(String stepId) async {
    await _db.selectAllTasksInStep(stepId);
  }

  Future<void> deselectAllTasksInStep(String stepId) async {
    await _db.deselectAllTasksInStep(stepId);
  }

  Future<void> deleteStep(String stepId) async {
    await _db.deleteStep(stepId);
  }
}
