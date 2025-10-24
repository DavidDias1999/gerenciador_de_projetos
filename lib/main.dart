import 'dart:io';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADICIONADO

// import 'package:gerenciador_de_projetos/data/local/database.dart'; // REMOVIDO
import 'package:gerenciador_de_projetos/data/repositories/auth_repository.dart';
import 'package:gerenciador_de_projetos/data/repositories/project_repository.dart';

import 'package:gerenciador_de_projetos/data/services/project_service.dart';
import 'package:gerenciador_de_projetos/ui/auth/view_models/auth_viewmodel.dart';
import 'package:gerenciador_de_projetos/ui/auth/widgets/auth_gate.dart';
import 'package:gerenciador_de_projetos/ui/projects/view_models/project_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '/ui/core/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Habilita a persistência offline do Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

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

  // Instanciações atualizadas
  final AuthRepository authRepository = AuthRepository();
  final ProjectService projectService = ProjectService(
    firestore: firestore,
    auth: authRepository, // O Service precisa saber o usuário logado
  );
  final ProjectRepository projectRepository =
      ProjectRepository(projectService: projectService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => ProjectViewModel(repository: projectRepository),
        ),
      ],
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
      home: const AuthGate(),
    );
  }
}
