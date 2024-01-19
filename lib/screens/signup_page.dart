import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrattendanceapp/models/user_model.dart';
import 'package:qrattendanceapp/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrattendanceapp/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late UserRole selectedRole;
  final UserRepository _userRepository = Get.find<UserRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _registrationNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRole = UserRole.student;
  }

  Future<void> createUser(
      UserModel user, String userId, String? photoUrl) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'regNo': user.regNo,
        'fullname': user.fullname,
        'email': user.email,
        'password': user.password,
        'role': user.role,
      });
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }

  void _handleSignUp() async {
    try {
      UserCredential userCredential =
          await _userRepository.signUpWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );

      UserModel user = UserModel(
        regNo: _registrationNumberController.text,
        fullname: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: selectedRole == UserRole.student ? 'student' : 'pending',
      );

      await _userRepository.createUser(
        user,
        userCredential.user!.uid,
        null,
      );

      await createUser(user, userCredential.user!.uid, null);

      print("User Registered: ${userCredential.user!.email}");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('User Created Successfully!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error During Registration: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(30.0),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/signup_logo.jpg',
                height: 150.0,
              ),
              SizedBox(height: 16.0),
              Text(
                'QRAttendance',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                'Start The Journey With US',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 15.0),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0),
              TextFormField(
                controller: _registrationNumberController,
                decoration: InputDecoration(
                  labelText: 'Registration Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your registration number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.0),
              Text(
                'Select User Role',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              ListTile(
                title: Text('Student'),
                leading: Radio(
                  value: UserRole.student,
                  groupValue: selectedRole,
                  onChanged: (UserRole? value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Lecturer'),
                leading: Radio(
                  value: UserRole.lecturer,
                  groupValue: selectedRole,
                  onChanged: (UserRole? value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _handleSignUp();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF2196F3),
                  ),
                  child: Text(
                    'Sign up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  primary: const Color(0xFF2196F3),
                ),
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
