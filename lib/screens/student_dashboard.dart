import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/screens/login_page.dart';
import 'package:qrattendanceapp/screens/more_page.dart';
import 'package:qrattendanceapp/screens/nottification_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
            backgroundColor: Color(0xFF03A9F4),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
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
      ),
    );
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
            color: Colors.black,
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
          color: _currentIndex == index ? Colors.blue : Color(0xFF90CAF9),
        ),
        onPressed: () {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomePage() {
    return Container(
      color: Color.fromARGB(255, 255, 255, 255), // Light blue background color
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16.0),
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'Your Recent '),
                TextSpan(
                  text: 'Lectures',
                  style: TextStyle(
                    color: Color(0xFF2962FF), // Set your preferred color
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchRecentLectures(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No recent lectures available.');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        color: Color(0xFFB3E5FC), // Card background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                            snapshot.data![index]['moduleName'] ?? 'No Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Color(0xFF2962FF), // Text color
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${snapshot.data![index]['lectureDate'] ?? 'No Date'}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Time: ${snapshot.data![index]['lectureTime'] ?? 'No Time'}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Place: ${snapshot.data![index]['lecturePlace'] ?? 'No Place'}',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          onTap: () {},
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRecentLectures() async {
    try {
      CollectionReference enrollesCollection =
          FirebaseFirestore.instance.collection('Enrolles');

      String? studentId = FirebaseAuth.instance.currentUser?.uid;

      QuerySnapshot enrolledModulesSnapshot = await enrollesCollection
          .where('studentId', isEqualTo: studentId)
          .get();

      List<String> enrolledModuleIds = enrolledModulesSnapshot.docs
          .map((enrolledModule) => enrolledModule['moduleId'].toString())
          .toList();

      CollectionReference lecturesCollection =
          FirebaseFirestore.instance.collection('Lectures');

      List<Map<String, dynamic>> recentLectures = [];

      for (String moduleId in enrolledModuleIds) {
        QuerySnapshot lecturesSnapshot = await lecturesCollection
            .where('moduleId', isEqualTo: moduleId)
            .get();

        if (lecturesSnapshot.docs.isNotEmpty) {
          var lecture = lecturesSnapshot.docs.first;
          recentLectures.add({
            'lectureDate': lecture['date'],
            'lectureTime': lecture['time'],
            'lecturePlace': lecture['place'],
            'moduleName': lecture['moduleName'],
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
        page = StudentModulesPage();
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
