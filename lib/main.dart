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
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

void main() async {
  // // DELETAR O BANCO DE DADOS NO WINDOWS
  // const bool DELETAR_BANCO_DE_DADOS_AO_INICIAR = true;
  // if (DELETAR_BANCO_DE_DADOS_AO_INICIAR) {
  //   final dbFolder = await getApplicationDocumentsDirectory();
  //   final file = File(p.join(dbFolder.path, 'db.sqlite'));

  //   if (await file.exists()) {
  //     await file.delete();
  //     print('====================================================');
  //     print('BANCO DE DADOS ANTIGO DELETADO COM SUCESSO.');
  //     print('====================================================');
  //   }
  // }

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 900),
      minimumSize: Size(600, 500),
      center: true,
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
        final projectService = ProjectService(database: dataBase);
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
