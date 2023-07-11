import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  // Toast bar Message Tab
  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: const Color(0xffFF8419),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  // Snack bar Message Tab
  static showSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xffFF8419),
        content: FittedBox(
          child: Text(message),
        ),
      ),
    );
  }

// Dialog box Message Tab
  static showDialogMessage(String message, BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: FittedBox(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xffFF8419),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
