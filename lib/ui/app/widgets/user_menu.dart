import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/auth/view_models/auth_viewmodel.dart';
import 'package:gerenciador_de_projetos/ui/projects/view_models/project_viewmodel.dart';
import 'package:gerenciador_de_projetos/ui/settings/settings_screen.dart';
import 'package:provider/provider.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  void _onSelected(BuildContext context, String value) async {
    if (value == 'logout') {
      await context.read<ProjectViewModel>().stopTimerAndCollapse();

      if (context.mounted) {
        context.read<AuthViewModel>().logout();
      }
    } else if (value == 'settings') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_rounded),
      tooltip: user?.name ?? user?.email,
      onSelected: (value) => _onSelected(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'settings',
          child: Text('Configurações'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Text('Deslogar ${user?.email ?? ''}'),
        ),
      ],
    );
  }
}

class NavRailUserMenu extends StatelessWidget {
  const NavRailUserMenu({super.key});

  void _onSelected(BuildContext context, String value) async {
    if (value == 'logout') {
      await context.read<ProjectViewModel>().stopTimerAndCollapse();

      if (context.mounted) {
        context.read<AuthViewModel>().logout();
      }
    } else if (value == 'settings') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return PopupMenuButton<String>(
      tooltip: user?.name ?? user?.email,
      onSelected: (value) => _onSelected(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'settings',
          child: Text('Configurações'),
        ),
        const PopupMenuDivider(),
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
          if (user != null && user.name != null && user.name!.isNotEmpty)
            Text(
              user.name!,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
