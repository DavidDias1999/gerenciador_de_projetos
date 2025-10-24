import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gerenciador_de_projetos/data/repositories/auth_repository.dart';
import 'package:gerenciador_de_projetos/data/templates/project_template.dart';
import '../../domain/models/project_model.dart' as domain;
// Certifique-se que Step está importado se createDefaultSteps retornar domain.Step
import '../../domain/models/step_model.dart' as domain;

class ProjectService {
  final FirebaseFirestore _firestore;
  final AuthRepository _auth;
  late final CollectionReference _projectsCollection;

  ProjectService({
    required FirebaseFirestore firestore,
    required AuthRepository auth,
  })  : _firestore = firestore,
        _auth = auth {
    _projectsCollection = _firestore.collection('projects');
  }

  /// Obtém o ID do usuário logado (ainda útil para saber QUEM está logado).
  String? get _userId => _auth.getLoggedInUser()?.id;

  /// **[MODIFICADO]** Retorna um Stream de projetos para real-time.
  Stream<List<domain.Project>> getProjectsStream() {
    if (_userId == null) throw Exception('Usuário não autenticado.');

    // .snapshots() escuta mudanças em tempo real
    return _projectsCollection.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return <domain.Project>[];
      }

      // Mapeia os documentos para os modelos de domínio
      return snapshot.docs.map((doc) {
        try {
          return domain.Project.fromJson(doc.data() as Map<String, dynamic>);
        } catch (e) {
          print("Erro ao desserializar projeto ${doc.id}: $e");
          print("Dados do documento: ${doc.data()}");
          rethrow;
        }
      }).toList();
    });
  }

  /// Cria um novo projeto (ainda associa o ID do CRIADOR).
  Future<void> createNewProject(String projectName) async {
    final creatorId = _userId; // Pega o ID de quem está criando
    if (creatorId == null) throw Exception('Usuário não autenticado.');

    final newProjectId = _projectsCollection.doc().id;
    final defaultSteps = await createDefaultSteps();

    final newProject = domain.Project(
      id: newProjectId,
      projectName: projectName,
      steps: defaultSteps,
      isCompleted: false,
      userId: creatorId, // Salva o ID do criador
    );

    // Ao usar .set(), o .snapshots() acima será notificado automaticamente.
    await _projectsCollection.doc(newProjectId).set(newProject.toJson());
  }

  /// Atualiza o status de um projeto (ativo/finalizado).
  Future<void> setProjectStatus(String projectId, bool isCompleted) async {
    await _projectsCollection
        .doc(projectId)
        .update({'isCompleted': isCompleted});
  }

  /// Deleta um projeto permanentemente.
  Future<void> deleteProject(String projectId) async {
    await _projectsCollection.doc(projectId).delete();
  }

  /// Salva o estado completo de um objeto de projeto.
  Future<void> updateProject(domain.Project project) async {
    // O 'userId' (do criador) já está no objeto 'project', então toJson() o incluirá.
    await _projectsCollection.doc(project.id).update(project.toJson());
  }
}
