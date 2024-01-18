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

  // Function to fetch the full name of the current user
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

  // Function to build the app bar
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0),
      child: AppBar(
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
              return Text('Welcome', style: TextStyle(color: Colors.black));
            } else if (snapshot.hasError) {
              return Text('Error fetching full name',
                  style: TextStyle(color: Colors.black));
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
                            color: Colors.black,
                            fontSize: 23.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        fullName,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
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
            onPressed: () {
              // Add your notification button logic here
              // For example, you can show a notification dialog or navigate to a notification page.
            },
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
      floatingActionButton: ClipOval(
          /*child: FloatingActionButton(
          onPressed: () async {
            // Replace this with your logic to fetch or generate module IDs
            List<String> moduleIds = await fetchModuleIds();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GenerateQrCode(moduleIds: moduleIds),
              ),
            );
          },
          child: Icon(Icons.qr_code, color: Colors.white),
          backgroundColor: Color(0xFF2196F3),
        ),*/
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  // Function to build the individual navigation bar item
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

  // Function to build the home page
  Widget _buildHomePage() {
    return Container(
      color: Color(0xFFEEEEEE),
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

                      // Check if 'title' is not null before casting
                      String title = lectureData['moduleName'] ?? 'N/A';

                      // Check if 'dateTime' is not null before casting
                      Timestamp? timestamp = lectureData['dateTime'];
                      DateTime lectureDateTime =
                          timestamp?.toDate() ?? DateTime.now();

                      return Card(
                        elevation: 5.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${lectureData['date'] ?? 'N/A'}'),
                              Text('Time: ${lectureData['time'] ?? 'N/A'}'),
                              Text(
                                  'Location: ${lectureData['place'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing:
                              Icon(Icons.arrow_forward_ios), // Add arrow icon
                          onTap: () {
                            // Navigate to ModuleAttendanceDetailsScreen with both moduleId and lectureId
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

  // Function to determine which page to display based on the selected index
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
