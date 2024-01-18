import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage; // Add 'as firebase_storage' alias
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattendanceapp/models/user_model.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<String> uploadProfilePhoto(File photoFile, String userId) async {
    try {
      String fileName = 'profile_photos/$userId.jpg';
      firebase_storage.Reference storageReference =
          firebase_storage.FirebaseStorage.instance.ref().child(
              fileName); // Change 'Reference' to 'firebase_storage.Reference'
      firebase_storage.UploadTask uploadTask = storageReference.putFile(
          photoFile); // Change 'UploadTask' to 'firebase_storage.UploadTask'
      await uploadTask.whenComplete(() => null);
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      throw Exception('Failed to upload profile photo');
    }
  }

  createUser(UserModel user, String userId, File? profilePhoto) async {
    try {
      if (profilePhoto != null) {
        String photoUrl = await uploadProfilePhoto(profilePhoto, userId);
        user = user.copyWith(profilePhotoUrl: photoUrl);
      }

      await _db.collection("Users").doc(userId).set(user.toJson()).whenComplete(
            () => Get.snackbar(
              "Success",
              "Your account has been created.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green,
            ),
          );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong. Try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
