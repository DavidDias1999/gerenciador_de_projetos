import 'package:flutter/material.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/project_complexity.dart';

class GeneralReportPanel extends StatelessWidget {
  final List<domain.Project> completedProjects;

  const GeneralReportPanel({
    super.key,
    required this.completedProjects,
  });

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    if (completedProjects.isEmpty) {
      return const Center(
          child: Text('Nenhum projeto finalizado para analisar.'));
    }

    // Calcula tempo médio
    int totalDurationAll = completedProjects.fold(
        0,
        (sum, p) =>
            sum + (p.finalTotalDurationInSeconds ?? p.totalDurationInSeconds));
    int avgDuration = (totalDurationAll / completedProjects.length).round();

    // Projetos no prazo vs atrasados
    int onTime = 0;
    int delayed = 0;
    for (var p in completedProjects) {
      if (p.deadline != null && p.finalizedAt != null) {
        final dDate =
            DateTime(p.deadline!.year, p.deadline!.month, p.deadline!.day);
        final fDate = DateTime(
            p.finalizedAt!.year, p.finalizedAt!.month, p.finalizedAt!.day);
        if (fDate.isAfter(dDate)) {
          delayed++;
        } else {
          onTime++;
        }
      }
    }

    // Produtividade por complexidade (min/m2)
    Map<ProjectComplexity, List<double>> minpm2ByComplexity = {
      ProjectComplexity.baixa: [],
      ProjectComplexity.media: [],
      ProjectComplexity.alta: [],
    };

    for (var p in completedProjects) {
      if (p.complexity != null &&
          p.squareMeters != null &&
          p.squareMeters! > 0) {
        int totalSeconds =
            p.finalTotalDurationInSeconds ?? p.totalDurationInSeconds;
        double minutes = totalSeconds / 60.0;
        double minpm2 = minutes / p.squareMeters!;

        minpm2ByComplexity[p.complexity!]!.add(minpm2);
      }
    }

    double getAvgMinpm2(ProjectComplexity complexity) {
      final list = minpm2ByComplexity[complexity]!;
      if (list.isEmpty) return 0.0;
      return list.fold(0.0, (sum, v) => sum + v) / list.length;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumo Geral',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Projetos Finalizados',
                    value: '${completedProjects.length}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'No Prazo',
                    value: '$onTime',
                    icon: Icons.thumb_up_alt_outlined,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Com Atraso',
                    value: '$delayed',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Produtividade Média (Minuto / m²)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProductivityCard(
                    complexityName: 'Baixa',
                    avgValue: getAvgMinpm2(ProjectComplexity.baixa),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ProductivityCard(
                    complexityName: 'Média',
                    avgValue: getAvgMinpm2(ProjectComplexity.media),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ProductivityCard(
                    complexityName: 'Alta',
                    avgValue: getAvgMinpm2(ProjectComplexity.alta),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProductivityCard extends StatelessWidget {
  final String complexityName;
  final double avgValue;

  const _ProductivityCard({
    required this.complexityName,
    required this.avgValue,
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
        children: [
          Text(
            complexityName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            avgValue > 0 ? '${avgValue.toStringAsFixed(2)} min/m²' : '-',
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
