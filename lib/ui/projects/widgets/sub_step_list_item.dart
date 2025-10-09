import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/sub_step_model.dart' as domain;
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';
import 'task_list_item.dart';

class SubStepListItem extends StatelessWidget {
  final domain.Project project;
  final domain.SubStep subStep;

  const SubStepListItem({
    super.key,
    required this.project,
    required this.subStep,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ProjectViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    final bool allTasksCompleted = subStep.tasks.isNotEmpty &&
        subStep.tasks.every((task) => task.isCompleted);
    final bool anyTasksIncomplete =
        subStep.tasks.any((task) => !task.isCompleted);

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 16, 0),
      child: ExpansionTile(
        shape: const Border(),
        key: ValueKey(subStep.id),
        title: Row(
          children: [
            Expanded(
              child: Text(subStep.title,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                value: subStep.progress,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                minHeight: 8,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              child: Text(
                '${(subStep.progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18.0),
              onSelected: (String result) {
                final currentUser = authViewModel.currentUser;
                if (currentUser == null) return;

                if (result == 'selectAll') {
                  viewModel.selectAllTasksInSubStep(
                    project: project,
                    subStepId: subStep.id,
                    userId: currentUser.id,
                    username: currentUser.username,
                    onProjectReached100: (p) =>
                        showMoveToCompletedDialog(context, p),
                  );
                } else if (result == 'deselectAll') {
                  viewModel.deselectAllTasksInSubStep(project.id, subStep.id);
                }
              },
              itemBuilder: (context) => [
                if (anyTasksIncomplete)
                  const PopupMenuItem(
                      value: 'selectAll', child: Text('Selecionar todas')),
                if (allTasksCompleted)
                  const PopupMenuItem(
                      value: 'deselectAll', child: Text('Desmarcar todas')),
              ],
            ),
          ],
        ),
        children: subStep.tasks
            .map((task) => TaskListItem(project: project, task: task))
            .toList(),
      ),
    );
  }
}
