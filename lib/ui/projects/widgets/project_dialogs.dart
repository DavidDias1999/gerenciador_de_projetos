import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import '../view_models/project_viewmodel.dart';
import 'restore_steps_dialog.dart';

void showCreateProjectDialog(BuildContext context) {
  final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
  final projectNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Novo Projeto'),
      content: Form(
        key: formKey,
        child: TextFormField(
          autofocus: true,
          controller: projectNameController,
          decoration: const InputDecoration(labelText: 'Nome do Projeto'),
          validator: (value) =>
              value == null || value.isEmpty ? 'Campo obrigatório' : null,
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
              viewModel.createNewProject(projectNameController.text);
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
  final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Projeto Finalizado!'),
      content: Text(
        'Deseja mover o projeto "${project.projectName}" para a área de finalizados?',
      ),
      actions: [
        TextButton(
          child: const Text('Não'),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        ElevatedButton(
          child: const Text('Sim, Mover'),
          onPressed: () {
            viewModel.completeProject(project.id);
            Navigator.of(dialogContext).pop();
          },
        ),
      ],
    ),
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
        'Você tem certeza que deseja deletar a etapa "${step.title}"? Suas sub-etapas e tarefas também serão ocultadas mas poderão ser restauradas.',
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
