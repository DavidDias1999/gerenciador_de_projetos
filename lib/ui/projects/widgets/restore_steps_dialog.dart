import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/projects/view_models/project_viewmodel.dart';
import 'package:provider/provider.dart';

class RestoreStepsDialog extends StatelessWidget {
  const RestoreStepsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProjectViewModel>();

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Restaurar Etapas'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: viewModel.isLoadingDeletedSteps
            ? const Center(child: CircularProgressIndicator())
            : viewModel.deletedSteps.isEmpty
                ? const Center(
                    child: Text('Nenhuma etapa na lixeira.'),
                  )
                : ListView.builder(
                    itemCount: viewModel.deletedSteps.length,
                    itemBuilder: (context, index) {
                      final step = viewModel.deletedSteps[index];
                      final isSelected =
                          viewModel.selectedStepsToRestore.contains(step.id);
                      return CheckboxListTile(
                        title: Text(step.title),
                        value: isSelected,
                        onChanged: (_) {
                          context
                              .read<ProjectViewModel>()
                              .toggleStepSelectionForRestore(step.id);
                        },
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: viewModel.selectedStepsToRestore.isEmpty
              ? null
              : () {
                  context.read<ProjectViewModel>().restoreSelectedSteps();
                  Navigator.of(context).pop();
                },
          child: const Text('Restaurar Selecionadas'),
        ),
      ],
    );
  }
}
