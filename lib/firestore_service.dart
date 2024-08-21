import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'students';

  Future<void> addStudent(String name, int age) async {
    await _db.collection(collection).add({
      'name': name,
      'age': age,
    });
  }

  Future<void> updateStudent(String id, String name, int age) async {
    await _db.collection(collection).doc(id).update({
      'name': name,
      'age': age,
    });
  }

  Future<void> deleteStudent(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Stream<List<Student>> getStudents() {
    return _db.collection(collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Student.fromFirestore(doc.data(), doc.id)).toList());
  }

  Stream<List<Student>> searchStudents(String query) {
    return _db.collection(collection)
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThanOrEqualTo: query + '\uf8ff')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Student.fromFirestore(doc.data(), doc.id)).toList());
  }
}

class Student {
  final String id;
  final String name;
  final int age;

  Student({required this.id, required this.name, required this.age});

  factory Student.fromFirestore(Map<String, dynamic> firestore, String id) {
    return Student(
      id: id,
      name: firestore['name'],
      age: firestore['age'],
    );
  }
}
