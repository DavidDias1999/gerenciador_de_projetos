import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/user_model.dart';
import 'package:gerenciador_de_projetos/ui/auth/view_models/auth_viewmodel.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipe'),
      ),
      body: StreamBuilder<List<User>>(
        stream: authViewModel.getAuthorizedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar equipe: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isMe = currentUser?.id == user.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Badge(
                    isLabelVisible: user.isOnline,
                    backgroundColor: Colors.green,
                    smallSize: 12,
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      backgroundColor: user.role == UserRole.admin ? Colors.blue.shade100 : Colors.grey.shade200,
                      child: Icon(
                        user.role == UserRole.admin ? Icons.admin_panel_settings : Icons.person,
                        color: user.role == UserRole.admin ? Colors.blue.shade700 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  title: Text(user.name ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${user.email}\n'
                    '${user.role == UserRole.admin ? "Administrador" : "Colaborador"}'
                    '${!user.isOnline && user.lastSeen != null ? "\nVisto por último ${_formatDate(user.lastSeen!)}" : ""}',
                  ),
                  isThreeLine: true,
                  trailing: isMe
                      ? const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Text('Você', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                user.role == UserRole.admin ? Icons.arrow_downward : Icons.arrow_upward,
                                color: user.role == UserRole.admin ? Colors.orange : Colors.blue,
                              ),
                              tooltip: user.role == UserRole.admin ? 'Rebaixar para Colaborador' : 'Promover a Administrador',
                              onPressed: () => _confirmChangeRole(context, authViewModel, user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Excluir Usuário',
                              onPressed: () => _confirmDelete(context, authViewModel, user),
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmChangeRole(BuildContext context, AuthViewModel viewModel, User user) {
    final bool willBeAdmin = user.role != UserRole.admin;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willBeAdmin ? 'Promover a Administrador?' : 'Rebaixar para Colaborador?'),
        content: Text(
          willBeAdmin
              ? 'O usuário ${user.name ?? user.email} terá acesso total ao sistema.'
              : 'O usuário ${user.name ?? user.email} perderá os acessos administrativos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.changeUserRole(
                user.id,
                willBeAdmin ? UserRole.admin : UserRole.collaborator,
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AuthViewModel viewModel, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Usuário?'),
        content: Text(
          'Tem certeza que deseja excluir ${user.name ?? user.email}?\n\n'
          'O acesso desta pessoa será revogado permanentemente.\n\nEsta ação não pode ser desfeita!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              viewModel.deleteUser(user.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0 && now.day == date.day) {
      return 'hoje às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
      return 'ontem às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return 'em ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
