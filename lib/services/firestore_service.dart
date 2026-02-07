import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirestoreService {
  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');

  Future<void> create(Student student) async {
    await studentsCollection.add(student.toMap());
  }

  Future<List<Student>> readAll() async {
    final snapshot = await studentsCollection.get();
    return snapshot.docs.map((doc) {
      return Student.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<void> update(Student student) async {
    await studentsCollection.doc(student.id).update(student.toMap());
  }

  Future<void> delete(String id) async {
    await studentsCollection.doc(id).delete();
  }

  Stream<List<Student>> getStudents() {
    return studentsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }
}
