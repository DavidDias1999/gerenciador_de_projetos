import 'package:flutter/material.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../core/formatters/date_formatter.dart';
import '../../core/themes/color_utils.dart';

class ProjectReportPanel extends StatelessWidget {
  final domain.Project project;

  const ProjectReportPanel({
    super.key,
    required this.project,
  });

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    // Collect all collaborators from tasks
    final Set<String> collaborators = {};
    for (var step in project.steps) {
      for (var task in step.directTasks) {
        if (task.completedByUsername != null &&
            task.completedByUsername!.isNotEmpty) {
          collaborators.add(task.completedByUsername!);
        }
      }
      for (var subStep in step.subSteps) {
        for (var task in subStep.tasks) {
          if (task.completedByUsername != null &&
              task.completedByUsername!.isNotEmpty) {
            collaborators.add(task.completedByUsername!);
          }
        }
      }
    }

    final hasCollaborators = collaborators.isNotEmpty;

    // Metrics calculations
    final totalSeconds =
        project.finalTotalDurationInSeconds ?? project.totalDurationInSeconds;
    final totalHours = totalSeconds / 3600.0;
    final totalMinutes = totalSeconds / 60.0;

    double minpm2 = 0;
    if (project.squareMeters != null && project.squareMeters! > 0) {
      minpm2 = totalMinutes / project.squareMeters!;
    }

    bool isDelayed = false;
    if (project.deadline != null && project.finalizedAt != null) {
      final dDate = DateTime(project.deadline!.year, project.deadline!.month,
          project.deadline!.day);
      final fDate = DateTime(project.finalizedAt!.year,
          project.finalizedAt!.month, project.finalizedAt!.day);
      isDelayed = fDate.isAfter(dDate);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Name and Complexity
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.projectName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                if (project.complexity != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Complexidade: ${project.complexity!.displayName}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Dates section
            Row(
              children: [
                if (project.createdAt != null)
                  Expanded(
                    child: _DateInfo(
                      title: 'Data de Início',
                      date: formatDate(project.createdAt!),
                      icon: Icons.play_circle_outline,
                    ),
                  ),
                if (project.createdAt != null) const SizedBox(width: 16),
                if (project.deadline != null)
                  Expanded(
                    child: _DateInfo(
                      title: 'Prazo Original',
                      date: formatDate(project.deadline!),
                      icon: Icons.calendar_today,
                    ),
                  ),
                if (project.deadline != null) const SizedBox(width: 16),
                if (project.finalizedAt != null)
                  Expanded(
                    child: _DateInfo(
                      title: 'Data de Entrega',
                      date: formatDate(project.finalizedAt!),
                      icon: Icons.flag_outlined,
                      isAlert: isDelayed,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Status do Prazo
            if (project.deadline != null && project.finalizedAt != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDelayed
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDelayed ? Colors.red : Colors.green,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isDelayed
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: isDelayed ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDelayed
                          ? 'Projeto entregue com atraso'
                          : 'Projeto entregue no prazo',
                      style: TextStyle(
                        color: isDelayed ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
            Text(
              'Métricas do Projeto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Tempo Total',
                    value: _formatDuration(totalSeconds),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Medida em M²',
                    value: project.squareMeters != null &&
                            project.squareMeters! > 0
                        ? '${project.squareMeters!.toStringAsFixed(2)} m²'
                        : '-',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Média min/m²',
                    value: project.squareMeters != null &&
                            project.squareMeters! > 0
                        ? '${minpm2.toStringAsFixed(2)} min/m²'
                        : '-',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text(
              'Colaboradores Envolvidos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            if (hasCollaborators)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: collaborators.map((name) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    label: Text(name),
                  );
                }).toList(),
              )
            else
              const Text('Nenhum colaborador registrou tarefas neste projeto.'),
          ],
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final bool isAlert;

  const _DateInfo({
    required this.title,
    required this.date,
    required this.icon,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isAlert
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isAlert
                          ? Colors.red
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isAlert ? Colors.red : null,
              ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
