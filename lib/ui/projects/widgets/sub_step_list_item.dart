import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/sub_step_model.dart' as domain;
import '../../app/widgets/app.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';
import 'task_list_item.dart';

class SubStepListItem extends StatefulWidget {
  final domain.Project project;
  final domain.SubStep subStep;
  final ProjectType projectType;

  const SubStepListItem({
    super.key,
    required this.project,
    required this.subStep,
    required this.projectType,
  });

  @override
  State<SubStepListItem> createState() => _SubStepListItemState();
}

class _SubStepListItemState extends State<SubStepListItem> {
  late final ExpansibleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpansibleController();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProjectViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    final double progressBarWidth = isPortrait ? 50.0 : 80.0;
    final double percentageWidth = isPortrait ? 35.0 : 40.0;
    final double spacingBeforeProgress = isPortrait ? 8.0 : 16.0;
    final double spacingBeforePercentage = isPortrait ? 4.0 : 8.0;

    final bool allTasksCompleted = widget.subStep.tasks.isNotEmpty &&
        widget.subStep.tasks.every((task) => task.isCompleted);
    final bool anyTasksIncomplete =
        widget.subStep.tasks.any((task) => !task.isCompleted);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          isPortrait ? 24.0 : 32, 0, isPortrait ? 8.0 : 16, 0),
      child: ExpansionTile(
        key: PageStorageKey(widget.subStep.id),
        shape: const Border(),
        controller: _controller,
        onExpansionChanged: (isExpanded) {
          if (widget.projectType == ProjectType.active) {
            viewModel.handleExpansionChange(
              itemId: widget.subStep.id,
              isExpanded: isExpanded,
              controller: _controller,
            );
          }
        },
        tilePadding: EdgeInsets.symmetric(
            horizontal: isPortrait ? 8.0 : 16.0, vertical: 0),
        title: Row(
          children: [
            if (viewModel.activeTimerId == widget.subStep.id)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.timer_outlined,
                    size: 18, color: Theme.of(context).colorScheme.primary),
              ),
            Expanded(
              child: Text(
                widget.subStep.title,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: spacingBeforeProgress),
            SizedBox(
              width: progressBarWidth,
              child: LinearProgressIndicator(
                value: widget.subStep.progress,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                minHeight: 8,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            SizedBox(width: spacingBeforePercentage),
            SizedBox(
              width: percentageWidth,
              child: Text(
                '${(widget.subStep.progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.end,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: "Mais opções",
              onSelected: (String result) {
                final currentUser = authViewModel.currentUser;
                if (currentUser == null) return;
                final completionUsername =
                    currentUser.name ?? currentUser.email;

                if (result == 'selectAll') {
                  viewModel.selectAllTasksInSubStep(
                    project: widget.project,
                    subStepId: widget.subStep.id,
                    username: completionUsername,
                    onProjectReached100: (p) =>
                        showMoveToCompletedDialog(context, p),
                  );
                } else if (result == 'deselectAll') {
                  viewModel.deselectAllTasksInSubStep(
                      widget.project.id, widget.subStep.id);
                } else if (result == 'deleteSubStep') {
                  showDeleteSubStepConfirmationDialog(
                      context, widget.project, widget.subStep);
                }
              },
              itemBuilder: (context) => [
                if (anyTasksIncomplete)
                  const PopupMenuItem(
                      value: 'selectAll', child: Text('Selecionar todas')),
                if (allTasksCompleted)
                  const PopupMenuItem(
                      value: 'deselectAll', child: Text('Desmarcar todas')),
                const PopupMenuItem<String>(
                  value: 'deleteSubStep',
                  child: Text(
                    'Deletar Subetapa',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                iconSize: 18.0,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity:
                    isPortrait ? VisualDensity.compact : VisualDensity.standard,
                tooltip: "Mais opções",
                onPressed: null,
              ),
            ),
          ],
        ),
        children: widget.subStep.tasks
            .map((task) => TaskListItem(project: widget.project, task: task))
            .toList(),
      ),
    );
  }
}
