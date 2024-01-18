import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/screens/enrollement_form.dart';

class StudentModulesPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchEnrolledModules() async {
    CollectionReference enrollesCollection =
        FirebaseFirestore.instance.collection('Enrolles');

    String? studentId = FirebaseAuth.instance.currentUser?.uid;

    if (studentId != null) {
      QuerySnapshot enrollesSnapshot = await enrollesCollection
          .where('studentId', isEqualTo: studentId)
          .get();

      List<Map<String, dynamic>> enrolledModules = enrollesSnapshot.docs
          .map((doc) => {
                'moduleName': doc['moduleName'].toString(),
                // Add other module details here if needed
              })
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
          centerTitle: true,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEnrolledModules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching enrolled modules'));
          } else {
            List<Map<String, dynamic>> enrolledModules = snapshot.data ?? [];

            return Column(
              children: [
                Expanded(
                  child: enrolledModules.isEmpty
                      ? Center(child: Text('No enrolled modules.'))
                      : ListView.builder(
                          itemCount: enrolledModules.length,
                          itemBuilder: (context, index) {
                            return _buildModuleCard(enrolledModules[index]);
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnrollmentFormPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Color(0xFF2196F3), width: 2.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                    ),
                    child: Text(
                      'Enroll in New Module',
                      style: TextStyle(
                        color: Color(0xFF2196F3), // Border color
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Color(0xFF90CAF9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          module['moduleName'] ?? 'No Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Color(0xFF2962FF),
          ),
        ),
        // You can add other module details here if needed
      ),
    );
  }
}
