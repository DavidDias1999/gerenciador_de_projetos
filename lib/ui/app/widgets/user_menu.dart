import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/domain/models/user_model.dart';
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
        context.read<ProjectViewModel>().clear();
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NotificationBellWidget(),
        PopupMenuButton<String>(
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
        context.read<ProjectViewModel>().clear();
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NotificationBellWidget(),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
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
        ),
      ],
    );
  }
}

class NotificationBellWidget extends StatelessWidget {
  const NotificationBellWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    if (!authViewModel.isAdmin) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<User>>(
      stream: authViewModel.getPendingUsers(),
      builder: (context, snapshot) {
        final pendingUsers = snapshot.data ?? [];
        final count = pendingUsers.length;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const PendingUsersDialog(),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PendingUsersDialog extends StatelessWidget {
  const PendingUsersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    return AlertDialog(
      title: const Text('Autorizar Usuários'),
      content: SizedBox(
        width: 400,
        child: StreamBuilder<List<User>>(
          stream: authViewModel.getPendingUsers(),
          builder: (context, snapshot) {
            final users = snapshot.data ?? [];
            
            if (users.isEmpty) {
              return const Text('Nenhum usuário aguardando autorização.');
            }
            
            return ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Negar',
                          onPressed: () {
                            authViewModel.denyUser(user.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: 'Autorizar',
                          onPressed: () {
                            authViewModel.authorizeUser(user.id);
                            // Pode remover o pop() para que o admin autorize vários usuários de uma vez sem fechar o modal
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Sair'),
        ),
      ],
    );
  }
}
