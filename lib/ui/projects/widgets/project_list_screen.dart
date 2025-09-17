import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/project_model.dart';
import '../../app/widgets/app.dart';
import '../view_models/project_viewmodel.dart';

class ProjectListScreen extends StatefulWidget {
  final ProjectType projectType;

  const ProjectListScreen({required this.projectType, super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
    if (viewModel.activeProjects.isEmpty &&
        viewModel.completedProjects.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadProjects();
      });
    }
  }

  void _showCreateProjectDialog(BuildContext context) {
    final viewModel = Provider.of<ProjectViewModel>(context, listen: false);
    final clienteNameController = TextEditingController();
    final projectNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Projeto'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: clienteNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Cliente',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo Obrigatório'
                      : null,
                ),
                TextFormField(
                  controller: projectNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Projeto',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo Obrigatório'
                      : null,
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
                  viewModel.createNewProject(
                    clienteNameController.text,
                    projectNameController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showMoveToCompletedDialog(Project project) {
    final viewModel = Provider.of<ProjectViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Projeto Finalizado!'),
          content: Text(
            'Deseja mover o projeto "${project.projectName}" para a área de finalizados?',
          ),
          actions: [
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Sim, Mover'),
              onPressed: () {
                viewModel.refreshProjectLists();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Project project) {
    final viewModel = Provider.of<ProjectViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
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
              // Usando um botão com mais destaque para a ação destrutiva
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.projectType == ProjectType.active
        ? 'Projetos Ativos'
        : 'Projetos Finalizados';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Consumer<ProjectViewModel>(
        builder: (context, viewModel, child) {
          final projects = widget.projectType == ProjectType.active
              ? viewModel.activeProjects
              : viewModel.completedProjects;
          if (viewModel.isLoading) {
            return Center(
              child: Text(
                'Nenhum Projeto ${widget.projectType == ProjectType.active ? 'ativo' : 'finalizado'} encontrado',
              ),
            );
          }
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  key: ValueKey(project.id),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.clientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              project.projectName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String result) {
                          if (result == 'complete') {
                            viewModel.completeProject(project.id);
                          } else if (result == 'activate') {
                            viewModel.activateProject(project.id);
                          } else if (result == 'delete') {
                            // Chama o novo diálogo de confirmação
                            _showDeleteConfirmationDialog(context, project);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              if (widget.projectType == ProjectType.active)
                                const PopupMenuItem<String>(
                                  value: 'complete',
                                  child: Text('Finalizar projeto'),
                                ),
                              if (widget.projectType == ProjectType.completed)
                                const PopupMenuItem<String>(
                                  value: 'activate',
                                  child: Text('Ativar projeto'),
                                ),
                              const PopupMenuDivider(), // Adiciona um divisor visual
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
                  children: project.steps.map((step) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ExpansionTile(
                        key: ValueKey(step.id),
                        title: Text(step.title),
                        children: step.tasks.map((task) {
                          return ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? value) {
                                viewModel.toggleTaskStatus(
                                  task.id,
                                  task.isCompleted,
                                );
                              },
                            ),
                            title: Text(task.title),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.projectType == ProjectType.active
          ? FloatingActionButton(
              onPressed: () => _showCreateProjectDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
