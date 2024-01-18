import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/screens/login_page.dart';
import 'package:qrattendanceapp/screens/more_page.dart';
import 'package:qrattendanceapp/screens/nottification_page.dart';
import 'package:qrattendanceapp/screens/profile.dart';
import 'package:qrattendanceapp/screens/qr_code_screen.dart';
import 'package:qrattendanceapp/screens/student_modules.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
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
                  SizedBox(width: 8.0), // Reduced SizedBox width
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: Center(
        child: _buildPage(_currentIndex),
      ),
      floatingActionButton: ClipOval(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QrCodeScreen(),
              ),
            );
          },
          child: Icon(Icons.qr_code, color: Colors.white),
          backgroundColor: Color(0xFF2196F3),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0, // Set elevation to 0.0
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
      color: Color(0xFFEEEEEE),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your Recent Lectures',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchRecentLectures(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error fetching lectures: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No recent lectures available.');
              } else {
                // Display the list of recent lectures
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          title: Text(
                            snapshot.data![index]['moduleName'] ?? 'No Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Module Code: ${snapshot.data![index]['moduleCode'] ?? 'No Code'}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Date: ${snapshot.data![index]['lectureDate'] ?? 'No Date'}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Time: ${snapshot.data![index]['lectureTime'] ?? 'No Time'}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Place: ${snapshot.data![index]['lecturePlace'] ?? 'No Place'}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Handle lecture tap
                          },
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRecentLectures() async {
    try {
      // Replace 'Enrolles' with your actual collection name
      CollectionReference enrollesCollection =
          FirebaseFirestore.instance.collection('Enrolles');

      String? studentId = FirebaseAuth.instance.currentUser?.uid;

      // Step 1: Fetch the enrolled modules
      QuerySnapshot enrolledModulesSnapshot = await enrollesCollection
          .where('studentId', isEqualTo: studentId)
          .get();

      List<String> enrolledModuleIds = enrolledModulesSnapshot.docs
          .map((enrolledModule) => enrolledModule['moduleId'].toString())
          .toList();

      // Replace 'Lectures' with your actual collection name
      CollectionReference lecturesCollection =
          FirebaseFirestore.instance.collection('Lectures');

      /// Step 2: Fetch lectures for each enrolled module
      List<Map<String, dynamic>> recentLectures = [];

      for (String moduleId in enrolledModuleIds) {
        QuerySnapshot lecturesSnapshot = await lecturesCollection
            .where('moduleId', isEqualTo: moduleId)
            .get();

        // Use if statement to ensure only one lecture is added
        if (lecturesSnapshot.docs.isNotEmpty) {
          var lecture = lecturesSnapshot.docs.first;
          recentLectures.add({
            'lectureDate': lecture['date'],
            'lectureTime': lecture['time'],
            'lecturePlace': lecture['place'],
            'moduleName': lecture['moduleName'],
            // You can add other fields as needed
          });
        }
      }

      return recentLectures;
    } catch (error) {
      print('Error fetching recent lectures: $error');
      return [];
    }
  }

  Widget _buildPage(int index) {
    Widget page;

    switch (index) {
      case 0:
        page = _buildHomePage();
        break;
      case 1:
        page = StudentModulesPage(); // Navigate to student_modules page
        break;
      case 2:
        page = NotificationPage();
        break;
      case 3:
        page = MorePage();
        break;
      default:
        page = Container();
    }

    return page;
  }
}
