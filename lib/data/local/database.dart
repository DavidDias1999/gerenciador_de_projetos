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
  TextColumn get clientName => text()();
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
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskData')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get stepId => text().references(Steps, #id)();
  @override
  Set<Column> get primaryKey => {id};
}

class FullProject {
  final ProjectData project;
  final List<FullStep> steps;
  FullProject({required this.project, required this.steps});
}

class FullStep {
  final StepData step;
  final List<TaskData> tasks;
  FullStep({required this.step, required this.tasks});
}

@DriftDatabase(tables: [Projects, Steps, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          // Se estamos vindo da versão 1, adicionamos a nova coluna.
          await m.addColumn(projects, projects.isCompleted);
        }
      },
    );
  }

  Future<List<FullProject>> getAllProjects() async {
    final projectsData = await select(projects).get();
    final List<FullProject> fullProjects = [];

    for (final projectData in projectsData) {
      final stepsQuery = select(steps)
        ..where((tbl) => tbl.projectId.equals(projectData.id));
      final projectStepsData = await stepsQuery.get();
      final List<FullStep> fullSteps = [];

      for (final stepData in projectStepsData) {
        final tasksQuery = select(tasks)
          ..where((tbl) => tbl.stepId.equals(stepData.id));
        final stepTasksData = await tasksQuery.get();
        fullSteps.add(FullStep(step: stepData, tasks: stepTasksData));
      }
      fullProjects.add(FullProject(project: projectData, steps: fullSteps));
    }
    return fullProjects;
  }

  Future<void> createNewProject(String clientName, String projectName) async {
    final uuid = Uuid();
    final newProjectId = uuid.v4();
    await transaction(() async {
      await into(projects).insert(
        ProjectsCompanion.insert(
          id: newProjectId,
          clientName: clientName,
          projectName: projectName,
        ),
      );

      final defaultSteps = await createDefaultSteps();
      for (final step in defaultSteps) {
        await into(this.steps).insert(
          StepsCompanion.insert(
            id: step.id,
            title: step.title,
            projectId: newProjectId,
          ),
        );
        for (final task in step.tasks) {
          await into(this.tasks).insert(
            TasksCompanion.insert(
              id: task.id,
              title: task.title,
              stepId: step.id,
            ),
          );
        }
      }
    });
  }

  Future<void> updateTaskStatus(String taskId, bool isCompleted) {
    return (update(tasks)..where((tbl) => tbl.id.equals(taskId))).write(
      TasksCompanion(isCompleted: Value(isCompleted)),
    );
  }

  Future<void> setProjectCompletionStatus(String projectId, bool isCompleted) {
    return (update(projects)..where((tbl) => tbl.id.equals(projectId))).write(
      ProjectsCompanion(isCompleted: Value(isCompleted)),
    );
  }

  Future<void> deleteProject(String projectId) async {
    await transaction(() async {
      final associatedSteps = await (select(
        steps,
      )..where((s) => s.projectId.equals(projectId))).get();
      final stepIds = associatedSteps.map((s) => s.id).toList();

      if (stepIds.isNotEmpty) {
        await (delete(tasks)..where((t) => t.stepId.isIn(stepIds))).go();
      }

      await (delete(steps)..where((s) => s.projectId.equals(projectId))).go();

      await (delete(projects)..where((p) => p.id.equals(projectId))).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
