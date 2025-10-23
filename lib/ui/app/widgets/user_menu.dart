import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/auth/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_rounded),
      tooltip: user?.email,
      onSelected: (value) {
        if (value == 'logout') {
          authViewModel.logout();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'logout',
          child: Text('Logout ${user?.email ?? ''}'),
        ),
      ],
    );
  }
}

class NavRailUserMenu extends StatelessWidget {
  const NavRailUserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return PopupMenuButton<String>(
      tooltip: user?.email,
      onSelected: (value) {
        if (value == 'logout') {
          authViewModel.logout();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_rounded),
          const SizedBox(height: 4),
          if (user != null)
            Text(
              user.email,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
