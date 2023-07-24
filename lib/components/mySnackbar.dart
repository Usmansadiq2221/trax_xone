import 'package:flutter/material.dart';

class MySnackBar{
  void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Trax xone',
          onPressed: () {
            // Perform an action when the user presses the action button
            print('Trax Xone');
          },
        ),
      ),
    );
  }
}