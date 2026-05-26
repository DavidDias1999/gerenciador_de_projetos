import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gerenciador_de_projetos/ui/auth/view_models/auth_viewmodel.dart';
import 'package:gerenciador_de_projetos/ui/projects/view_models/project_viewmodel.dart';
import 'package:gerenciador_de_projetos/ui/projects/widgets/project_list_screen.dart';
import 'package:gerenciador_de_projetos/ui/reports/reports_screen.dart';
import 'package:gerenciador_de_projetos/ui/users/users_screen.dart';
import 'user_menu.dart';

enum ProjectType { active, completed }

class AppGDP extends StatefulWidget {
  const AppGDP({super.key});

  @override
  State<AppGDP> createState() => _AppGDPState();
}

class _AppGDPState extends State<AppGDP> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProjectViewModel>().loadProjects();
        context.read<AuthViewModel>().updatePresence(true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final authViewModel = context.read<AuthViewModel>();
    
    if (state == AppLifecycleState.resumed) {
      authViewModel.updatePresence(true);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      authViewModel.updatePresence(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthViewModel>().isAdmin;

    final screens = [
      const ProjectListScreen(projectType: ProjectType.active),
      if (isAdmin) const ProjectListScreen(projectType: ProjectType.completed),
      if (isAdmin) const ReportsScreen(),
      if (isAdmin) const UsersScreen(),
    ];

    final navRailDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.folder_open_outlined),
        selectedIcon: Icon(Icons.folder_open),
        label: Text('Ativos'),
      ),
      if (isAdmin)
        const NavigationRailDestination(
          icon: Icon(Icons.folder_zip_outlined),
          selectedIcon: Icon(Icons.folder_zip),
          label: Text('Finalizados'),
        ),
      if (isAdmin)
        const NavigationRailDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: Text('Relatórios'),
        ),
      if (isAdmin)
        const NavigationRailDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt),
          label: Text('Equipe'),
        ),
    ];

    final bottomNavItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.folder_open_outlined),
        activeIcon: Icon(Icons.folder_open),
        label: 'Ativos',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.folder_zip_outlined),
          activeIcon: Icon(Icons.folder_zip),
          label: 'Finalizados',
        ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Relatórios',
        ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          activeIcon: Icon(Icons.people_alt),
          label: 'Equipe',
        ),
    ];

    // Segurança para evitar crash se o _selectedIndex estiver fora dos limites (ex: após mudar de permissão)
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Scaffold(
            body: screens[_selectedIndex],
            bottomNavigationBar: bottomNavItems.length > 1
                ? BottomNavigationBar(
                    items: bottomNavItems,
                    currentIndex: _selectedIndex,
                    onTap: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  )
                : null, // Se só tem 1 item (colab), esconde a navbar inteira para ganhar espaço
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
                    destinations: navRailDestinations,
                    trailing: const Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: NavRailUserMenu(),
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
                Expanded(child: screens[_selectedIndex]),
              ],
            ),
          );
        }
      },
    );
  }
}
