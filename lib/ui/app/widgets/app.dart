import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/projects/widgets/project_list_screen.dart';

enum ProjectType { active, completed }

class AppGDP extends StatefulWidget {
  const AppGDP({super.key});

  @override
  State<AppGDP> createState() => _AppGDPState();
}

class _AppGDPState extends State<AppGDP> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
              ],
            ),
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            indent: 20,
            endIndent: 20,
          ),
          Expanded(
            child: _selectedIndex == 0
                ? const ProjectListScreen(projectType: ProjectType.active)
                : const ProjectListScreen(projectType: ProjectType.completed),
          ),
        ],
      ),
    );
  }
}
