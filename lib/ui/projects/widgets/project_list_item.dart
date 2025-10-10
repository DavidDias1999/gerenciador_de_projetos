import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../app/widgets/app.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';
import 'step_list_item.dart';

class ProjectListItem extends StatelessWidget {
  final domain.Project project;
  final ProjectType projectType;

  const ProjectListItem({
    super.key,
    required this.project,
    required this.projectType,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ProjectViewModel>();

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        shape: const Border(),
        key: ValueKey(project.id),
        title: Row(
          children: [
            Expanded(
              child: Text(
                project.projectName,
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
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'complete') {
                  viewModel.completeProject(project.id);
                } else if (result == 'activate') {
                  viewModel.activateProject(project.id);
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
