// student_modules.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/screens/enrollement_form.dart';

class StudentModulesPage extends StatelessWidget {
  // Function to fetch enrolled modules for the current user
  Future<List<String>> _fetchEnrolledModules() async {
    // Replace 'Enrolles' with your actual collection name
    CollectionReference enrollesCollection =
        FirebaseFirestore.instance.collection('Enrolles');

    // Get the current user ID
    String? studentId = FirebaseAuth.instance.currentUser?.uid;

    if (studentId != null) {
      QuerySnapshot enrollesSnapshot = await enrollesCollection
          .where('studentId', isEqualTo: studentId)
          .get();

      // Extract module names from the snapshot
      List<String> enrolledModules = enrollesSnapshot.docs
          .map((doc) => doc['moduleName'].toString())
          .toList();

      return enrolledModules;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF2962FF),
          title: Text(
            'Modules',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true, // Center the title horizontally
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchEnrolledModules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching enrolled modules'));
          } else {
            List<String> enrolledModules = snapshot.data ?? [];

            return Column(
              children: [
                // Display Enrolled Modules
                Expanded(
                  child: enrolledModules.isEmpty
                      ? Center(
                          child: Text('No enrolled modules.'),
                        )
                      : ListView.builder(
                          itemCount: enrolledModules.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(enrolledModules[index]),
                              // Add any other information about the module here
                            );
                          },
                        ),
                ),
                // Button to Enroll in New Module
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the enrollment form page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnrollmentFormPage(),
                        ),
                      );
                    },
                    child: Text('Enroll in New Module'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
