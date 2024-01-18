import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
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

  // Function to fetch modules in the selected semester
  Future<List<Map<String, dynamic>>> _fetchModulesInSemester(
      String semester) async {
    // Replace 'Modules' with your actual collection name
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

  // Function to handle enrollment
  Future<void> _enrollModule(
    String moduleId,
    String moduleName,
    String moduleCode,
  ) async {
    // Replace 'Enrolles' with your actual collection name
    CollectionReference enrollesCollection =
        FirebaseFirestore.instance.collection('Enrolles');

    // Get the current user ID
    String? studentId = FirebaseAuth.instance.currentUser?.uid;

    if (studentId != null) {
      await enrollesCollection.add({
        'moduleId': moduleId, // Save moduleId along with other details
        'moduleName': moduleName,
        'moduleCode': moduleCode,
        'studentId': studentId,
      });

      // You can add more logic here if needed

      // Show AlertDialog to inform the user about the successful enrollment
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
                  Navigator.pop(context); // Close the AlertDialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle the case where the user is not authenticated
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
                    // Call the function to enroll in the selected module
                    // Pass the selected module's ID, name, and code to the function
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF2962FF),
          title: Text(
            'Enrolle in module',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true, // Center the title horizontally
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Semester:'),
            Expanded(
              child: ListView.builder(
                itemCount: semesters.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(semesters[index]),
                    onTap: () async {
                      setState(() {
                        selectedSemester = semesters[index];
                      });

                      List<
                          Map<String,
                              dynamic>> modules = await _fetchModulesInSemester(
                          selectedSemester); // Fetch modules when semester changes
                      _showModulesPopup(modules); // Show modules in a popup
                    },
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
