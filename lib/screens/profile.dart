import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.0),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            if (currentUser != null) ...[
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : AssetImage('lib/assets/profile.png') as ImageProvider<Object> // Explicit cast
                    ),
                    radius: 50.0,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              FutureBuilder<String?>(
                future: _fetchFullName(currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error fetching fullName');
                  } else {
                    String fullName = snapshot.data ?? 'N/A';
                    return Center(
                      child: Text(
                        '$fullName',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _uploadProfilePhoto(currentUser!.uid);
                },
                child: Text('Upload Profile Photo'),
              ),
              SizedBox(height: 16.0), // Add some space
            ],
            PasswordChangeForm(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfilePhoto(String userId) async {
    try {
      if (_selectedImage == null || userId == null || userId.isEmpty) {
        print('Invalid user ID or no image selected to upload. UserId: $userId');
        return;
      }

      String fileName = 'profile_photos/$userId.png';
      firebase_storage.Reference storageReference =
      firebase_storage.FirebaseStorage.instance.ref().child(fileName);

      // Check if the file exists by attempting to get its download URL
      try {
        await storageReference.getDownloadURL();
      } catch (e) {
        print('File does not exist at location: $fileName');
        return;
      }

      firebase_storage.UploadTask uploadTask = storageReference.putFile(_selectedImage!);
      await uploadTask.whenComplete(() => null);
      String downloadUrl = await storageReference.getDownloadURL();

      // Now you have the downloadUrl, you can use it as needed.
      print('Profile photo uploaded. Download URL: $downloadUrl');

      // Update the user's profile photo URL in the Firestore database
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({'profilePhotoUrl': downloadUrl});
    } catch (e) {
      print('Error uploading profile photo: $e');
      throw Exception('Failed to upload profile photo');
    }
  }

  Future<String?> _fetchFullName(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      return userSnapshot['FullName'];
    } catch (e) {
      print('Error fetching fullName: $e');
      return null;
    }
  }
}

class PasswordChangeForm extends StatefulWidget {
  @override
  _PasswordChangeFormState createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _currentPasswordController,
          decoration: InputDecoration(
            labelText: 'Current Password',
          ),
          obscureText: true,
        ),
        SizedBox(height: 16.0),
        TextFormField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'New Password',
          ),
          obscureText: true,
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            String currentPassword = _currentPasswordController.text;
            String newPassword = _newPasswordController.text;

            print('Current Password: $currentPassword');
            print('New Password: $newPassword');

            // Add logic to change the password
            // ...

            // Navigate back to the previous page (ProfilePage)
            Navigator.pop(context);
          },
          child: Text('Change Password'),
        ),
      ],
    );
  }
}
