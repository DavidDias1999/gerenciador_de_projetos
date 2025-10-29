import 'dart:io';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gerenciador_de_projetos/data/repositories/auth_repository.dart';
import 'package:gerenciador_de_projetos/data/repositories/project_repository.dart';

import 'package:gerenciador_de_projetos/data/services/project_service.dart';
import 'package:gerenciador_de_projetos/ui/auth/view_models/auth_viewmodel.dart';
import 'package:gerenciador_de_projetos/ui/auth/widgets/auth_gate.dart';
import 'package:gerenciador_de_projetos/ui/projects/view_models/project_viewmodel.dart';
import 'package:provider/provider.dart';

import '/ui/core/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final AuthRepository authRepository = AuthRepository();
  final ProjectService projectService = ProjectService(
    firestore: firestore,
    auth: authRepository,
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
