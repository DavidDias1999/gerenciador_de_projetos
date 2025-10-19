import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import '../templates/project_template.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database.g.dart';

@DataClassName('ProjectData')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get projectName => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StepData')
class Steps extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get durationInSeconds => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SubStepData')
class SubSteps extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  TextColumn get stepId => text().references(Steps, #id)();
  IntColumn get durationInSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskData')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get subStepId => text().nullable().references(SubSteps, #id)();
  TextColumn get stepId => text().nullable().references(Steps, #id)();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  TextColumn get completedByUsername => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK ((sub_step_id IS NOT NULL AND step_id IS NULL) OR (sub_step_id IS NULL AND step_id IS NOT NULL))'
      ];
}

class FullProject {
  final ProjectData project;
  final List<FullStep> steps;
  FullProject({required this.project, required this.steps});
}

class FullStep {
  final StepData step;
  final List<FullSubStep> subSteps;
  final List<TaskData> directTasks;

  FullStep({
    required this.step,
    required this.subSteps,
    required this.directTasks,
  });
}

class FullSubStep {
  final SubStepData subStep;
  final List<TaskData> tasks;
  FullSubStep({required this.subStep, required this.tasks});
}

@DriftDatabase(tables: [Projects, Steps, SubSteps, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 6) await m.createTable(subSteps);
        if (from < 7) {
          await m.addColumn(tasks, tasks.completedAt);
        }
        if (from < 8) await m.addColumn(tasks, tasks.stepId);
        if (from < 9) {
          await m.addColumn(steps, steps.durationInSeconds);
          await m.addColumn(subSteps, subSteps.durationInSeconds);
        }
        if (from < 10) {
          await m.addColumn(subSteps, subSteps.deletedAt);
        }
        if (from < 11) {
          await m.addColumn(tasks, tasks.completedByUsername);
        }
      },
    );
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required bool isCompleted,
    String? username,
  }) {
    return (update(tasks)..where((tbl) => tbl.id.equals(taskId))).write(
      TasksCompanion(
        isCompleted: Value(isCompleted),
        completedByUsername: Value(isCompleted ? username : null),
        completedAt: Value(isCompleted ? DateTime.now() : null),
      ),
    );
  }

  Future<void> selectAllTasksInSubStep(String subStepId, String username) {
    return (update(tasks)..where((t) => t.subStepId.equals(subStepId))).write(
      TasksCompanion(
        isCompleted: const Value(true),
        completedByUsername: Value(username),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deselectAllTasksInSubStep(String subStepId) {
    return (update(tasks)..where((t) => t.subStepId.equals(subStepId))).write(
      const TasksCompanion(
          isCompleted: Value(false),
          completedByUsername: Value(null),
          completedAt: Value(null)),
    );
  }

  Future<void> selectAllTasksInStep(String stepId, String username) {
    return (update(tasks)..where((t) => t.stepId.equals(stepId))).write(
      TasksCompanion(
        isCompleted: const Value(true),
        completedByUsername: Value(username),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deselectAllTasksInStep(String stepId) {
    return (update(tasks)..where((t) => t.stepId.equals(stepId))).write(
      const TasksCompanion(
          isCompleted: Value(false),
          completedByUsername: Value(null),
          completedAt: Value(null)),
    );
  }

  Future<List<FullProject>> getAllProjects() async {
    final projectsData = await select(projects).get();
    final List<FullProject> fullProjects = [];
    for (final projectData in projectsData) {
      final stepsQuery = select(steps)
        ..where((tbl) => tbl.projectId.equals(projectData.id))
        ..where((tbl) => tbl.deletedAt.isNull());
      final projectStepsData = await stepsQuery.get();
      final List<FullStep> fullSteps = [];
      for (final stepData in projectStepsData) {
        final subStepsQuery = select(subSteps)
          ..where((tbl) => tbl.stepId.equals(stepData.id))
          ..where((tbl) => tbl.deletedAt.isNull());
        final projectSubStepsData = await subStepsQuery.get();
        final List<FullSubStep> fullSubSteps = [];
        for (final subStepData in projectSubStepsData) {
          final tasksQuery = select(tasks)
            ..where((tbl) => tbl.subStepId.equals(subStepData.id));
          final stepTasksData = await tasksQuery.get();
          fullSubSteps
              .add(FullSubStep(subStep: subStepData, tasks: stepTasksData));
        }
        final directTasksQuery = select(tasks)
          ..where((tbl) => tbl.stepId.equals(stepData.id));
        final directTasksData = await directTasksQuery.get();
        fullSteps.add(FullStep(
          step: stepData,
          subSteps: fullSubSteps,
          directTasks: directTasksData,
        ));
      }
      fullProjects.add(FullProject(project: projectData, steps: fullSteps));
    }
    return fullProjects;
  }

  Future<void> createNewProject(String projectName) async {
    final uuid = Uuid();
    final newProjectId = uuid.v4();
    await transaction(() async {
      await into(projects).insert(
        ProjectsCompanion.insert(id: newProjectId, projectName: projectName),
      );
      final defaultSteps = await createDefaultSteps();
      for (final step in defaultSteps) {
        await into(steps).insert(
          StepsCompanion.insert(
            id: step.id,
            title: step.title,
            projectId: newProjectId,
          ),
        );
        if (step.subSteps.isNotEmpty) {
          for (final subStep in step.subSteps) {
            await into(subSteps).insert(
              SubStepsCompanion.insert(
                id: subStep.id,
                title: subStep.title,
                orderIndex: Value(subStep.orderIndex),
                stepId: step.id,
              ),
            );
            for (final task in subStep.tasks) {
              await into(tasks).insert(
                TasksCompanion.insert(
                  id: task.id,
                  title: task.title,
                  orderIndex: Value(task.orderIndex),
                  subStepId: Value(subStep.id),
                ),
              );
            }
          }
        } else if (step.directTasks.isNotEmpty) {
          for (final task in step.directTasks) {
            await into(tasks).insert(
              TasksCompanion.insert(
                id: task.id,
                title: task.title,
                orderIndex: Value(task.orderIndex),
                stepId: Value(step.id),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> setProjectCompletionStatus(String projectId, bool isCompleted) {
    return (update(projects)..where((tbl) => tbl.id.equals(projectId))).write(
      ProjectsCompanion(isCompleted: Value(isCompleted)),
    );
  }

  Future<void> deleteProject(String projectId) async {
    await transaction(() async {
      final stepIdsQuery = select(steps, distinct: true)
        ..where((s) => s.projectId.equals(projectId));
      final stepIds = await stepIdsQuery.map((s) => s.id).get();
      if (stepIds.isNotEmpty) {
        final subStepIdsQuery = select(subSteps, distinct: true)
          ..where((ss) => ss.stepId.isIn(stepIds));
        final subStepIds = await subStepIdsQuery.map((ss) => ss.id).get();
        if (subStepIds.isNotEmpty) {
          await (delete(tasks)..where((t) => t.subStepId.isIn(subStepIds)))
              .go();
        }
        await (delete(tasks)..where((t) => t.stepId.isIn(stepIds))).go();
        await (delete(subSteps)..where((ss) => ss.stepId.isIn(stepIds))).go();
      }
      await (delete(steps)..where((s) => s.projectId.equals(projectId))).go();
      await (delete(projects)..where((p) => p.id.equals(projectId))).go();
    });
  }

  Future<void> softDeleteStep(String stepId) {
    return (update(steps)..where((s) => s.id.equals(stepId))).write(
      StepsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<List<StepData>> getDeletedStepsForProject(String projectId) {
    return (select(steps)
          ..where((s) => s.projectId.equals(projectId))
          ..where((s) => s.deletedAt.isNotNull()))
        .get();
  }

  Future<void> restoreSteps(List<String> stepIds) {
    return (update(steps)..where((s) => s.id.isIn(stepIds))).write(
      const StepsCompanion(deletedAt: Value(null)),
    );
  }

  Future<void> updateStepDuration(String stepId, int newDuration) {
    return (update(steps)..where((s) => s.id.equals(stepId))).write(
      StepsCompanion(durationInSeconds: Value(newDuration)),
    );
  }

  Future<void> updateSubStepDuration(String subStepId, int newDuration) {
    return (update(subSteps)..where((ss) => ss.id.equals(subStepId))).write(
      SubStepsCompanion(durationInSeconds: Value(newDuration)),
    );
  }

  Future<void> softDeleteSubStep(String subStepId) {
    return (update(subSteps)..where((ss) => ss.id.equals(subStepId))).write(
      SubStepsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<List<SubStepData>> getDeletedSubStepsForProject(String projectId) {
    final query = select(steps)
        .join([innerJoin(subSteps, subSteps.stepId.equalsExp(steps.id))])
      ..where(steps.projectId.equals(projectId))
      ..where(subSteps.deletedAt.isNotNull());

    return query.map((row) => row.readTable(subSteps)).get();
  }

  Future<void> restoreSubSteps(List<String> subStepIds) {
    return (update(subSteps)..where((ss) => ss.id.isIn(subStepIds))).write(
      const SubStepsCompanion(deletedAt: Value(null)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
