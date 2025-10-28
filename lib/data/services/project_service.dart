import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gerenciador_de_projetos/data/repositories/auth_repository.dart';
import 'package:gerenciador_de_projetos/data/templates/project_template.dart';
import '../../domain/models/project_model.dart' as domain;

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

  String? get _userId => _auth.getLoggedInUser()?.id;

  Stream<List<domain.Project>> getProjectsStream() {
    if (_userId == null) throw Exception('Usuário não autenticado.');

    return _projectsCollection.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return <domain.Project>[];
      }

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

  Future<void> createNewProject(
      String projectName, double? squareMeters) async {
    final creatorId = _userId;
    if (creatorId == null) throw Exception('Usuário não autenticado.');

    final newProjectId = _projectsCollection.doc().id;
    final defaultSteps = await createDefaultSteps();

    final newProject = domain.Project(
      id: newProjectId,
      projectName: projectName,
      steps: defaultSteps,
      isCompleted: false,
      userId: creatorId,
      squareMeters: squareMeters,
      complexity: null,
    );

    await _projectsCollection.doc(newProjectId).set(newProject.toJson());
  }

  Future<void> setProjectStatus(String projectId, bool isCompleted) async {
    await _projectsCollection
        .doc(projectId)
        .update({'isCompleted': isCompleted});
  }

  Future<void> deleteProject(String projectId) async {
    await _projectsCollection.doc(projectId).delete();
  }

  Future<void> updateProject(domain.Project project) async {
    await _projectsCollection.doc(project.id).update(project.toJson());
  }
}
