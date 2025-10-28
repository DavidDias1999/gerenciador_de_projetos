import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/data/services/updater_service.dart';
import 'package:gerenciador_de_projetos/ui/app/widgets/user_menu.dart';
import 'package:provider/provider.dart';
import '../../app/widgets/app.dart';
import '../view_models/project_viewmodel.dart';
import 'project_dialogs.dart';
import 'project_list_item.dart';

class ProjectListScreen extends StatefulWidget {
  final ProjectType projectType;

  const ProjectListScreen({required this.projectType, super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen>
    with WidgetsBindingObserver {
  Size? _previousSize;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousSize = MediaQuery.of(context).size;

      checkForUpdates(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    final newSize = MediaQuery.of(context).size;
    if (_previousSize != null && _previousSize != newSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ProjectViewModel>().stopTimerAndCollapse();
        }
      });
      _previousSize = newSize;
    } else {
      _previousSize ??= newSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.projectType == ProjectType.active
        ? 'Projetos Ativos'
        : 'Projetos Finalizados';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
      body: Consumer<ProjectViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erro ao carregar dados: ${viewModel.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final projects = widget.projectType == ProjectType.active
              ? viewModel.activeProjects
              : viewModel.completedProjects;

          if (projects.isEmpty) {
            return Center(
              child: Text(
                'Nenhum projeto ${widget.projectType == ProjectType.active ? 'ativo' : 'finalizado'} encontrado.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ProjectListItem(
                project: project,
                projectType: widget.projectType,
              );
            },
          );
        },
      ),
      floatingActionButton: widget.projectType == ProjectType.active
          ? FloatingActionButton(
              onPressed: () => showCreateProjectDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
