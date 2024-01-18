import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('Calling _loadUserDetails...');
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      print('Current User: $user');

      if (user != null) {
        String uid = user.uid;
        print('UID: $uid');

        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('Users').doc(uid).get();

        if (userSnapshot.exists) {
          Map<String, dynamic>? userData =
              userSnapshot.data() as Map<String, dynamic>?;

          String? fullname = userData?['fullname'];
          String? email = userData?['email'];

          if (fullname != null) {
            _fullNameController.text = fullname;
          }

          if (email != null) {
            _emailController.text = email;
          }
        } else {
          print('User document does not exist in Firestore.');
        }
      } else {
        print('No current user.');
      }
    } catch (e) {
      print('Error loading user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF03A9F4),
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserDetailsForm(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _updateUserDetails();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(labelText: 'Full Name'),
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
      ],
    );
  }

  Future<void> _updateUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .update({
        'fullname': _fullNameController.text,
        'email': _emailController.text,
      });

      _showSuccessMessage('User details updated successfully!');
    } catch (e) {
      print('Error updating user details: $e');
      _showErrorMessage('An error occurred while updating user details.');
    }
  }

  void _showSuccessMessage(String message) {
    print(message);
  }

  void _showErrorMessage(String message) {
    print(message);
  }
}
