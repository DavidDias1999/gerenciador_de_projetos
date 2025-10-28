import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/projects/view_models/project_viewmodel.dart';
import 'package:provider/provider.dart';

class RestoreSubStepsDialog extends StatelessWidget {
  const RestoreSubStepsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProjectViewModel>();

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Restaurar Subetapas'),
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
        child: viewModel.isLoadingDeletedSubSteps
            ? const Center(child: CircularProgressIndicator())
            : viewModel.deletedSubSteps.isEmpty
                ? const Center(
                    child: Text('Nenhuma subetapa na lixeira.'),
                  )
                : ListView.builder(
                    itemCount: viewModel.deletedSubSteps.length,
                    itemBuilder: (context, index) {
                      final subStep = viewModel.deletedSubSteps[index];
                      final isSelected = viewModel.selectedSubStepsToRestore
                          .contains(subStep.id);
                      return CheckboxListTile(
                        title: Text(subStep.title),
                        value: isSelected,
                        onChanged: (_) {
                          context
                              .read<ProjectViewModel>()
                              .toggleSubStepSelectionForRestore(subStep.id);
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
          onPressed: viewModel.selectedSubStepsToRestore.isEmpty
              ? null
              : () {
                  context.read<ProjectViewModel>().restoreSelectedSubSteps();
                  Navigator.of(context).pop();
                },
          child: const Text('Restaurar Selecionadas'),
        ),
      ],
    );
  }
}
