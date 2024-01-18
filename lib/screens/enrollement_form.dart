import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/models/enrolle_model.dart';

class EnrollmentFormPage extends StatefulWidget {
  @override
  _EnrollmentFormPageState createState() => _EnrollmentFormPageState();
}

class _EnrollmentFormPageState extends State<EnrollmentFormPage> {
  String selectedSemester = '';
  List<Map<String, dynamic>> modulesInSemester = [];
  List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8'
  ];

  Future<List<Map<String, dynamic>>> _fetchModulesInSemester(
      String semester) async {
    CollectionReference modulesCollection =
        FirebaseFirestore.instance.collection('Modules');

    try {
      QuerySnapshot moduleSnapshot =
          await modulesCollection.where('semester', isEqualTo: semester).get();

      return moduleSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'moduleName': doc['moduleName'],
                'moduleCode': doc['moduleCode'],
              })
          .toList();
    } catch (error) {
      print('Error fetching modules: $error');
      return [];
    }
  }

  Future<void> _enrollModule(
    String moduleId,
    String moduleName,
    String moduleCode,
  ) async {
    CollectionReference enrollesCollection =
        FirebaseFirestore.instance.collection('Enrolles');

    // Get the current user ID
    String? studentId = FirebaseAuth.instance.currentUser?.uid;

    if (studentId != null) {
      await enrollesCollection.add({
        'moduleId': moduleId,
        'moduleName': moduleName,
        'moduleCode': moduleCode,
        'studentId': studentId,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enrollment Successful'),
            content: Text(
                'You have successfully enrolled in $moduleName - $moduleCode.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      print('User not authenticated');
    }
  }

  // Function to show the modules in a popup
  void _showModulesPopup(List<Map<String, dynamic>> modules) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modules in $selectedSemester:'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      '${modules[index]['moduleName']} - ${modules[index]['moduleCode']}'),
                  onTap: () {
                    _enrollModule(
                      modules[index]['id'],
                      modules[index]['moduleName'],
                      modules[index]['moduleCode'],
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03A9F4),
        title: Text(
          'Enroll in Module',
          style: TextStyle(color: Colors.white, fontSize: 25.0),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Semester:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: semesters.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3.0,
                    color: Color(0xFFB3E5FC),
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(semesters[index]),
                      onTap: () async {
                        setState(() {
                          selectedSemester = semesters[index];
                        });

                        List<Map<String, dynamic>> modules =
                            await _fetchModulesInSemester(selectedSemester);
                        _showModulesPopup(modules);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
