import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Center(
        child: TextButton(
          child: const Text('Go Back'),
          // Go back to the Home screen
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
