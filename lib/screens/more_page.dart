import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/screens/login_page.dart';
import 'package:qrattendanceapp/screens/profile_details.dart';
import 'package:qrattendanceapp/screens/settings_page.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF2962FF),
          title: Text(
            'More',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true, // Center the title horizontally
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildListTile(Icons.person, 'My Profile', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileDetails()),
            );
          }),
          SizedBox(height: 16.0),
          _buildListTile(Icons.calendar_today, 'Attendance', () {
            // Add your Attendance logic here
          }),
          SizedBox(height: 16.0),
          _buildListTile(Icons.settings, 'Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }),
          SizedBox(height: 16.0),
          _buildListTile(Icons.exit_to_app, 'Logout', () {
            _logout(context);
          }),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Close the current screen (More page)
      Navigator.pop(context);

      // Check if there are any existing routes before navigating
      if (Navigator.of(context).canPop()) {
        // Navigate to the login or home page as needed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        ); // Example: Navigate to login page
      } else {
        // If there are no existing routes, you might want to navigate to the login page directly
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
      // Handle logout error
      // Show a message or navigate to an error page as needed
    }
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF2962FF)),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF2962FF)),
        onTap: onTap,
      ),
    );
  }
}
