import 'package:flutter/material.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import 'project_dialogs.dart';
import 'sub_step_list_item.dart';

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
    return ExpansionTile(
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
              if (result == 'deleteStep') {
                showDeleteStepConfirmationDialog(context, project, step);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'deleteStep',
                child: Text(
                  'Deletar etapa',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
      children: step.subSteps
          .map((subStep) => SubStepListItem(project: project, subStep: subStep))
          .toList(),
    );
  }
}
