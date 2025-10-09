import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/task_model.dart' as domain;
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';

class TaskListItem extends StatelessWidget {
  final domain.Project project;
  final domain.Task task;

  const TaskListItem({
    super.key,
    required this.project,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ProjectViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 16),
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (bool? value) {
          final currentUser = authViewModel.currentUser;
          if (currentUser != null) {
            viewModel.toggleTaskStatus(
              project: project,
              taskId: task.id,
              onProjectReached100: (completedProject) =>
                  showMoveToCompletedDialog(context, completedProject),
              currentUserId: currentUser.id,
              currentUsername: currentUser.username,
            );
          }
        },
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: task.isCompleted ? Theme.of(context).disabledColor : null,
        ),
      ),
      subtitle: task.isCompleted && task.completedByUsername != null
          ? Text(
              'Concluído por: ${task.completedByUsername}',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
    );
  }
}
