import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../utils/resources.dart';

class ReviewsListScreen extends StatelessWidget {
  const ReviewsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading:BackButton(),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (BuildContext context, index) {
            return Padding(
              padding: EdgeInsets.only(
                top: index == 0 ? 20.sp : 15.sp,
                left: 8.sp,
                right: 8.sp
              ),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .2,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image:  AssetImage(Resources.assets.review))),
              ),
            );
          })
    );
  }
}
