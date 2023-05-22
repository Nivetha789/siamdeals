import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ImageListScreen extends StatefulWidget {

  ImageListScreenState createState() => ImageListScreenState();


}

class ImageListScreenState extends State<ImageListScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: BackButton(),
      ),

      body: Padding(
        padding: EdgeInsets.only(top: 10.sp, left: 8.sp, right: 8.sp),
        child: GridView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: .0.sp,
              mainAxisSpacing: 0.sp,
              childAspectRatio: .60.sp,
            ),
            itemCount: 8,
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.all(2.sp),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => CouponListScreen()));
                  },
                  child: Container(
                    width: 22.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgcfas8NKYAEx3f4nl-H4Onh6JnouK6YExMumJKOJi&s'))),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
