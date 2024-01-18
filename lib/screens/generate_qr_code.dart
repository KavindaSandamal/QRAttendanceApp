import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrCode extends StatefulWidget {
  final List<String> lectureIds;

  GenerateQrCode({required this.lectureIds});

  @override
  _GenerateQrCodeState createState() => _GenerateQrCodeState();
}

class _GenerateQrCodeState extends State<GenerateQrCode> {
  String selectedLectureId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF03A9F4),
          title: Text(
            'Generate QR',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true,
        ),
      ),
      body: ListView.builder(
        itemCount: widget.lectureIds.length,
        itemBuilder: (context, index) {
          String lectureId = widget.lectureIds[index];
          String qrData = 'Lecture ID: $lectureId';

          return Card(
            color: selectedLectureId == lectureId
                ? Colors.blueAccent.withOpacity(0.3)
                : null,
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedLectureId = lectureId;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    SizedBox(height: 16.0),
                    Text('Lecture ID: $lectureId'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLectureId.isNotEmpty) {
            print('Generating QR for Lecture ID: $selectedLectureId');
          } else {
            print('Please select a lecture to generate QR code');
          }
        },
        child: Icon(Icons.qr_code, color: Colors.white),
        backgroundColor: Color(0xFF2196F3),
      ),
    );
  }
}
