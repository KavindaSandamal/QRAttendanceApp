import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF2962FF),
          title: Text(
            'Notifications',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true, // Center the title horizontally
        ),
      ),
      body: Center(
        child: Text('This is the Notification Page content'),
      ),
    );
  }
}
