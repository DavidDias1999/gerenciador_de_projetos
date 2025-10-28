import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import '../../../domain/models/sub_step_model.dart' as domain;
import '../../../domain/models/project_complexity.dart';
import '../view_models/project_viewmodel.dart';
import 'restore_steps_dialog.dart';
import 'restore_sub_steps_dialog.dart';

void showCreateProjectDialog(BuildContext context) {
  final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
  final projectNameController = TextEditingController();
  final squareMetersController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Novo Projeto'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: projectNameController,
              decoration: const InputDecoration(labelText: 'Nome do Projeto'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: squareMetersController,
              decoration: const InputDecoration(
                labelText: 'Metragem (m²)',
                suffixText: 'm²',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                final formattedValue = value.replaceAll(',', '.');
                if (double.tryParse(formattedValue) == null) {
                  return 'Número inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final m2Text = squareMetersController.text.replaceAll(',', '.');
              final squareMeters = double.tryParse(m2Text);

              viewModel.createNewProject(
                projectNameController.text,
                squareMeters,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

void showDeleteConfirmationDialog(
    BuildContext context, domain.Project project) {
  final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: Text(
        'Você tem certeza que deseja deletar o projeto "${project.projectName}"? Esta ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          child: const Text('Deletar'),
          onPressed: () {
            viewModel.deleteProject(project.id);
            Navigator.of(dialogContext).pop();
          },
        ),
      ],
    ),
  );
}

void showMoveToCompletedDialog(BuildContext context, domain.Project project) {
  ProjectComplexity? selectedComplexity;

  selectedComplexity = project.complexity;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final viewModel =
              Provider.of<ProjectViewModel>(context, listen: false);

          return AlertDialog(
            title: const Text('Finalizar Projeto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'O projeto "${project.projectName}" atingiu 100% ou foi marcado como concluído.',
                ),
                const SizedBox(height: 24),
                Text(
                  'Qual foi o nível de complexidade?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...ProjectComplexity.values
                    .map(
                      (complexity) => RadioListTile<ProjectComplexity>(
                        title: Text(complexity.displayName),
                        value: complexity,
                        groupValue: selectedComplexity,
                        onChanged: (ProjectComplexity? value) {
                          setState(() {
                            selectedComplexity = value;
                          });
                        },
                      ),
                    )
                    .toList(),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                onPressed: selectedComplexity == null
                    ? null
                    : () {
                        viewModel.finalizeProject(
                          project.id,
                          selectedComplexity!,
                        );
                        Navigator.of(dialogContext).pop();
                      },
                child: const Text('Confirmar e Mover'),
              ),
            ],
          );
        },
      );
    },
  );
}

void showDeleteStepConfirmationDialog(
    BuildContext context, domain.Project project, domain.Step step) {
  final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: Text(
        'Você tem certeza que deseja deletar a etapa "${step.title}"? Suas subetapas e tarefas também serão ocultadas mas poderão ser restauradas.',
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          child: const Text('Deletar Etapa'),
          onPressed: () {
            viewModel.softDeleteStep(project.id, step.id);
            Navigator.of(dialogContext).pop();
          },
        ),
      ],
    ),
  );
}

void showDeleteSubStepConfirmationDialog(
    BuildContext context, domain.Project project, domain.SubStep subStep) {
  final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: Text(
        'Você tem certeza que deseja deletar a subetapa "${subStep.title}"? Suas tarefas também serão ocultadas mas poderão ser restauradas.',
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          child: const Text('Deletar SubEtapa'),
          onPressed: () {
            viewModel.softDeleteSubStep(project.id, subStep.id);
            Navigator.of(dialogContext).pop();
          },
        ),
      ],
    ),
  );
}

void showRestoreStepsDialog(BuildContext context, domain.Project project) {
  final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
  viewModel.fetchDeletedSteps(project.id);
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: viewModel,
      child: const RestoreStepsDialog(),
    ),
  );
}

void showRestoreSubStepsDialog(BuildContext context, domain.Project project) {
  final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
  viewModel.fetchDeletedSubSteps(project.id);
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: viewModel,
      child: const RestoreSubStepsDialog(),
    ),
  );
}
