import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../utils/style.dart';

class TopCouponsAndDealsCard extends StatelessWidget {
  final String image;
  final String logoName;
  final String title;
  final String description;
  final String offerMessage;
  final VoidCallback onTapGetCode;

  const TopCouponsAndDealsCard({
    super.key,
    required this.image,
    required this.logoName,
    required this.title,
    required this.description,
    required this.offerMessage,
    required this.onTapGetCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp, left: 8.sp, right: 8.sp),
      child: Container(
        height: 19.h,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6.sp)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height:18.h,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.sp),
                  bottomLeft: Radius.circular(5.sp),
                ),
                  image: DecorationImage(
                      fit: BoxFit.cover, image: NetworkImage(image))),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.sp, bottom: 8.sp, left: 16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                  ),
                  SizedBox(height: 5.sp,),
                  SizedBox(
                    width: 55.w,
                    child: Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  // SizedBox(
                  //   height: 0.5.h,
                  // ),
                  // Text(
                  //   offerMessage,
                  //   style: Style.textStyles.poppins(
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.green,
                  //   ),
                  // ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        child: Text('Get Code'),
                          onPressed: onTapGetCode),
                      // SizedBox(width: 5.w,),
                      // CustomElevatedButton(
                      //     buttonText: 'View Store',
                      //     filledColor: false,
                      //     onPressed: () {}),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
