import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/fees.dart';

class FirestoreService {
  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');
  final CollectionReference feesCollection =
      FirebaseFirestore.instance.collection('fees');
  final CollectionReference discountsCollection =
      FirebaseFirestore.instance.collection('discounts');

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

  // Fees CRUD methods
  Future<void> createFees(Fees fee) async {
    await feesCollection.add(fee.toMap());
  }

  Future<List<Fees>> readAllFees() async {
    final snapshot = await feesCollection.get();
    return snapshot.docs.map((doc) {
      return Fees.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<void> updateFees(Fees fee) async {
    await feesCollection.doc(fee.id).update(fee.toMap());
  }

  Future<void> deleteFees(String id) async {
    await feesCollection.doc(id).delete();
  }

  Stream<List<Fees>> getFees() {
    return feesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Fees.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // Discounts CRUD methods
  Future<void> createDiscount(Discount discount) async {
    await discountsCollection.add(discount.toMap());
  }

  Future<List<Discount>> readAllDiscounts() async {
    final snapshot = await discountsCollection.get();
    return snapshot.docs.map((doc) {
      return Discount.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<void> updateDiscount(Discount discount) async {
    await discountsCollection.doc(discount.id).update(discount.toMap());
  }

  Future<void> deleteDiscount(String id) async {
    await discountsCollection.doc(id).delete();
  }

  Stream<List<Discount>> getDiscounts() {
    return discountsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Discount.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }
}
