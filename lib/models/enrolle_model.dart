import 'package:cloud_firestore/cloud_firestore.dart';

class Enrolles {
  String id;
  String moduleName;
  String moduleCode;
  String moduleId;
  String studentId;

  Enrolles({
    required this.id,
    required this.moduleName,
    required this.moduleCode,
    required this.moduleId,
    required this.studentId,
  });

  // Factory constructor to create a Modules instance from a Firestore document
  factory Enrolles.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Enrolles(
      id: doc.id,
      moduleName: data['moduleName'] ?? '',
      moduleCode: data['moduleCode'] ?? '',
      moduleId: data['moduleId'] ?? '',
      studentId: data['studentId'] ?? '',
    );
  }
}
