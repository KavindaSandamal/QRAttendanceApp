import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/screens/generate_qr_code.dart';
import 'package:qrattendanceapp/screens/lecture_details_screen.dart';
import 'package:qrattendanceapp/screens/lecture_more_page.dart';
import 'package:qrattendanceapp/screens/lecturer_modules.dart';
import 'package:qrattendanceapp/screens/login_page.dart';
import 'package:qrattendanceapp/screens/module_attendance_details.dart';
import 'package:qrattendanceapp/screens/more_page.dart';
import 'package:qrattendanceapp/screens/nottification_page.dart';
import 'package:qrattendanceapp/screens/profile.dart';
import 'package:qrattendanceapp/screens/qr_code_screen.dart';
import 'package:qrattendanceapp/screens/student_modules.dart';

class LecturerDashboard extends StatefulWidget {
  @override
  _LecturerDashboardState createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;

  Future<String?> _fetchFullName(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      return userSnapshot['fullname'];
    } catch (e) {
      print('Error fetching fullName: $e');
      return null;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0),
      child: AppBar(
        backgroundColor: Color(0xFF03A9F4),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: FutureBuilder<String?>(
          future: _fetchFullName(currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Welcome', style: TextStyle(color: Colors.white));
            } else if (snapshot.hasError) {
              return Text('Error fetching full name',
                  style: TextStyle(color: Colors.white));
            } else {
              String fullName = snapshot.data ?? 'N/A';
              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: AssetImage('lib/assets/profile.png'),
                      radius: 20.0,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 23.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        fullName,
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Function to fetch module IDs from the Firestore collection
  Future<List<String>> fetchModuleIds() async {
    try {
      QuerySnapshot lecturesSnapshot = await FirebaseFirestore.instance
          .collection('Lectures')
          .where('lecturerId', isEqualTo: currentUser!.uid)
          .get();

      List<String> moduleIds = lecturesSnapshot.docs
          .map((doc) => doc['moduleId'].toString())
          .toList();

      return moduleIds;
    } catch (e) {
      print('Error fetching module IDs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: Center(
        child: _buildPage(_currentIndex),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(Icons.home, 0),
            _buildNavBarItem(Icons.receipt, 1),
            _buildNavBarItem(Icons.notifications, 2),
            _buildNavBarItem(Icons.more_horiz, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                _currentIndex == index ? Color(0xFF2196F3) : Colors.transparent,
            width: 1.0,
          ),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: _currentIndex == index ? Color(0xFF2196F3) : Color(0xFF64B5F6),
        ),
        onPressed: () {
          setState(() {
            _currentIndex = index;
          });
        },
        splashColor: Colors.transparent,
      ),
    );
  }

  Widget _buildHomePage() {
    return Container(
      color: Color.fromARGB(255, 255, 255, 255),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: FutureBuilder<List<String>>(
        future: fetchModuleIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error fetching modules: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No modules available.');
          } else {
            List<String> moduleIds = snapshot.data!;
            return ListView.builder(
              itemCount: moduleIds.length,
              itemBuilder: (context, index) {
                String moduleId = moduleIds[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Lectures')
                      .where('moduleId', isEqualTo: moduleId)
                      .get()
                      .then((value) => value.docs.first),
                  builder: (context, lectureSnapshot) {
                    if (lectureSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (lectureSnapshot.hasError) {
                      return Text('Error fetching lecture details');
                    } else {
                      Map<String, dynamic> lectureData =
                          lectureSnapshot.data!.data() as Map<String, dynamic>;

                      String title = lectureData['moduleName'] ?? 'N/A';

                      Timestamp? timestamp = lectureData['dateTime'];
                      DateTime lectureDateTime =
                          timestamp?.toDate() ?? DateTime.now();

                      return Card(
                        elevation: 5.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        color: Color(0xFF90CAF9),
                        child: ListTile(
                          title: Text(
                            title,
                            style: TextStyle(
                                color: Color(0xFF2962FF),
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${lectureData['date'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Time: ${lectureData['time'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Location: ${lectureData['place'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ModuleAttendanceDetailsScreen(
                                  moduleId: moduleId,
                                  lectureId: lectureSnapshot.data!.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    Widget page;

    switch (index) {
      case 0:
        page = _buildHomePage();
        break;
      case 1:
        page = LecturerModules();
        break;
      case 2:
        page = LectureDetailsScreen();
        break;
      case 3:
        page = LectureMorePage();
        break;
      default:
        page = Container();
    }

    return page;
  }
}
