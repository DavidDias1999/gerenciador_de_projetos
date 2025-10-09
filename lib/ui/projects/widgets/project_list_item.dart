import 'package:flutter/material.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../app/widgets/app.dart';
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
                if (result == 'delete') {
                  showDeleteConfirmationDialog(context, project);
                } else if (result == 'restore_steps') {
                  showRestoreStepsDialog(context, project);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'restore_steps',
                  child: Text('Restaurar etapas'),
                ),
                const PopupMenuDivider(),
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
            .map((step) => StepListItem(project: project, step: step))
            .toList(),
      ),
    );
  }
}
