import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/auth/view_models/auth_viewmodel.dart';
import 'package:gerenciador_de_projetos/ui/projects/widgets/project_list_screen.dart';
import 'package:gerenciador_de_projetos/ui/reports/reports_screen.dart';
import 'package:provider/provider.dart';

enum ProjectType { active, completed }

class AppGDP extends StatefulWidget {
  const AppGDP({super.key});

  @override
  State<AppGDP> createState() => _AppGDPState();
}

class _AppGDPState extends State<AppGDP> {
  int _selectedIndex = 0;
  final _screens = [
    const ProjectListScreen(projectType: ProjectType.active),
    const ProjectListScreen(projectType: ProjectType.completed),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.folder_open_outlined),
                  selectedIcon: Icon(Icons.folder_open),
                  label: Text('Ativos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder_zip_outlined),
                  selectedIcon: Icon(Icons.folder_zip),
                  label: Text('Finalizados'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('Relatórios'),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          authViewModel.logout();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'logout',
                          child: Text('Deslogar'),
                        ),
                      ],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_rounded),
                          const SizedBox(height: 4),
                          if (user != null) Text(user.username),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            indent: 20,
            endIndent: 20,
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
