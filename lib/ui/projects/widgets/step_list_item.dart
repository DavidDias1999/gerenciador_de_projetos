import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';
import 'sub_step_list_item.dart';
import 'task_list_item.dart';

class StepListItem extends StatelessWidget {
  final domain.Project project;
  final domain.Step step;

  const StepListItem({
    super.key,
    required this.project,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ProjectViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    final bool allDirectTasksCompleted = step.directTasks.isNotEmpty &&
        step.directTasks.every((task) => task.isCompleted);
    final bool anyDirectTasksIncomplete =
        step.directTasks.any((task) => !task.isCompleted);

    return ExpansionTile(
      shape: const Border(),
      key: ValueKey(step.id),
      title: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                step.title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: step.progress,
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
              '${(step.progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20.0),
            onSelected: (String result) {
              final currentUser = authViewModel.currentUser;
              if (currentUser == null) return;

              if (result == 'deleteStep') {
                showDeleteStepConfirmationDialog(context, project, step);
              }
              if (result == 'selectAllDirect') {
                viewModel.selectAllTasksInStep(
                  stepId: step.id,
                  project: project,
                  userId: currentUser.id,
                  username: currentUser.username,
                );
              }
              if (result == 'deselectAllDirect') {
                viewModel.deselectAllTasksInStep(step.id, project);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                if (anyDirectTasksIncomplete)
                  const PopupMenuItem<String>(
                    value: 'selectAllDirect',
                    child: Text('Selecionar todas'),
                  ),
                if (allDirectTasksCompleted)
                  const PopupMenuItem<String>(
                    value: 'deselectAllDirect',
                    child: Text('Desmarcar todas'),
                  ),
                if (step.directTasks.isNotEmpty) const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'deleteStep',
                  child: Text(
                    'Deletar etapa',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      children: [
        ...step.subSteps.map(
            (subStep) => SubStepListItem(project: project, subStep: subStep)),
        ...step.directTasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 16.0),
            child: TaskListItem(project: project, task: task),
          ),
        ),
      ],
    );
  }
}
