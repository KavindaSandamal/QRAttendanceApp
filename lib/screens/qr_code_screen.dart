import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QrCodeScreen extends StatefulWidget {
  @override
  _QrCodeScreenState createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  QRViewController? _controller;
  late String qrText = "";
  bool isScanning = true;
  bool hasSubmitted = false;
  bool isCooldown = false;

  Future<String?> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<bool> _isAttendanceSubmitted(
      String studentId, String lectureId) async {
    // Check if the attendance record already exists for the given student and lecture
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('Attendance')
        .where('studentId', isEqualTo: studentId)
        .where('lectureId', isEqualTo: lectureId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void _submitAttendance(String studentId, String lectureId) async {
    bool alreadySubmitted = await _isAttendanceSubmitted(studentId, lectureId);
    try {
      if (alreadySubmitted || hasSubmitted) {
        // Display a message if attendance has already been submitted
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Attendance has already been submitted.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the error dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      if (!isCooldown) {
        // Set cooldown to prevent multiple submissions
        isCooldown = true;
        Future.delayed(Duration(seconds: 10), () {
          setState(() {
            isCooldown = false;
          });
        });

        // Your existing submission logic
        await FirebaseFirestore.instance.collection('Attendance').add({
          'studentId': studentId,
          'lectureId': lectureId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          isScanning = false;
          hasSubmitted = true;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Attendance Successfully Submitted'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the success dialog
                    Navigator.pop(
                        context); // Navigate back to the previous screen
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('Submission cooldown in progress. Please wait.');
      }
    } catch (error) {
      print('Error submitting attendance: $error');
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
            'QR Code Scanner',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller == null && !hasSubmitted)
                  QRView(
                    key: GlobalKey(),
                    onQRViewCreated: (controller) async {
                      _controller = controller;
                      _controller!.scannedDataStream.listen((scanData) {
                        if (isScanning && !hasSubmitted) {
                          setState(() async {
                            qrText = scanData.code!;
                            String? studentId = await _getCurrentUserId();
                            if (studentId != null && qrText.length >= 20) {
                              _submitAttendance(
                                  studentId, qrText.substring(0, 20));

                              isScanning = false;
                            }
                          });
                        }
                      });
                    },
                  ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.yellow,
                      width: 5.0,
                    ),
                  ),
                  width: 200.0,
                  height: 200.0,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey.withOpacity(0.3),
            child: Text(
              'Scanned QR Code: $qrText',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
