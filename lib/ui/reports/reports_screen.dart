import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/app/widgets/user_menu.dart';
import 'package:provider/provider.dart';
import '../projects/view_models/project_viewmodel.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProjectViewModel>();
    final completedProjects = viewModel.completedProjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Projetos'),
        actions: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isMobile = MediaQuery.of(context).size.width < 600;
              if (isMobile) {
                return const UserMenu();
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: completedProjects.isEmpty
          ? const Center(child: Text('Nenhum projeto finalizado para exibir.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedProjects.length,
              itemBuilder: (context, index) {
                final project = completedProjects[index];

                final time =
                    'Tempo Total: ${_formatDuration(project.totalDurationInSeconds)}';
                final m2 = project.squareMeters != null
                    ? '\nMetragem: ${project.squareMeters!.toStringAsFixed(2)} m²'
                    : '';
                final complexity = project.complexity != null
                    ? '\nComplexidade: ${project.complexity!.displayName}'
                    : '\nComplexidade: N/A';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    shape: const Border(),
                    title: Text(project.projectName,
                        style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Text(
                      '$time$m2$complexity',
                    ),
                    children: project.steps.map((step) {
                      final totalStepDuration = step.durationInSeconds +
                          step.subSteps.fold<int>(
                              0, (sum, sub) => sum + sub.durationInSeconds);

                      if (step.subSteps.isEmpty && step.directTasks.isEmpty) {
                        return ListTile(
                          title: Text(step.title),
                          trailing: Text(_formatDuration(totalStepDuration)),
                        );
                      }

                      return ExpansionTile(
                        shape: const Border(),
                        title: Text(step.title),
                        trailing: Text(_formatDuration(totalStepDuration)),
                        children: step.subSteps.map((subStep) {
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 32, right: 16),
                            title: Text(subStep.title),
                            trailing: Text(
                                _formatDuration(subStep.durationInSeconds)),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
