import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/models/modules_model.dart';
import 'package:qrattendanceapp/screens/final_attendance.dart';
import 'package:qrattendanceapp/screens/module_attendance_details.dart'; // Import the attendance details screen

class LecturerModules extends StatefulWidget {
  @override
  _LecturerModulesState createState() => _LecturerModulesState();
}

class _LecturerModulesState extends State<LecturerModules> {
  List<Modules>? modules;

  final CollectionReference modulesCollection =
      FirebaseFirestore.instance.collection('Modules');

  TextEditingController moduleNameController = TextEditingController();
  TextEditingController moduleCodeController = TextEditingController();
  String? selectedSemester;

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  Future<void> _fetchModules() async {
    String lecturerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      QuerySnapshot moduleSnapshot = await modulesCollection
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      // Check if the widget is still mounted before updating the state
      if (mounted) {
        setState(() {
          modules = moduleSnapshot.docs
              .map((doc) => Modules.fromFirestore(doc))
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching modules: $e');
    }
  }

  Future<void> _addModule(
      String moduleName, String moduleCode, String? semester) async {
    var docRef = await modulesCollection.add({
      'moduleName': moduleName,
      'moduleCode': moduleCode,
      'semester': semester ?? '',
      'lecturerId': FirebaseAuth.instance.currentUser?.uid,
      'lecturerName': 'ReplaceWithActualLecturerName',
    });

    String moduleId = docRef.id;

    setState(() {
      modules!.add(Modules(
        id: moduleId,
        moduleName: moduleName,
        moduleCode: moduleCode,
        semester: semester ?? '',
        lecturerId: FirebaseAuth.instance.currentUser?.uid ?? '',
        lecturerName: 'ReplaceWithActualLecturerName',
      ));
    });
  }

  Future<void> _deleteModule(String moduleId) async {
    await modulesCollection.doc(moduleId).delete();

    setState(() {
      modules!.removeWhere((module) => module.id == moduleId);
    });
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
      body: modules != null && modules!.isNotEmpty
          ? ListView.builder(
              itemCount: modules!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(modules![index].moduleName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(modules![index].moduleCode),
                          Text(modules![index].semester),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteModule(modules![index].id);
                        },
                      ),
                      onTap: () {
                        // Navigate to attendance details screen with moduleId and lectureId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FinalAttendance(
                              moduleId: modules![index].id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text('No modules available.'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddModuleDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF2196F3),
      ),
    );
  }

  Future<void> _showAddModuleDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Module'),
              content: Column(
                children: [
                  TextField(
                    controller: moduleNameController,
                    decoration: InputDecoration(labelText: 'Module Name'),
                  ),
                  TextField(
                    controller: moduleCodeController,
                    decoration: InputDecoration(labelText: 'Module Code'),
                  ),
                  DropdownButton<String>(
                    value: selectedSemester,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSemester = newValue;
                      });
                    },
                    items: <String>[
                      'Semester 1',
                      'Semester 2',
                      'Semester 3',
                      'Semester 4',
                      'Semester 5',
                      'Semester 6',
                      'Semester 7',
                      'Semester 8'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: Text('Select Semester'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String moduleName = moduleNameController.text.trim();
                    String moduleCode = moduleCodeController.text.trim();

                    if (moduleName.isNotEmpty &&
                        moduleCode.isNotEmpty &&
                        selectedSemester != null) {
                      _addModule(moduleName, moduleCode, selectedSemester);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
