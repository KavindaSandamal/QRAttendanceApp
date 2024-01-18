import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Color(0xFF03A9F4),
          title: Text(
            'Notifications',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          centerTitle: true,
        ),
      ),
      body: Center(
        child: Text('This is the Notification Page content'),
      ),
    );
  }
}
