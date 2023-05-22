import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:siamdealz/utils/style.dart';

class ProgressDialog {
  late AlertDialog alert;

  showLoaderDialog(BuildContext context) {
    alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(color: Style.colors.logoRed),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Color(0xBFFFFFFF),
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showWithoutBackgroundLoaderDialog(BuildContext context) {
    alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(color: Style.colors.logoRed),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Color(0x01000000),
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  dismissDialog(BuildContext context) {
    Navigator.pop(context);
  }

}

