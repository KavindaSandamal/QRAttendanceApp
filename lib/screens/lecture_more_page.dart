import 'package:flutter/material.dart';
import 'package:qrattendanceapp/screens/login_page.dart';
import 'package:qrattendanceapp/screens/profile_details.dart';
import 'package:qrattendanceapp/screens/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LectureMorePage extends StatelessWidget {
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
            // Navigate to ProfileDetails page
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

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context); // Close the More page after logout
      // Navigate to the login or home page as needed
      // You can replace MaterialPageRoute with the appropriate page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error logging out: $e');
      // Handle logout error
      // Show a message or navigate to an error page as needed
    }
  }
}
