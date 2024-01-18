import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinalAttendance extends StatelessWidget {
  final String moduleId;

  FinalAttendance({required this.moduleId});

  @override
  Widget build(BuildContext context) {
    print('Module ID: $moduleId');

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: Color(0xFF03A9F4),
            title: Text(
              'Module Attendance Details',
              style: TextStyle(color: Colors.white, fontSize: 25.0),
            ),
            centerTitle: true,
          ),
        ),
        body: FutureBuilder<DataTable>(
          future: _buildDataTable(moduleId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Error building DataTable: ${snapshot.error}');
              return Center(child: Text('Error building DataTable'));
            } else {
              return snapshot.data ?? Container();
            }
          },
        ));
  }

  Future<DataTable> _buildDataTable(String moduleId) async {
    List<Map<String, dynamic>> studentDetails =
        await _fetchEnrolledStudentsDetails(moduleId);

    List<DataColumn> dateColumns = await _buildDateColumns(moduleId);
    List<String> lectureIds = await _fetchLectureIds(moduleId);

    return DataTable(
      columns: [
        DataColumn(label: Text('Student Names')),
        ...dateColumns,
      ],
      rows: studentDetails.map<DataRow>((studentData) {
        return DataRow(
          cells: [
            DataCell(Text(studentData['fullname'])),
            ..._buildAttendanceCells(studentData['id'], lectureIds),
          ],
        );
      }).toList(),
    );
  }

  Future<List<DataColumn>> _buildDateColumns(String moduleId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> lecturesSnapshot =
          await FirebaseFirestore.instance
              .collection('Lectures')
              .where('moduleId', isEqualTo: moduleId)
              .get();

      List<DataColumn> dateColumns = lecturesSnapshot.docs.map((doc) {
        String date = doc['date'] ?? '';
        return DataColumn(label: Text('$date'));
      }).toList();

      return dateColumns;
    } catch (e) {
      print('Error fetching lecture dates: $e');
      return [];
    }
  }

  Future<List<String>> _fetchLectureIds(String moduleId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> lecturesSnapshot =
          await FirebaseFirestore.instance
              .collection('Lectures')
              .where('moduleId', isEqualTo: moduleId)
              .get();

      List<String> lectureIds =
          lecturesSnapshot.docs.map((doc) => doc.id).toList();

      return lectureIds;
    } catch (e) {
      print('Error fetching lecture IDs: $e');
      return [];
    }
  }

  List<DataCell> _buildAttendanceCells(
      String studentId, List<String> lectureIds) {
    return [
      for (String lectureId in lectureIds)
        DataCell(FutureBuilder<String>(
          future: _fetchAttendanceStatus(studentId, lectureId),
          builder: (context, attendanceSnapshot) {
            if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (attendanceSnapshot.hasError) {
              return Text('Error');
            } else {
              String attendanceStatus = attendanceSnapshot.data ?? 'N/A';

              IconData icon = attendanceStatus == 'Present'
                  ? Icons.check_circle
                  : attendanceStatus == 'Absent'
                      ? Icons.cancel
                      : Icons.error;
              Color iconColor = attendanceStatus == 'Present'
                  ? Colors.blue
                  : attendanceStatus == 'Absent'
                      ? Colors.red
                      : Colors.grey;
              return Icon(
                icon,
                color: iconColor,
              );
            }
          },
        )),
    ];
  }

  Future<String> _fetchAttendanceStatus(
      String studentId, String lectureId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> attendanceSnapshot =
          await FirebaseFirestore.instance
              .collection('Attendance')
              .where('studentId', isEqualTo: studentId)
              .where('lectureId', isEqualTo: lectureId)
              .get();

      return attendanceSnapshot.docs.isNotEmpty ? 'Present' : 'Absent';
    } catch (e) {
      print('Error fetching attendance status: $e');
      return 'N/A';
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEnrolledStudentsDetails(
      String moduleId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> enrolledSnapshot =
          await FirebaseFirestore.instance
              .collection('Enrolles')
              .where('moduleId', isEqualTo: moduleId)
              .get();

      List<String> enrolledStudentIds = enrolledSnapshot.docs
          .map((doc) => doc['studentId'] as String)
          .toList();

      List<Future<Map<String, dynamic>>> futures =
          enrolledStudentIds.map((studentId) async {
        Map<String, dynamic> studentDetails =
            await _fetchStudentDetails(studentId);

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
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(studentId)
              .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() ?? {};

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
