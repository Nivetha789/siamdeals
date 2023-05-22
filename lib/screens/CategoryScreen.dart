// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/style.dart';
import '../ResponseModule/BannerModel.dart';
import '../ResponseModule/CategoryModel.dart';
import '../core/ApiProvider/api_provider.dart';
import '../helper/AppLocalizations.dart';
import '../utils/ProgressDialog.dart';
import '../utils/check_internet.dart';
import '../utils/fab_menu_package.dart';
import '../utils/handler/toast_handler.dart';
import 'SearchStoreListScreen.dart';

class CategoryListScreen extends StatefulWidget {
  final cityid;
  CategoryListScreen(this.cityid, {super.key});

  CategoryListScreenState createState() => CategoryListScreenState();
}

class CategoryListScreenState extends State<CategoryListScreen> {
  List<CategoryJResult> categoryJResultList = [];

  bool checkBanner = false;
  List<BannerJResult> bannerJResultList = [];

  bool checkEmpty = false;
  String emptyTxt = "";
  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();

  int pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check().then((intenet) {
      if (intenet) {
        getBannerList("category", "0");
        getCategoryList();
      } else {
        ToastHandler.showToast(
            message: "Please check your internet connection");
      }
    });
  }

  updateCategoryList(List<CategoryJResult> categoryJResultList1,
      List<CategoryJBanner> categoryJBannerList1) {
    categoryJResultList.clear();
    setState(() {
      categoryJResultList.addAll(categoryJResultList1);
    });
  }

  updateBannerList(List<BannerJResult> bannerJResultList1) {
    bannerJResultList.clear();
    setState(() {
      bannerJResultList.addAll(bannerJResultList1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Style.colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: BackButton(),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.categories!,
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Style.colors.logoRed,
              fontSize: 17.0,
              fontFamily: Style.montserrat),
        ),
        iconTheme: IconThemeData(color: Style.colors.logoRed),
        backgroundColor: Colors.white,
        // brightness: Brightness.light,
      ),
      body: HawkFabMenu(
        icon: Image.asset("images/help.png", color: Color(0xffFB595D)),
        fabColor: Color(0xffFB595D),
        iconColor: Color(0xffFB595D),
        hawkFabMenuController: hawkFabMenuController,
        items: [
          HawkFabMenuItem(
            label: 'Whatsapp',
            ontap: () {
              openWhatsapp();
            },
            icon: Image.asset("images/whatsapp.png", height: 30, width: 30),
            color: Style.colors.white,
            labelColor: Style.colors.white,
            labelBackgroundColor: Colors.green,
          ),
          // HawkFabMenuItem(
          //   label: 'Line',
          //   ontap: () {
          //     launch(('tel://${"+66810673747"}'));
          //   },
          //   icon: Image.asset("images/phone_call.png", height: 30, width: 30),
          //   color: Style.colors.white,
          //   labelColor: Style.colors.white,
          //   labelBackgroundColor: Colors.blue,
          // ),
        ],
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      top: 5.0, left: 16.0, right: 16.0, bottom: 5.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6.0)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6.0)),
                        hintText:
                            AppLocalizations.of(context)!.category_search!,
                        hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff495271)
                                .withOpacity(0.3)
                                .withOpacity(0.7)),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20.sp,
                          color: Style.colors.logoRed,
                        )),
                    style: TextStyle(fontSize: 15.sp),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                ),
                flex: 1,
              ),
              Visibility(
                visible: checkBanner,
                child: bannerJResultList.isNotEmpty
                    ? Expanded(
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .city_spotLight!,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: Style.josefinsans)),
                                margin: EdgeInsets.only(top: 15.0, left: 16.0),
                                alignment: Alignment.centerLeft,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: CarouselSlider.builder(
                                  itemCount: bannerJResultList.length,
                                  itemBuilder: (BuildContext context, int index,
                                      int realIdx) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Container(
                                        width: 330.0,
                                        height: 200.0,
                                        child: Container(
                                          child: Image.network(
                                            bannerJResultList[index]
                                                .cBannerImage!,
                                            fit: BoxFit.fitWidth,
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                    );
                                  },
                                  options: new CarouselOptions(
                                      autoPlay: bannerJResultList.length > 0
                                          ? true
                                          : false,
                                      viewportFraction: 1.0,
                                      height: 200,
                                      enlargeCenterPage: false,
                                      enableInfiniteScroll: false,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          pageIndex = index;
                                          // _current = index;
                                        });
                                      }),
                                ),
                              ),
                              Container(
                                child: CarouselIndicator(
                                  count: bannerJResultList.length,
                                  index: pageIndex,
                                  color: Style.colors.grey.withOpacity(0.3),
                                  activeColor: Style.colors.logoRed,
                                  width: 10.0,
                                ),
                                margin: EdgeInsets.only(top: 5.0),
                              )
                            ],
                          ),
                        ),
                        flex: 4,
                      )
                    : Container(),
              ),
              Expanded(
                flex: 6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: !checkEmpty,
                      child: Container(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: categoryJResultList.length,
                            itemBuilder: (BuildContext context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 8.sp,
                                    right: 8.sp,
                                    top: index == 0 ? 12.sp : 8.sp),
                                child: GestureDetector(
                                  onTap: () {
                                    print(
                                        "asdfghjkl {categoryJResultList[index].nId!}");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SearchStoreListScreen(
                                                    int.parse(
                                                        categoryJResultList[
                                                                index]
                                                            .nId!),
                                                    widget.cityid,
                                                    categoryJResultList[index]
                                                        .cCategory!,
                                                    true)));
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.sp)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.sp),
//  color: Colors.green,
                                          border: Border.all(
                                              color: Style.colors.grey
                                                  .withOpacity(.2))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 20.5.h,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10.sp),
                                                    topRight:
                                                        Radius.circular(10.sp)),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        categoryJResultList[
                                                                index]
                                                            .cCategoryImage!))),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 15.0,
                                                bottom: 15.0,
                                                left: 8,
                                                right: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  categoryJResultList[index]
                                                      .cCategory!,
                                                  style: TextStyle(
                                                      color: Style
                                                          .colors.app_black,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w600),
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
                      ),
                    ),
                    Visibility(
                      visible: checkEmpty,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          emptyTxt,
                          style: TextStyle(
                              color: Style.colors.grey,
                              fontSize: 15.0,
                              fontFamily: Style.montserrat,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getCategoryList() async {
    ProgressDialog().showLoaderDialog(context);

    try {
      Dio dio = new Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      var parameters = {"n_parent": 0, "n_city": widget.cityid};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      final response = await dio.post(ApiProvider.getCategory,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        CategoryModel categoryModel = CategoryModel.fromJson(map);

        if (categoryModel.nStatus == 1) {
          setState(() {
            checkEmpty = false;
          });

          updateCategoryList(categoryModel.jResult!, categoryModel.jBanner!);
          ProgressDialog().dismissDialog(context);
        } else {
          setState(() {
            checkEmpty = true;
            emptyTxt = categoryModel.cMessage!;
          });
          ProgressDialog().dismissDialog(context);
        }
      } else {
        ProgressDialog().dismissDialog(context);
        setState(() {
          checkEmpty = true;
          emptyTxt = "Bad Network Connection try again..";
        });
      }

      // print(response);
    } catch (e) {
      ProgressDialog().dismissDialog(context);
      setState(() {
        checkEmpty = true;
        emptyTxt = "Bad Network Connection try again..";
      });
    }
  }

  openWhatsapp() async {
    var whatsapp = "+66810673747";
    var whatsappURl_android = "whatsapp://send?phone=" + whatsapp + "&text=";
    var whatappURL_ios = "https://wa.me/$whatsapp?text=${Uri.parse("")}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunch(whatappURL_ios)) {
        await launch(whatappURL_ios, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // android , web
      if (await canLaunch(whatsappURl_android)) {
        await launch(whatsappURl_android);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  getBannerList(String type, String actionId) async {
    try {
      Dio dio = new Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      var parameters = {"c_type": type, "n_actionid": actionId};

      final response = await dio.post(ApiProvider.getBanner,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        BannerModel bannerModel = BannerModel.fromJson(map);

        if (bannerModel.nStatus == 1) {
          setState(() {
            checkBanner = true;
          });

          updateBannerList(bannerModel.jResult!);
        }
      } else {
        setState(() {
          checkBanner = false;
        });
        // bannerJResultList.clear();
        print("Response: " + "Bad Network Connection try again..");
        // ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // print(response);
    } catch (e) {
      // bannerJResultList.clear();
      setState(() {
        checkBanner = false;
      });
      ProgressDialog().dismissDialog(context);
      print("Response: " + e.toString());
    }
  }
}
