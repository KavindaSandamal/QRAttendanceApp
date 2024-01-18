import 'package:cloud_firestore/cloud_firestore.dart';

class Modules {
  String id;
  String moduleName;
  String moduleCode;
  String semester;
  String lecturerId;
  String lecturerName;

  Modules({
    required this.id,
    required this.moduleName,
    required this.moduleCode,
    required this.semester,
    required this.lecturerId,
    required this.lecturerName,
  });

  // Factory constructor to create a Modules instance from a Firestore document
  factory Modules.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Modules(
      id: doc.id,
      moduleName: data['moduleName'] ?? '',
      moduleCode: data['moduleCode'] ?? '',
      lecturerId: data['lecturerId'] ?? '',
      semester: data['semester'] ?? '',
      lecturerName: data['lecturerName'] ?? '',
    );
  }
}
