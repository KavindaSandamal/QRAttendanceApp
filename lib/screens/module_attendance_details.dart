import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleAttendanceDetailsScreen extends StatelessWidget {
  final String moduleId;
  final String lectureId;

  ModuleAttendanceDetailsScreen({
    required this.moduleId,
    required this.lectureId,
  });

  @override
  Widget build(BuildContext context) {
    print('Module ID: $moduleId');
    print('Lecture ID: $lectureId');
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF2962FF),
          title: Text(
            'Module Attendance',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true,
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Enrolles')
            .where('moduleId', isEqualTo: moduleId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching module details'));
          } else {
            List<String> enrolledStudentIds = [];

            for (QueryDocumentSnapshot<Map<String, dynamic>> doc
                in snapshot.data?.docs ?? []) {
              String studentId = doc['studentId'];
              enrolledStudentIds.add(studentId);
            }

            if (enrolledStudentIds.isNotEmpty) {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchEnrolledStudentsDetails(enrolledStudentIds),
                builder: (context, studentDetailsSnapshot) {
                  if (studentDetailsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (studentDetailsSnapshot.hasError) {
                    return Center(
                        child: Text('Error fetching student details'));
                  } else {
                    List<Map<String, dynamic>> studentDetails =
                        studentDetailsSnapshot.data ?? [];

                    return Column(
                      children: [
                        DataTable(
                          columns: [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Reg No')),
                            DataColumn(label: Text('Attendance')),
                          ],
                          rows: studentDetails.map<DataRow>((studentData) {
                            bool hasSubmitted =
                                studentData['attendanceStatus'] == 'Submitted';

                            return DataRow(
                              cells: [
                                DataCell(Text(studentData['fullname'])),
                                DataCell(Text(studentData['regNo'])),
                                DataCell(
                                  hasSubmitted
                                      ? Icon(Icons.check_circle,
                                          color: Colors.blue)
                                      : Icon(Icons.cancel, color: Colors.red),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Total Attendance: ${_getSubmittedStudentsCount(studentDetails)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            } else {
              return Center(
                  child: Text('No enrolled students for this lecture'));
            }
          }
        },
      ),
    );
  }

  int _getSubmittedStudentsCount(List<Map<String, dynamic>> studentDetails) {
    return studentDetails
        .where((student) => student['attendanceStatus'] == 'Submitted')
        .length;
  }

  Future<List<Map<String, dynamic>>> _fetchEnrolledStudentsDetails(
      List<String> enrolledStudentIds) async {
    try {
      List<Future<Map<String, dynamic>>> futures =
          enrolledStudentIds.map((studentId) async {
        Map<String, dynamic> studentDetails =
            await _fetchStudentDetails(studentId);

        QuerySnapshot<Map<String, dynamic>> attendanceSnapshot =
            await FirebaseFirestore.instance
                .collection('Attendance')
                .where('studentId', isEqualTo: studentId)
                .where('lectureId', isEqualTo: lectureId)
                .get();

        if (attendanceSnapshot.docs.isNotEmpty) {
          studentDetails['attendanceStatus'] = 'Submitted';
        } else {
          studentDetails['attendanceStatus'] = 'Not Submitted';
        }

        return studentDetails;
      }).toList();

      return await Future.wait(futures);
    } catch (e) {
      print('Error fetching enrolled students details: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _fetchStudentDetails(String studentId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(studentId)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        return {
          'id': studentId,
          'fullname': userData['fullname'] ?? 'N/A',
          'regNo': userData['regNo'] ?? 'N/A',
        };
      } else {
        print('User not found in Firestore for ID: $studentId');
        return {'id': studentId, 'fullname': 'N/A', 'regNo': 'N/A'};
      }
    } catch (e) {
      print('Error fetching student details: $e');
      return {'id': studentId, 'fullname': 'N/A', 'regNo': 'N/A'};
    }
  }
}
