import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/projects/widgets/project_list_screen.dart';
import 'package:gerenciador_de_projetos/ui/reports/reports_screen.dart';
import 'user_menu.dart';

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

  final List<NavigationRailDestination> _navRailDestinations = const [
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
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_open_outlined),
      activeIcon: Icon(Icons.folder_open),
      label: 'Ativos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_zip_outlined),
      activeIcon: Icon(Icons.folder_zip),
      label: 'Finalizados',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: 'Relatórios',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Scaffold(
            body: _screens[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              items: _bottomNavItems,
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          );
        } else {
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
                    destinations: _navRailDestinations,
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: const NavRailUserMenu(),
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
      },
    );
  }
}
