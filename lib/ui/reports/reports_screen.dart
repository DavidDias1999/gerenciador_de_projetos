import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/ui/app/widgets/user_menu.dart';
import 'package:provider/provider.dart';
import '../projects/view_models/project_viewmodel.dart';
import 'widgets/general_report_panel.dart';
import 'widgets/project_report_panel.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // null significa "Resumo Geral" selecionado.
  // Se contiver uma String, é o ID do projeto selecionado.
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProjectViewModel>();
    
    // Filtra e ordena os projetos finalizados do mais recente para o mais antigo
    final completedProjects = List.of(viewModel.completedProjects)
      ..sort((a, b) {
        if (a.finalizedAt == null && b.finalizedAt == null) return 0;
        if (a.finalizedAt == null) return 1;
        if (b.finalizedAt == null) return -1;
        return b.finalizedAt!.compareTo(a.finalizedAt!);
      });

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna da Esquerda (Lista)
                SizedBox(
                  width: constraints.maxWidth * 0.35,
                  child: _buildList(completedProjects, isDesktop: true),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // Coluna da Direita (Detalhes)
                Expanded(
                  child: _buildDetailsPanel(completedProjects),
                ),
              ],
            );
          } else {
            // Mobile view: se tem um projeto ou resumo selecionado e o usuário clicou (no mobile a navegação seria diferente, 
            // mas para manter simples podemos exibir a lista, e ao clicar abrir um modal ou nova tela.
            // Para simplificar, vou manter a lista e, ao clicar, empurrar uma nova tela com os detalhes.)
            return _buildList(completedProjects, isDesktop: false);
          }
        },
      ),
    );
  }

  Widget _buildList(List<dynamic> projects, {required bool isDesktop}) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: projects.length + 1, // +1 for "Resumo Geral"
      itemBuilder: (context, index) {
        if (index == 0) {
          final isSelected = _selectedProjectId == null;
          return _buildListItem(
            title: 'Resumo Geral',
            icon: Icons.dashboard,
            isSelected: isSelected,
            isDesktop: isDesktop,
            onTap: () {
              if (isDesktop) {
                setState(() => _selectedProjectId = null);
              } else {
                _navigateToMobileDetails(context, null, projects);
              }
            },
          );
        }

        final project = projects[index - 1];
        final isSelected = _selectedProjectId == project.id;
        return _buildListItem(
          title: project.projectName,
          icon: Icons.folder,
          isSelected: isSelected,
          isDesktop: isDesktop,
          onTap: () {
            if (isDesktop) {
              setState(() => _selectedProjectId = project.id);
            } else {
              _navigateToMobileDetails(context, project.id, projects);
            }
          },
        );
      },
    );
  }

  Widget _buildListItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDesktop,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      color: isSelected && isDesktop
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
          : null,
      shape: RoundedRectangleBorder(
        side: isSelected && isDesktop
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : const BorderSide(color: Colors.transparent, width: 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: isSelected && isDesktop ? Theme.of(context).colorScheme.primary : null),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected && isDesktop ? FontWeight.bold : FontWeight.normal,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isDesktop) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(List<dynamic> completedProjects) {
    if (_selectedProjectId == null) {
      return GeneralReportPanel(completedProjects: completedProjects.cast());
    }

    final matchingProjects = completedProjects.where((p) => p.id == _selectedProjectId);
    final project = matchingProjects.isEmpty ? null : matchingProjects.first;

    if (project == null) {
      return const Center(child: Text('Projeto não encontrado.'));
    }

    return ProjectReportPanel(project: project);
  }

  void _navigateToMobileDetails(BuildContext context, String? projectId, List<dynamic> completedProjects) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          Widget body;
          String title;

          if (projectId == null) {
            title = 'Resumo Geral';
            body = GeneralReportPanel(completedProjects: completedProjects.cast());
          } else {
            final matchingProjects = completedProjects.where((p) => p.id == projectId);
            final project = matchingProjects.isEmpty ? null : matchingProjects.first;
            if (project == null) {
              body = const Center(child: Text('Projeto não encontrado.'));
              title = 'Erro';
            } else {
              title = project.projectName;
              body = ProjectReportPanel(project: project);
            }
          }

          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: body,
          );
        },
      ),
    );
  }
}
