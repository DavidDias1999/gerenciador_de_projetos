import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/data/local/database.dart';
import 'package:gerenciador_de_projetos/data/repositories/project_repository.dart';
import 'package:gerenciador_de_projetos/data/services/project_service.dart';
import 'package:gerenciador_de_projetos/ui/app/widgets/app.dart';
import 'package:gerenciador_de_projetos/ui/projects/view_models/project_viewmodel.dart';
import 'package:provider/provider.dart';
import '/ui/core/themes/theme.dart';

void main() {
  final AppDatabase dataBase = AppDatabase();
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final projectService = ProjectService(dataBase: dataBase);
        final projectRepository = ProjectRepository(
          projectService: projectService,
        );
        return ProjectViewModel(repository: projectRepository);
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Projetos',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const AppGDP(),
    );
  }
}
