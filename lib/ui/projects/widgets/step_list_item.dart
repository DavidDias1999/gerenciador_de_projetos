import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import '../../app/widgets/app.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';
import 'restore_sub_steps_dialog.dart';
import 'sub_step_list_item.dart';
import 'task_list_item.dart';

class StepListItem extends StatefulWidget {
  final domain.Project project;
  final domain.Step step;
  final ProjectType projectType;

  const StepListItem({
    super.key,
    required this.project,
    required this.step,
    required this.projectType,
  });

  @override
  State<StepListItem> createState() => _StepListItemState();
}

class _StepListItemState extends State<StepListItem> {
  late final ExpansibleController _controller;

  bool get canHaveTimer => widget.step.directTasks.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = ExpansibleController();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProjectViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    final bool allDirectTasksCompleted = widget.step.directTasks.isNotEmpty &&
        widget.step.directTasks.every((task) => task.isCompleted);
    final bool anyDirectTasksIncomplete =
        widget.step.directTasks.any((task) => !task.isCompleted);

    return ExpansionTile(
      shape: const Border(),
      controller: _controller,
      key: ValueKey(widget.step.id),
      onExpansionChanged: (isExpanded) {
        if (widget.projectType == ProjectType.active && canHaveTimer) {
          viewModel.handleExpansionChange(
            itemId: widget.step.id,
            isExpanded: isExpanded,
            controller: _controller,
          );
        }
      },
      title: Row(
        children: [
          if (viewModel.activeTimerId == widget.step.id)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.timer_outlined,
                  size: 20, color: Theme.of(context).colorScheme.primary),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                widget.step.title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: widget.step.progress,
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
              '${(widget.step.progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20.0),
            onSelected: (String result) {
              final currentUser = authViewModel.currentUser;
              if (currentUser == null) return;

              if (result == 'deleteStep') {
                showDeleteStepConfirmationDialog(
                    context, widget.project, widget.step);
              }
              if (result == 'selectAllDirect') {
                viewModel.selectAllTasksInStep(
                  stepId: widget.step.id,
                  project: widget.project,
                  userId: currentUser.id,
                  username: currentUser.username,
                );
              }
              if (result == 'deselectAllDirect') {
                viewModel.deselectAllTasksInStep(
                    widget.step.id, widget.project);
              }
              if (result == 'restore_sub_steps') {
                showRestoreSubStepsDialog(context, widget.project);
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
                const PopupMenuItem<String>(
                  value: 'restore_sub_steps',
                  child: Text('Restaurar Subetapas'),
                ),
                const PopupMenuDivider(),
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
        ...widget.step.subSteps.map((subStep) => SubStepListItem(
            project: widget.project,
            subStep: subStep,
            projectType: widget.projectType)),
        ...widget.step.directTasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 16.0),
            child: TaskListItem(project: widget.project, task: task),
          ),
        ),
      ],
    );
  }
}
