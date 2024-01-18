import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDetails extends StatefulWidget {
  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> _fetchUserDetails(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      return userSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
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
            'My Profile',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true, // Center the title horizontally
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserDetails(currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching user details'));
            } else {
              Map<String, dynamic>? userDetails = snapshot.data;
              return userDetails != null
                  ? _buildProfileDetails(userDetails)
                  : Center(child: Text('User details not available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileDetails(Map<String, dynamic> userDetails) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 16.0),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF2962FF),
                    width: 8.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF82B1FF).withOpacity(1),
                      spreadRadius: 8,
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage('lib/assets/profile.png'),
                  radius: 50.0,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Add your edit profile picture logic here
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Full Name', userDetails['fullname'] ?? ''),
                  _buildField(
                      'Registration Number', userDetails['regNo'] ?? ''),
                  _buildField('Email', userDetails['email'] ?? ''),
                  // Add more fields as needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        Divider(height: 16.0, color: Colors.grey),
      ],
    );
  }
}
