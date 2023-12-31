import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(10.0),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            // SizedBox(height: 10.0,),
          ],
        ),
      ),
    );
  }
}
