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

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
