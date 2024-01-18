import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<List<Map<String, dynamic>>?> getPendingRequests() async {
    try {
      // Query Firestore for users with 'pending' role
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'pending')
          .get();

      // Convert each document to a map
      List<Map<String, dynamic>> pendingRequests = querySnapshot.docs
          .map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return pendingRequests;
    } catch (e) {
      print('Error fetching pending requests: $e');
      return null;
    }
  }

  void _approveRequest(String email) async {
    try {
      // Update the role to 'lecturer'
      await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.size > 0) {
          querySnapshot.docs.first.reference.update({'role': 'lecturer'});
        }
      });

      // Refresh the UI after approving
      setState(() {});
    } catch (e) {
      print('Error approving request: $e');
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
            'Admin',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true, // Center the title horizontally
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: getPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError || snapshot.data == null) {
            return Text('Error fetching pending requests.');
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No pending requests.'));
          } else {
            List<Map<String, dynamic>> pendingRequests = snapshot.data!;

            return ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> request = pendingRequests[index];
                print('Request: $request'); // Add this line for debugging

                return ListTile(
                  title: Text(request['fullname'] ?? ''),
                  subtitle: Text(request['email'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Check if 'email' is not null before using it
                      if (request['email'] != null) {
                        // Approve the request
                        _approveRequest(request['email']);
                      } else {
                        print('Error: email is null or not present.');
                      }
                    },
                    child: Text('Approve'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
