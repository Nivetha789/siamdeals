import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Dot extends StatelessWidget {
  final Color color;
  double? width;
  double? height;

  Dot({required this.color, this.height, this.width, Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        height: height ?? 6.sp,
        width: width ?? 6.sp,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
