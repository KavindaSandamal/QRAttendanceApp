import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrattendanceapp/models/lecture_model.dart';
import 'package:qrattendanceapp/models/modules_model.dart';
import 'package:intl/intl.dart';
import 'package:qrattendanceapp/screens/generate_qr_code.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';

class LectureDetailsScreen extends StatefulWidget {
  @override
  _LectureDetailsScreenState createState() => _LectureDetailsScreenState();
}

class _LectureDetailsScreenState extends State<LectureDetailsScreen> {
  List<Lecture> lectures = [];
  List<Modules> allModules = [];
  final CollectionReference lecturesCollection =
      FirebaseFirestore.instance.collection('Lectures');
  final CollectionReference modulesCollection =
      FirebaseFirestore.instance.collection('Modules');

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchModules();
    _fetchLectures();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchLectures();
  }

  // Function to fetch all modules for the current lecturer
  void _fetchModules() async {
    String lecturerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    QuerySnapshot moduleSnapshot = await modulesCollection
        .where('lecturerId', isEqualTo: lecturerId)
        .get();

    setState(() {
      allModules =
          moduleSnapshot.docs.map((doc) => Modules.fromFirestore(doc)).toList();
    });
  }

  // Function to fetch lectures
  void _fetchLectures() async {
    String lecturerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    QuerySnapshot lectureSnapshot = await lecturesCollection
        .where('lecturerId', isEqualTo: lecturerId)
        .get();

    setState(() {
      lectures = lectureSnapshot.docs
          .map((doc) => Lecture.fromFirestore(doc))
          .toList();
    });
  }

  // Function to add a lecture
  void _addLecture(
      String date, String time, String place, Modules? selectedModule) async {
    String lecturerId = FirebaseAuth.instance.currentUser?.uid ??
        ''; // Get the current lecturer's ID

    if (selectedModule != null) {
      var docRef = await lecturesCollection.add({
        'lecturerId': lecturerId, // Add the lecturerId field
        'moduleId': selectedModule.id,
        'moduleName': selectedModule.moduleName,
        'date': date,
        'time': time,
        'place': place,
        // Add other details as needed
      });

      String lectureId = docRef.id;

      setState(() {
        lectures.add(Lecture(
          id: lectureId,
          lecturerId: lecturerId,
          moduleId: selectedModule.id,
          moduleName: selectedModule.moduleName,
          date: date,
          time: time,
          place: place,
          // Add other details as needed
        ));
      });
    }
  }

  // Function to delete a lecture
  void _deleteLecture(String lectureId) async {
    await lecturesCollection.doc(lectureId).delete();

    setState(() {
      lectures.removeWhere((lecture) => lecture.id == lectureId);
    });
  }

  Color _getModuleColor(String moduleId) {
    // You can implement your logic to assign a unique color for each module
    // For simplicity, let's use a predefined list of colors
    List<Color> moduleColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      // Add more colors as needed
    ];

    int index = allModules.indexWhere((module) => module.id == moduleId);
    if (index >= 0 && index < moduleColors.length) {
      return moduleColors[index];
    } else {
      // Default color if the module is not found or doesn't have a specific color
      return Colors.grey;
    }
  }

  Future<bool> _showGenerateQrConfirmation(Lecture lecture) async {
    bool confirmGenerate = false; // Default value

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Generate QR Code'),
          content: Text('Do you want to generate a QR code for this lecture?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // No, don't generate QR code
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                confirmGenerate = true;
                Navigator.pop(context, true); // Yes, generate QR code
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    return confirmGenerate;
  }

  Future<void> _generateQrCode(Lecture lecture) async {
    var confirmGenerate = await _showGenerateQrConfirmation(lecture);

    if (confirmGenerate) {
      print('Generate QR Code function called');
      String qrData = _generateQrData(
        lecture.id,
        lecture.lecturerId,
        lecture.moduleId,
        lecture.date,
        lecture.time,
        lecture.place,
      );

      // Create a PDF document
      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                children: [
                  // Add QR code to the PDF using BarcodeWidget
                  pw.BarcodeWidget(
                    color: PdfColors.black,
                    barcode: pw.Barcode.qrCode(),
                    data: qrData,
                    width: 200,
                    height: 200,
                  ),
                  pw.SizedBox(height: 10),
                  // Add additional text or information to the PDF
                  pw.Text('Date: ${lecture.date}'),
                  pw.Text('Time: ${lecture.time}'),
                  pw.Text('Place: ${lecture.place}'),
                  pw.Text('Module Name: ${lecture.moduleName}'),
                ],
              ),
            );
          },
        ),
      );

      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
        status = await Permission.storage.status;
        if (!status.isGranted) {
          print('Permission denied.');
          return;
        }
      }

      // Get the downloads directory with lecle_downloads_path_provider
      Directory? downloadsDirectory = await DownloadsPath.downloadsDirectory();
      String? downloadsDirectoryPath = downloadsDirectory?.path;

      final String filePath = '$downloadsDirectoryPath/${lecture.id}.pdf';

      final File pdfFile = File(filePath);
      await pdfFile.writeAsBytes(await pdf.save());

      print('PDF saved to: $filePath');

      // Show the PDF using a PDF viewer (you can use a package like pdf_viewer)
      // You need to implement this part based on your chosen PDF viewer package

      // After showing the PDF, you can add a button to trigger the download
      // For example, add a FlatButton to your UI

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('QR Code Generated'),
            content: Column(
              children: [
                // Use QrImage directly to display the QR code
                SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: QrImageView(
                    data: qrData ?? '',
                    version: QrVersions.auto,
                  ),
                ),
                SizedBox(height: 10),
                // Add a button to download the PDF
                TextButton(
                  onPressed: () async {
                    // Display a message or take further actions as needed
                    print('PDF saved to: $filePath');

                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Download PDF'),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _generateQrCodeForLecture(Lecture lecture) async {
    await _generateQrCode(lecture);
  }

  // Function to generate QR code data based on lecture ID
  String _generateQrData(String lectureId, String lecturerId, String moduleId,
      String date, String time, String place) {
    // Concatenate lecture details into a string
    String qrData = "$lectureId|$lecturerId|$moduleId|$date|$time|$place";
    return qrData;
  }

  Widget _buildModuleLectures(List<Lecture> moduleLectures) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: moduleLectures.length,
      itemBuilder: (context, index) {
        Lecture lecture = moduleLectures[index];
        Color moduleColor = _getModuleColor(lecture.moduleId);

        return Card(
          color: moduleColor,
          elevation: 3.0,
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: ListTile(
            onTap: () async {
              await _generateQrCode(lecture);
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${lecture.date != null ? Utils.getFormattedDateSimple(lecture.date.toString()) : 'Invalid Date'}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Time: ${lecture.time}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Place: ${lecture.place}',
                  style: TextStyle(color: Colors.white),
                ),
                // Add other details as needed
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteLecture(lecture.id);
                  },
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color pageBackgroundColor = Colors.white; // Initial background color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF2962FF),
          title: Text(
            'Lecture Details',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true,
        ),
      ),
      body: GestureDetector(
        // GestureDetector for the entire screen
        onPanUpdate: (details) {
          // Detect swipe gestures
          if (details.delta.dx > 0) {
            // Right swipe
            setState(() {
              pageBackgroundColor = Colors.green; // Change background color
            });
          } else if (details.delta.dx < 0) {
            // Left swipe
            setState(() {
              pageBackgroundColor = Colors.red; // Change background color
            });
          }
        },
        child: Container(
          color: pageBackgroundColor, // Set the background color of the page
          child: allModules.isNotEmpty
              ? ListView.builder(
                  itemCount: allModules.length,
                  itemBuilder: (context, index) {
                    Modules module = allModules[index];
                    List<Lecture> moduleLectures = lectures
                        .where((lecture) => lecture.moduleId == module.id)
                        .toList();

                    return Dismissible(
                      key: Key(module.id), // Unique key for each module
                      onDismissed: (direction) {
                        // Handle dismiss (swipe) action
                        setState(() {
                          allModules.removeAt(index); // Remove the module
                        });
                      },
                      background: Container(
                        color: Colors.grey, // Background color on swipe
                      ),
                      child: Card(
                        elevation: 5.0,
                        margin: EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Module Code: ${module.moduleCode}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Module Name: ${module.moduleName}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              _buildModuleLectures(moduleLectures),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text('No modules available.'),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLectureDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF2196F3),
      ),
    );
  }

  // Function to show a dialog for adding a new lecture
  Future<void> _showAddLectureDialog() async {
    Modules? selectedModule;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    Future<void> _selectDate(BuildContext context) async {
      DateTime currentDate = selectedDate ?? DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        setState(() {
          selectedDate = picked;
          dateController.text = Utils.getFormattedDateSimple(
              selectedDate!.millisecondsSinceEpoch.toString());
        });
      }
    }

    Future<void> _selectTime(BuildContext context) async {
      TimeOfDay currentTime = selectedTime ?? TimeOfDay.now();
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: currentTime,
      );

      if (picked != null) {
        setState(() {
          selectedTime = picked;
          timeController.text = "${picked.hour}:${picked.minute}";
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Lecture'),
              content: Container(
                width: MediaQuery.of(context).size.width *
                    0.8, // Set a maximum width
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButton<Modules>(
                        value: selectedModule,
                        onChanged: (Modules? newSelectedModule) {
                          setState(() {
                            selectedModule = newSelectedModule;
                          });
                        },
                        items: allModules.map((Modules module) {
                          return DropdownMenuItem<Modules>(
                            value: module,
                            child: Text(
                                '${module.moduleCode}: ${module.moduleName}'),
                          );
                        }).toList(),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _selectDate(context);
                          if (selectedDate != null) {
                            setState(() {
                              dateController.text =
                                  Utils.getFormattedDateSimple(selectedDate!
                                      .millisecondsSinceEpoch
                                      .toString());
                            });
                          }
                        },
                        child: Text('Select Date'),
                      ),
                      TextField(
                        controller: dateController,
                        enabled: false,
                        decoration: InputDecoration(labelText: 'Date'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _selectTime(context);
                          if (selectedTime != null) {
                            setState(() {
                              timeController.text =
                                  "${selectedTime!.hour}:${selectedTime!.minute}";
                            });
                          }
                        },
                        child: Text('Select Time'),
                      ),
                      TextField(
                        controller: timeController,
                        enabled: false,
                        decoration: InputDecoration(labelText: 'Time'),
                      ),
                      TextField(
                        controller: placeController,
                        decoration: InputDecoration(labelText: 'Place'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String date = selectedDate != null
                        ? Utils.getFormattedDateSimple(
                            selectedDate!.millisecondsSinceEpoch.toString())
                        : '';
                    String time = selectedTime != null
                        ? "${selectedTime!.hour}:${selectedTime!.minute}"
                        : '';

                    String place = placeController.text.trim();

                    if (date.isNotEmpty &&
                        time.isNotEmpty &&
                        place.isNotEmpty &&
                        selectedModule != null) {
                      _addLecture(date, time, place, selectedModule);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class Utils {
  static String getFormattedDateSimple(String dateString) {
    try {
      // Convert milliseconds to DateTime
      DateTime parsedDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(dateString));

      // Format the DateTime object
      DateFormat newFormat = DateFormat("MM/dd/yyyy");
      return newFormat.format(parsedDate);
    } catch (e) {
      // If parsing fails, assume it's already a valid DateTime object and return it
      return dateString;
    }
  }
}
