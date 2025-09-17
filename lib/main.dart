import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/data/local/database.dart';
import 'package:gerenciador_de_projetos/data/repositories/project_repository.dart';
import 'package:gerenciador_de_projetos/data/services/project_service.dart';
import 'package:gerenciador_de_projetos/ui/app/widgets/app.dart';
import 'package:gerenciador_de_projetos/ui/projects/view_models/project_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '/ui/core/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 900),
      minimumSize: Size(600, 500),
      maximumSize: Size(1920, 1080),
      title: 'Gerenciador de Projetos',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
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
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Projetos',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const AppGDP(),
    );
  }
}
