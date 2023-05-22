import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:siamdealz/utils/style.dart';
import 'package:sizer/sizer.dart';

class Resources {
  static final assets = _Assets();
  static final widgets = _Widgets();
  static final anims = _Anims();
}

class _Anims {}

class _Assets {
  String man='images/man.png';
  String women='images/women.png';
  String coupon='images/coupon.jpeg';
  String logo='images/logo.png';
  String plateChickenImage='images/chicken.png';
  String foodCategory='images/food_category.png';
  String review='images/review.jpg';

}

class _Widgets {
  Widget dot() {
    return Container(
      width: 5.sp,
      height: 5.sp,
      decoration:
          BoxDecoration(color: Style.colors.primary, shape: BoxShape.circle),
    );
  }

  Widget loader = SizedBox(
    width: 100.w,
    height: 50.h,
    child: Center(
      child: Platform.isIOS
          ? CircularProgressIndicator.adaptive()
          : LoadingAnimationWidget.fallingDot(
              color: Style.colors.primary,
              size: 30.sp,
            ),
    ),
  );
}

