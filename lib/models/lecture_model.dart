import 'package:cloud_firestore/cloud_firestore.dart';

class Lecture {
  final String id;
  final String lecturerId; // Add this line
  final String moduleId;
  final String moduleName;
  final String date;
  final String time;
  final String place;

  Lecture({
    required this.id,
    required this.lecturerId, // Add this line
    required this.moduleId,
    required this.moduleName,
    required this.date,
    required this.time,
    required this.place,
  });

  // Add other constructors or methods if needed

  // Factory method to create a Lecture instance from Firestore data
  factory Lecture.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Lecture(
      id: doc.id,
      lecturerId: data['lecturerId'] ?? '', // Add this line
      moduleId: data['moduleId'] ?? '',
      moduleName: data['moduleName'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      place: data['place'] ?? '',
    );
  }
}
