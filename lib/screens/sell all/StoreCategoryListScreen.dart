import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../utils/style.dart';

class StoreCategoryListScreen extends StatefulWidget {
  StoreCategoryListScreenState createState() => StoreCategoryListScreenState();
}

class StoreCategoryListScreenState extends State<StoreCategoryListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Style.colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Madras cafe',
          textAlign: TextAlign.start,
        ),
        iconTheme: IconThemeData(color: Style.colors.logoRed),
        backgroundColor: Colors.white,
        //     brightness: Brightness.light,
      ),
      body: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (BuildContext context, index) {
            return Padding(
              padding: EdgeInsets.only(
                  left: 8.sp, right: 8.sp, top: index == 0 ? 12.sp : 8.sp),
              child: GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> CouponListScreen()));
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.sp)),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.sp),
//  color: Colors.green,
                        border: Border.all(
                            color: Style.colors.grey.withOpacity(.2))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20.5.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.sp),
                                  topRight: Radius.circular(10.sp)),
                              image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      'https://images.freekaamaal.com/post_images/1538118798.jpg'))),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 15.0, left: 8, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 1.h,
                              ),
                              const Text(
                                'Biriyani',
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
