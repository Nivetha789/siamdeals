import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:siamdealz/ResponseModule/StoreDetailsModule/StoreDetailsModel.dart';

import '../utils/style.dart';

class ViewAllReviewImagesScreen extends StatefulWidget {
  List<JAlbums> profileDetailsImages = [];

  ViewAllReviewImagesScreen(this.profileDetailsImages);

  @override
  State<StatefulWidget> createState() {
    return _ViewAllReviewImagesScreen();
  }
}

class _ViewAllReviewImagesScreen extends State<ViewAllReviewImagesScreen> {
  PageController controller = PageController(initialPage: 0);

  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Container(
      //   color: Colors.black,
      //   child: ListView(
      //     children: [
      //       Container(
      //         alignment: Alignment.center,
      //         width: MediaQuery.of(context).size.width,
      //         height: MediaQuery.of(context).size.height/1.2,
      //         child: PhotoViewGallery.builder(
      //           itemCount: widget.profileDetailsImages.length,
      //           builder: (context, index) {
      //             return PhotoViewGalleryPageOptions(
      //             imageProvider: NetworkImage(
      //                 widget.profileDetailsImages[index].imageUrl),
      //             filterQuality: FilterQuality.high,
      //             minScale: PhotoViewComputedScale.contained * 0.8,
      //             maxScale: PhotoViewComputedScale.covered * 2,
      //             );
      //           },
      //           scrollPhysics: BouncingScrollPhysics(),
      //           backgroundDecoration: BoxDecoration(),
      //           loadingChild: Center(
      //             child: CircularProgressIndicator(),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ));

      body: Container(
        color: Colors.black,
        child: ListView(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(top: 20.0, right: 20.0),
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.close_outlined,
                  size: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              color: Colors.black,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height / 1.2,
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: PhotoViewGallery.builder(
                          builder: (BuildContext context, int index) {
                            return PhotoViewGalleryPageOptions(
                              filterQuality: FilterQuality.high,
                              imageProvider: NetworkImage(widget
                                  .profileDetailsImages[index].cListingImg!),
                              initialScale:
                                  PhotoViewComputedScale.contained * 0.9,
                              // heroAttributes: PhotoViewHeroAttributes(
                              //     tag: widget.profileDetailsImages[index].imageId!),
                            );
                          },
                          itemCount: widget.profileDetailsImages.length,

                          loadingBuilder: (context, event) => Center(
                            child: Container(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                value: event == null
                                    ? 0
                                    : event.cumulativeBytesLoaded /
                                        event.expectedTotalBytes!,
                              ),
                            ),
                          ),
                          pageController: controller,
                          reverse: true,
                          onPageChanged: (index) {
                            setState(() {
                              pageIndex = index;
                              // _current = index;
                            });
                          },

                          // onPageChanged: onPageChanged,
                        ),
                      ),

                      widget.profileDetailsImages.isNotEmpty
                          ? Container(
                              child: CarouselIndicator(
                                count: widget.profileDetailsImages.length,
                                index: pageIndex,
                                color: MyStyle.colors.grey.withOpacity(0.3),
                                activeColor: MyStyle.colors.white,
                                width: 10.0,
                              ),
                              margin: EdgeInsets.only(top: 5.0),
                            )
                          : Container(),
                      // Container(
                      //   margin: EdgeInsets.only(bottom: 20.0),
                      //   child: SmoothPageIndicator(
                      //     controller: controller,
                      //     count: widget.profileDetailsImages.length,
                      //     effect: WormEffect(
                      //         dotHeight: 10.0,
                      //         dotWidth: 10.0,
                      //         dotColor: Colors.grey,
                      //         activeDotColor: Colors.white),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
