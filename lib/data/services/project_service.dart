import '../local/database.dart';
import '../../domain/models/project_model.dart' as domain;
import '../../domain/models/step_model.dart' as domain;
import '../../domain/models/sub_step_model.dart' as domain;
import '../../domain/models/task_model.dart' as domain;

class ProjectService {
  final AppDatabase _db;

  ProjectService({required AppDatabase database}) : _db = database;

  Future<List<domain.Project>> fetchProjects() async {
    final fullProjects = await _db.getAllProjects();

    final allUsersData = await _db.select(_db.users).get();
    final userMap = {for (var user in allUsersData) user.id: user.username};

    return fullProjects.map((fullProject) {
      return domain.Project(
        id: fullProject.project.id,
        projectName: fullProject.project.projectName,
        isCompleted: fullProject.project.isCompleted,
        steps: fullProject.steps.map((fullStep) {
          return domain.Step(
            id: fullStep.step.id,
            title: fullStep.step.title,
            deletedAt: fullStep.step.deletedAt,
            subSteps: fullStep.subSteps.map((fullSubStep) {
              return domain.SubStep(
                id: fullSubStep.subStep.id,
                title: fullSubStep.subStep.title,
                orderIndex: fullSubStep.subStep.orderIndex,
                tasks: fullSubStep.tasks.map((taskData) {
                  return domain.Task(
                    id: taskData.id,
                    title: taskData.title,
                    isCompleted: taskData.isCompleted,
                    orderIndex: taskData.orderIndex,
                    completedAt: taskData.completedAt,
                    completedByUsername: userMap[taskData.completedByUserId],
                  );
                }).toList(),
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  Future<void> createNewProject(String projectName) async {
    await _db.createNewProject(projectName);
  }

  Future<void> updateTask(
      String taskId, bool isCompleted, int currentUserId) async {
    await _db.updateTaskStatus(
      taskId: taskId,
      isCompleted: isCompleted,
      userId: currentUserId,
    );
  }

  Future<void> setProjectStatus(String projectId, bool isCompleted) async {
    await _db.setProjectCompletionStatus(projectId, isCompleted);
  }

  Future<void> deleteProject(String projectId) async {
    await _db.deleteProject(projectId);
  }

  Future<void> selectAllTasksInSubStep(String subStepId) async {
    await _db.selectAllTasksInSubStep(subStepId);
  }

  Future<void> deselectAllTasksInSubStep(String subStepId) async {
    await _db.deselectAllTasksInSubStep(subStepId);
  }

  Future<void> softDeleteStep(String stepId) async {
    await _db.softDeleteStep(stepId);
  }

  Future<List<domain.Step>> getDeletedStepsForProject(String projectId) async {
    final deletedStepsData = await _db.getDeletedStepsForProject(projectId);
    return deletedStepsData.map((stepData) {
      return domain.Step(
        id: stepData.id,
        title: stepData.title,
        subSteps: [],
        deletedAt: stepData.deletedAt,
      );
    }).toList();
  }

  Future<void> restoreSteps(List<String> stepIds) async {
    await _db.restoreSteps(stepIds);
  }
}
