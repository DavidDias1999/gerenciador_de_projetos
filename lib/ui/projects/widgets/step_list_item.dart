import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/project_model.dart' as domain;
import '../../../domain/models/step_model.dart' as domain;
import '../../app/widgets/app.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';
import 'sub_step_list_item.dart';
import 'task_list_item.dart';

class StepListItem extends StatefulWidget {
  final domain.Project project;
  final domain.Step step;
  final ProjectType projectType;

  const StepListItem({
    super.key,
    required this.project,
    required this.step,
    required this.projectType,
  });

  @override
  State<StepListItem> createState() => _StepListItemState();
}

class _StepListItemState extends State<StepListItem> {
  // O ExpansibleController ainda é útil se você o usa para
  // controlar a expansão programaticamente (como no timer).
  late final ExpansibleController _controller;

  // Determina se esta etapa pode ter um timer ativo
  bool get canHaveTimer => widget.step.directTasks.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = ExpansibleController();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProjectViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    // Detectar orientação
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    // Definir tamanhos/espaçamentos condicionais
    final double progressBarWidth = isPortrait ? 60.0 : 80.0;
    final double percentageWidth = isPortrait ? 35.0 : 40.0;
    final double spacingBeforeProgress = isPortrait ? 8.0 : 16.0;
    final double spacingBeforePercentage = isPortrait ? 4.0 : 8.0;

    final bool allDirectTasksCompleted = widget.step.directTasks.isNotEmpty &&
        widget.step.directTasks.every((task) => task.isCompleted);
    final bool anyDirectTasksIncomplete =
        widget.step.directTasks.any((task) => !task.isCompleted);

    return ExpansionTile(
      key: PageStorageKey(widget.step.id), // Preserva estado na rotação
      shape: const Border(),
      controller: _controller, // Mantido para controle do timer
      onExpansionChanged: (isExpanded) {
        // Lógica do timer continua aqui
        if (widget.projectType == ProjectType.active && canHaveTimer) {
          viewModel.handleExpansionChange(
            itemId: widget.step.id,
            isExpanded: isExpanded,
            controller: _controller,
          );
        }
      },
      title: Row(
        children: [
          if (viewModel.activeTimerId == widget.step.id)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.timer_outlined,
                  size: 20, color: Theme.of(context).colorScheme.primary),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isPortrait ? 8.0 : 16.0),
              child: Text(
                widget.step.title,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis, // Evita quebra de linha
                maxLines: 1, // Evita quebra de linha
              ),
            ),
          ),
          SizedBox(width: spacingBeforeProgress), // Espaçamento condicional
          SizedBox(
            width: progressBarWidth, // Largura condicional
            child: LinearProgressIndicator(
              value: widget.step.progress,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              minHeight: 8,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(width: spacingBeforePercentage), // Espaçamento condicional
          SizedBox(
            width: percentageWidth, // Largura condicional
            child: Text(
              '${(widget.step.progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.end, // Alinha à direita
            ),
          ),
          // CORRIGIDO: PopupMenuButton com IconButton como child
          PopupMenuButton<String>(
            tooltip: "Mais opções",
            onSelected: (String result) {
              final currentUser = authViewModel.currentUser;
              if (currentUser == null) return;
              final completionUsername = currentUser.name ?? currentUser.email;

              if (result == 'deleteStep') {
                showDeleteStepConfirmationDialog(
                    context, widget.project, widget.step);
              }
              if (result == 'selectAllDirect') {
                viewModel.selectAllTasksInStep(
                  stepId: widget.step.id,
                  project: widget.project,
                  username: completionUsername,
                );
              }
              if (result == 'deselectAllDirect') {
                viewModel.deselectAllTasksInStep(
                    widget.step.id, widget.project);
              }
              if (result == 'restore_sub_steps') {
                showRestoreSubStepsDialog(context, widget.project);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                if (anyDirectTasksIncomplete)
                  const PopupMenuItem<String>(
                    value: 'selectAllDirect',
                    child: Text('Selecionar todas'),
                  ),
                if (allDirectTasksCompleted)
                  const PopupMenuItem<String>(
                    value: 'deselectAllDirect',
                    child: Text('Desmarcar todas'),
                  ),
                if (widget.step.directTasks
                    .isNotEmpty) // Só mostra se houver tarefas diretas
                  const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'restore_sub_steps',
                  child: Text('Restaurar Subetapas'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'deleteStep',
                  child: Text(
                    'Deletar etapa',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ];
            },
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              iconSize: 20.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: isPortrait
                  ? VisualDensity.compact
                  : VisualDensity.standard, // Aplica aqui
              tooltip: "Mais opções",
              onPressed: null, // O PopupMenuButton cuida do toque
            ),
          ),
        ],
      ),
      children: [
        // Filtra sub-etapas deletadas
        ...widget.step.subSteps
            .where((subStep) => subStep.deletedAt == null)
            .map((subStep) => SubStepListItem(
                project: widget.project,
                subStep: subStep,
                projectType: widget.projectType)),
        ...widget.step.directTasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 16.0),
            child: TaskListItem(project: widget.project, task: task),
          ),
        ),
      ],
    );
  }
}
