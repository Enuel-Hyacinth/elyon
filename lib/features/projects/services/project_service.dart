import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProject(ProjectModel project) async {
    await _firestore
        .collection("projects")
        .add(project.toMap());
  }
}