import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                child: ExpansionTile(
                  title: Text(
                    project.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(project.projectName),
                  children: project.steps.map((step) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ExpansionTile(
                        title: Text(step.title),
                        children: step.tasks.map((task) {
                          return ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (bool? value) {
                                viewModel.toggleTaskStatus(
                                  project,
                                  step.id,
                                  task.id,
                                );
                              },
                            ),
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
