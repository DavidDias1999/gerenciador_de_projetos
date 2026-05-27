import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../core/formatters/date_formatter.dart'; // IMPORT ATUALIZADO
import '../../app/widgets/app.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';
import 'step_list_item.dart';

class ProjectListItemMobile extends StatelessWidget {
  final domain.Project project;
  final ProjectType projectType;

  const ProjectListItemMobile({
    super.key,
    required this.project,
    required this.projectType,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProjectViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final isAdmin = authViewModel.isAdmin;
    final String title = project.projectName;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        key: ValueKey('${project.id}_${viewModel.collapseTrigger}'),
        shape: const Border(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 90,
              child: LinearProgressIndicator(
                value: project.progress,
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
                '${(project.progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            if (isAdmin)
              PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == 'complete') {
                    showMoveToCompletedDialog(context, project);
                  } else if (result == 'activate') {
                    viewModel.activateProject(project.id);
                  } else if (result == 'edit_deadline') {
                    showEditDeadlineDialog(context, project);
                  } else if (result == 'delete') {
                    showDeleteConfirmationDialog(context, project);
                  } else if (result == 'restore_steps') {
                    showRestoreStepsDialog(context, project);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (projectType == ProjectType.active)
                    const PopupMenuItem<String>(
                      value: 'complete',
                      child: Text('Finalizar projeto'),
                    ),
                  if (projectType == ProjectType.completed)
                    const PopupMenuItem<String>(
                      value: 'activate',
                      child: Text('Ativar projeto'),
                    ),
                  if (projectType == ProjectType.active)
                    const PopupMenuItem<String>(
                      value: 'edit_deadline',
                      child: Text('Editar prazo'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'restore_steps',
                    child: Text('Restaurar etapas'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(
                      'Deletar projeto',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
          ],
        ),
        children: project.steps
            .where((step) => step.deletedAt == null)
            .map((step) => StepListItem(
                  project: project,
                  step: step,
                  projectType: projectType,
                ))
            .toList(),
      ),
    );
  }
}

class ProjectListItemDesktop extends StatelessWidget {
  final domain.Project project;
  final ProjectType projectType;
  final bool isSelected;

  const ProjectListItemDesktop({
    super.key,
    required this.project,
    required this.projectType,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ProjectViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final isAdmin = authViewModel.isAdmin;
    final String title = project.projectName;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
          : null,
      shape: RoundedRectangleBorder(
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : const BorderSide(color: Colors.transparent, width: 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => viewModel.selectProject(project.id),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 35,
                child: Text(
                  '${(project.progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.end,
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    if (result == 'complete') {
                      showMoveToCompletedDialog(context, project);
                    } else if (result == 'activate') {
                      viewModel.activateProject(project.id);
                    } else if (result == 'edit_deadline') {
                      showEditDeadlineDialog(context, project);
                    } else if (result == 'delete') {
                      showDeleteConfirmationDialog(context, project);
                    } else if (result == 'restore_steps') {
                      showRestoreStepsDialog(context, project);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    if (projectType == ProjectType.active)
                      const PopupMenuItem<String>(
                        value: 'complete',
                        child: Text('Finalizar projeto'),
                      ),
                    if (projectType == ProjectType.completed)
                      const PopupMenuItem<String>(
                        value: 'activate',
                        child: Text('Ativar projeto'),
                      ),
                    if (projectType == ProjectType.active)
                      const PopupMenuItem<String>(
                        value: 'edit_deadline',
                        child: Text('Editar prazo'),
                      ),
                    const PopupMenuItem<String>(
                      value: 'restore_steps',
                      child: Text('Restaurar etapas'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        'Deletar projeto',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectDetailsPanel extends StatelessWidget {
  final domain.Project project;
  final ProjectType projectType;

  const ProjectDetailsPanel({
    super.key,
    required this.project,
    required this.projectType,
  });

  @override
  Widget build(BuildContext context) {
    final activeSteps =
        project.steps.where((step) => step.deletedAt == null).toList();

    bool isOverdue = false;
    if (project.deadline != null && !project.isCompleted) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final deadlineDate = DateTime(project.deadline!.year,
          project.deadline!.month, project.deadline!.day);
      isOverdue = deadlineDate.isBefore(today);
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    project.projectName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (project.deadline != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOverdue
                            ? Colors.red.shade300
                            : Colors.blue.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOverdue
                              ? Icons.warning_amber_rounded
                              : Icons.calendar_today,
                          size: 16,
                          color: isOverdue
                              ? Colors.red.shade900
                              : Colors.blue.shade900,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Prazo: ${formatDate(project.deadline!)}',
                          style: TextStyle(
                            color: isOverdue
                                ? Colors.red.shade900
                                : Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  '${(project.progress * 100).toStringAsFixed(0)}% Concluído',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: activeSteps.isEmpty
                ? const Center(
                    child: Text('Nenhuma etapa ativa neste projeto.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: activeSteps.length,
                    itemBuilder: (context, index) {
                      return StepListItem(
                        project: project,
                        step: activeSteps[index],
                        projectType: projectType,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
