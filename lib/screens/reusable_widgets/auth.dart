import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AuthBg extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final Widget form;
  final bool hideButton;
  final void Function()? onSubmit;

  const AuthBg(
      {required this.title,
      required this.description,
      required this.buttonText,
      required this.form,
      required this.onSubmit,
      required this.hideButton,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: 100.w,
          height: 100.h,
          child: SingleChildScrollView(
            child: Stack(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Positioned(
                  right: 20,
                  top: 20,
                  child: Container(
                    width: 15.w,
                    height: 8.5.h,
                    decoration: BoxDecoration(
                        //
                        // image: DecorationImage(
                        //   image: AssetImage('assets/images/logo.png',),
                        //   fit: BoxFit.contain,
                        // ),
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 6.w,
                    right: 6.w,
                    top: 10.h,
                    bottom: 15.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                      ),
                      Text(
                        description,
                      ),
                      SizedBox(
                        height: 10.sp,
                      ),
                      form,
                      SizedBox(
                        height: 5.h,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 7.h,
                        child: ElevatedButton(
                          child: Text(buttonText),
                          onPressed: onSubmit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
