import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import '../templates/project_template.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database.g.dart';

// 1. DEFINIÇÃO DAS TABELAS
@DataClassName('ProjectData')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get clientName => text()();
  TextColumn get projectName => text()();
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

// Classes para agrupar resultados das queries
class FullProject {
  // CORREÇÃO: Usa o tipo de dado gerado pelo Drift.
  final ProjectData project;
  final List<FullStep> steps;
  FullProject({required this.project, required this.steps});
}

class FullStep {
  // CORREÇÃO: Usa os tipos de dados gerados pelo Drift.
  final StepData step;
  final List<TaskData> tasks;
  FullStep({required this.step, required this.tasks});
}

// 2. CLASSE DO BANCO DE DADOS
@DriftDatabase(tables: [Projects, Steps, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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

      // CORREÇÃO: Nome da função do template estava incorreto.
      final defaultSteps = createDefaultSteps();
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
}

// Função helper para abrir a conexão
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
