import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String studentId;
  final String lectureId;
  final Timestamp timestamp;

  Attendance({
    required this.id,
    required this.studentId,
    required this.lectureId,
    required this.timestamp,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      studentId: map['studentId'],
      lectureId: map['lectureId'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'lectureId': lectureId,
      'timestamp': timestamp,
    };
  }
}
