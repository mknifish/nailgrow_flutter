import 'package:flutter/material.dart';

class DialogService {
  Future<void> showWinDialog(BuildContext context, VoidCallback onConfirm) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Image.asset(
              'assets/img/nag_tassei.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Future<void> showLoseDialog(BuildContext context, VoidCallback onConfirm) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Image.asset(
              'assets/img/nag_futassei.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Future<void> showErrorDialog(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
