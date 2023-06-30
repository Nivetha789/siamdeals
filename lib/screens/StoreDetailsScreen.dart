// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:siamdealz/ResponseModule/DownloadCouponModel.dart';
import 'package:siamdealz/screens/viewallreviewimages.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ResponseModule/StoreDetailsModule/StoreDetailsModel.dart';
import '../Utils/SharedPreference.dart';
import '../core/ApiProvider/api_provider.dart';
import '../helper/AppLocalizations.dart';
import '../utils/ProgressDialog.dart';
import '../utils/check_internet.dart';
import '../utils/fab_menu_package.dart';
import '../utils/handler/toast_handler.dart';
import '../utils/style.dart';
import 'CouponListScreen.dart';
import 'ViewAllImagesScreen.dart';

class StoreDetailsScreen extends StatefulWidget {
  String storeId = "";
  String storeName = "";

  StoreDetailsScreen(this.storeId, this.storeName);

  StoreDetailsScreenState createState() => StoreDetailsScreenState();
}

class StoreDetailsScreenState extends State<StoreDetailsScreen> {
  List<JImages> storeDetailsJImagesList = [];
  List<JAlbums> storeDetailsJAlbumsList = [];
  List<JCoupons> storeDetailsJCoupons = [];
  List<JOpeningHours> openingHoursList = [];

  bool checkEmpty = false;
  String emptyTxt = "";
  String profilePicture = "";

  String? nId = "";
  String? nLatitude = "";
  String? nLongitude = "";
  String? cPlaceType = "";
  String? cIntroduction = "";
  String? cSinceType = "";
  String? nCityId = "";
  String? cCity = "";
  String? nDistrictId = "";
  String? cDistrict = "";
  String? nTownId = "";
  String? cTown = "";
  String? nCategoryId = "";
  String? cCategory = "";
  String? cName = "";
  String? cNameInThai = "";
  String? cMobileNumbers = "";
  String? cEmailids = "";
  String? cAddress = "";
  String? cTerms = "";
  String currentOpenTime = "";
  String currentCloseTime = "";
  bool checkCurrentLeave = false;

  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    check().then((intenet) {
      if (intenet) {
        storeDetailsApi();
      } else {
        ToastHandler.showToast(
            message: "Please check your internet connection");
      }
    });
  }

  updateStoreImage(
      List<JImages> storeDetailsJImagesList1,
      List<JAlbums> storeDetailsJAlbumsList1,
      List<JCoupons> storeDetailsJCoupons1,
      List<JOpeningHours> openingHoursList1) {
    storeDetailsJImagesList.clear();
    storeDetailsJAlbumsList.clear();
    storeDetailsJCoupons.clear();
    openingHoursList.clear();
    setState(() {
      storeDetailsJImagesList.addAll(storeDetailsJImagesList1);

      storeDetailsJAlbumsList.addAll(storeDetailsJAlbumsList1);
      storeDetailsJCoupons.addAll(storeDetailsJCoupons1);
      openingHoursList.addAll(openingHoursList1);

      if (storeDetailsJImagesList.length > 0) {
        profilePicture = storeDetailsJImagesList[0].cListingImg!;
      }
    });
  }

  //country
  OpenHoursBottomList(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        builder: (context) {
          return WillPopScope(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.75,
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 10.0),
                          height: 45.0,
                          child: Container(
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Open -  Close Timings",
                                    style: TextStyle(
                                        color: const Color(0xff495271),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: Style.sfproddisplay),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 20.0),
                                      child: Icon(Icons.cancel_sharp,
                                          size: 20.0, color: Colors.grey[400]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 20.0),
                          child: ListView.builder(
                              itemCount: openingHoursList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, postion) {
                                String openTime = "";
                                String closeTime = "";
                                bool checkLeave = false;

                                if (openingHoursList[postion].open!.isEmpty &&
                                    openingHoursList[postion].close!.isEmpty) {
                                  openTime = "Leave";
                                  closeTime = "";
                                  checkLeave = true;
                                } else if (openingHoursList[postion]
                                        .open!
                                        .isNotEmpty &&
                                    openingHoursList[postion].close!.isEmpty) {
                                  openTime = "Open - 24 Hours";
                                  closeTime = "";
                                  checkLeave = false;
                                } else {
                                  openTime =
                                      "Open - ${openingHoursList[postion].open!}";
                                  closeTime =
                                      " - Close - ${openingHoursList[postion].close!}";
                                  checkLeave = false;
                                }

                                return Container(
                                  margin: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              top: 10.0,
                                              bottom: 5.0),
                                          child: Text(
                                            "${openingHoursList[postion].days!} ($openTime$closeTime)",
                                            style: TextStyle(
                                                color: checkLeave
                                                    ? Colors.red
                                                    : Colors.black87,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    Style.sfproddisplay),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 10.0, bottom: 5.0),
                                        child: Divider(
                                          thickness: 0.5,
                                          height: 1.0,
                                          color: const Color(0xff818EA7)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                        const SizedBox(
                          height: 50.0,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            onWillPop: () async {
              return false;
            },
          );
        });
  }

  void launchGoogleMaps(double latitude, double longitude) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void redirectToCall(String phoneNumber) async {
    if (await Permission.phone.request().isGranted) {
      // Permission is granted. Proceed with making the phone call.
      String url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      // Permission is not granted. Show a dialog or handle it accordingly.
      // You can inform the user that the permission is required to make a phone call.
    }
  }

  void redirectMailPage(String providerUrl) async {
    // if (await Permission.email.request().isGranted) {
    // Permission is granted. Proceed with making the phone call.

    if (await canLaunch("mailto:$providerUrl")) {
      await launch("mailto:$providerUrl");
    } else {
      throw 'Could not launch $providerUrl';
    }
    // } else {
    //   // Permission is not granted. Show a dialog or handle it accordingly.
    //   // You can inform the user that the permission is required to make a phone call.
    // }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Style.colors.white,
        appBar: AppBar(
          elevation: 0.0,
          leading: const BackButton(),
          title: Text(widget.storeName,
              style: TextStyle(
                  color: Style.colors.logoRed,
                  fontSize: 17.0,
                  fontFamily: Style.montserrat)),
          centerTitle: false,
          iconTheme: IconThemeData(color: Style.colors.logoRed),
          backgroundColor: Colors.white,
          //brightness: Brightness.light,
        ),
        body: HawkFabMenu(
          icon: Image.asset("images/help.png", color: const Color(0xffFB595D)),
          fabColor: const Color(0xffFB595D),
          iconColor: const Color(0xffFB595D),
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
            HawkFabMenuItem(
              label: 'Map',
              ontap: () {
                double latitude = double.parse(
                    nLatitude!); // Replace with your desired latitude
                double longitude = double.parse(
                    nLongitude!); // Replace with your desired longitude

                launchGoogleMaps(latitude, longitude);
              },
              icon: Image.asset("images/map.png", height: 30, width: 30),
              color: Style.colors.white,
              labelColor: Style.colors.white,
              labelBackgroundColor: Colors.blue,
            ),
          ],
          body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Visibility(
                    visible: !checkEmpty,
                    child: ListView(
                      children: [
                        Container(
                          color: Colors.black,
                          child: Container(
                            color: const Color(0xfffafafa),
                            child: Stack(
                              children: [
                                Container(
                                  height: 350,
                                  alignment: Alignment.center,
                                  child: Container(
                                    color: Colors.black,
                                    foregroundDecoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                          Colors.black.withOpacity(0.3),
                                          const Color(0x00000000),
                                          const Color(0x00000000),
                                          const Color(0x00000000),
                                          const Color(0xCC000000),
                                        ])),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.network(
                                              profilePicture,
                                              // "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHBppM7IlnKJ5J66tUvw19f0S4MsajUI3mYCrZLnVGidUp7Xy7yLXHHKy-wqcbxh6BvCo&usqp=CAU",
                                              filterQuality: FilterQuality.high,
                                              height: 350,
                                              width: 350,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              top: 15.0, left: 16.0, right: 16.0),
                          child: Text(
                            cName!,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Style.colors.app_black,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(
                              top: 5.0, left: 16.0, right: 16.0),
                          child: Row(
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.place_type!} : ",
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Style.colors.grey,
                                    fontFamily: Style.montserrat,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                cPlaceType!,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Style.colors.grey,
                                    fontFamily: Style.montserrat,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            OpenHoursBottomList(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey.withOpacity(0.2),
                            margin: const EdgeInsets.only(top: 5.0),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 10.0,
                                  right: 16.0,
                                  top: 10.0,
                                  bottom: 10.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: checkCurrentLeave
                                        ? Colors.red
                                        : Style.colors.green,
                                    size: 18.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      currentOpenTime,
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: checkCurrentLeave
                                              ? Colors.red
                                              : Style.colors.app_black,
                                          fontFamily: Style.montserrat,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      currentCloseTime,
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: checkCurrentLeave
                                              ? Colors.red
                                              : Style.colors.app_black,
                                          fontFamily: Style.montserrat,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: Colors.grey,
                                      size: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Container(
                        //   margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        //   child: Wrap(
                        //     children: [
                        //       Chip(
                        //         avatar: Icon(
                        //           Icons.done,
                        //           color: Colors.green,
                        //           size: 15.0,
                        //         ),
                        //         label: Text(
                        //           "Dine-in",
                        //           style: TextStyle(
                        //             fontSize: 13.0,
                        //             color: Style.colors.app_black,
                        //           ),
                        //         ),
                        //         backgroundColor:
                        //             Style.colors.grey.withOpacity(0.1),
                        //         elevation: 1.0,
                        //         shadowColor: Style.colors.grey.withOpacity(0.1),
                        //         labelPadding: EdgeInsets.only(left: 1.0),
                        //         padding: EdgeInsets.only(right: 12.0, left: 6.0),
                        //       ),
                        //       SizedBox(
                        //         width: 10.sp,
                        //       ),
                        //       Chip(
                        //         avatar: Icon(
                        //           Icons.done,
                        //           color: Colors.green,
                        //           size: 15.sp,
                        //         ),
                        //         label: Text(
                        //           'Takeaway',
                        //           style: TextStyle(
                        //             fontSize: 13.0,
                        //             color: Style.colors.app_black,
                        //           ),
                        //         ),
                        //         backgroundColor:
                        //             Style.colors.grey.withOpacity(0.1),
                        //         elevation: 1.0,
                        //         shadowColor: Style.colors.grey.withOpacity(0.1),
                        //         labelPadding: EdgeInsets.only(left: 1.0),
                        //         padding: EdgeInsets.only(right: 12.0, left: 6.0),
                        //       ),
                        //       SizedBox(
                        //         width: 10.sp,
                        //       ),
                        //       Chip(
                        //         avatar: Icon(
                        //           Icons.done,
                        //           color: Colors.green,
                        //           size: 15.0,
                        //         ),
                        //         label: Text(
                        //           'Delivery',
                        //           style: TextStyle(
                        //             fontSize: 13.0,
                        //             color: Style.colors.app_black,
                        //           ),
                        //         ),
                        //         backgroundColor:
                        //             Style.colors.grey.withOpacity(0.1),
                        //         elevation: 1.0,
                        //         shadowColor: Style.colors.grey.withOpacity(0.1),
                        //         labelPadding: EdgeInsets.only(left: 1.0),
                        //         padding: EdgeInsets.only(right: 12.0, left: 6.0),
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        storeDetailsJImagesList.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(
                                    top: 15.0, left: 16.0, right: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.photos!,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: Style.colors.app_black,
                                          fontFamily: Style.josefinsans),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (storeDetailsJImagesList.length >
                                            0) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ViewAllImagesScreen(
                                                          storeDetailsJImagesList)));
                                        }
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.view_all!,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Style.colors.logoRed,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: Style.josefinsans),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 10.sp,
                        ),
                        storeDetailsJImagesList.isNotEmpty
                            ? Container(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 80,
                                      margin: const EdgeInsets.only(
                                          top: 10.0, left: 10.0, right: 10.0),
                                      alignment: Alignment.center,
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              flex: 4,
                                              child: Container(
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        storeDetailsJImagesList
                                                            .length,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, postion) {
                                                      return InkWell(
                                                        onTap: () {
//
                                                        },
                                                        child: Container(
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            children: [
                                                              Visibility(
                                                                visible: true,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      profilePicture =
                                                                          storeDetailsJImagesList[postion]
                                                                              .cListingImg!;
                                                                    });
                                                                  },
                                                                  child: Container(
                                                                      margin: const EdgeInsets.only(left: 3.0, right: 3.0, bottom: 8.0),
                                                                      height: 80,
                                                                      width: 80,
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Style.colors.app_black.withOpacity(0.3),
                                                                            width: 1),
                                                                        borderRadius:
                                                                            const BorderRadius.all(Radius.circular(10.0)),
                                                                      ),
                                                                      child: ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                        child:
                                                                            AspectRatio(
                                                                          aspectRatio:
                                                                              1 / 1,
                                                                          child:
                                                                              Image.network(
                                                                            storeDetailsJImagesList[postion].cListingImg!,
                                                                            filterQuality:
                                                                                FilterQuality.high,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        storeDetailsJAlbumsList.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(
                                    top: 15.0, left: 16.0, right: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Reviews",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: Style.colors.app_black,
                                          fontFamily: Style.josefinsans),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (storeDetailsJAlbumsList.length >
                                            0) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ViewAllReviewImagesScreen(
                                                          storeDetailsJAlbumsList)));
                                        }
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.view_all!,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Style.colors.logoRed,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: Style.josefinsans),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 10.sp,
                        ),
                        storeDetailsJAlbumsList.isNotEmpty
                            ? Container(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 80,
                                      margin: const EdgeInsets.only(
                                          top: 10.0, left: 10.0, right: 10.0),
                                      alignment: Alignment.center,
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              flex: 4,
                                              child: Container(
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        storeDetailsJAlbumsList
                                                            .length,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, postion1) {
                                                      return InkWell(
                                                        onTap: () {
//
                                                        },
                                                        child: Container(
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            children: [
                                                              Visibility(
                                                                visible: true,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    // setState(
                                                                    //     () {
                                                                    //   profilePicture =
                                                                    //       storeDetailsJImagesList[postion]
                                                                    //           .cListingImg!;
                                                                    // });
                                                                  },
                                                                  child: Container(
                                                                      margin: const EdgeInsets.only(left: 3.0, right: 3.0, bottom: 8.0),
                                                                      height: 80,
                                                                      width: 80,
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Style.colors.app_black.withOpacity(0.3),
                                                                            width: 1),
                                                                        borderRadius:
                                                                            const BorderRadius.all(Radius.circular(10.0)),
                                                                      ),
                                                                      child: ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                        child:
                                                                            AspectRatio(
                                                                          aspectRatio:
                                                                              1 / 1,
                                                                          child:
                                                                              Image.network(
                                                                            storeDetailsJAlbumsList[postion1].cListingImg!,
                                                                            filterQuality:
                                                                                FilterQuality.high,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),

                        storeDetailsJCoupons.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(
                                    top: 15.0, left: 16.0, right: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.coupons!,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: Style.colors.app_black,
                                          fontFamily: Style.josefinsans),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (storeDetailsJCoupons.length > 0) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      CouponListScreen(
                                                          nId!,
                                                          storeDetailsJImagesList[
                                                                  0]
                                                              .cListingImg!,
                                                          cName!,
                                                          cAddress!,
                                                          cMobileNumbers!,
                                                          storeDetailsJCoupons)));
                                        }
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.view_all!,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Style.colors.logoRed,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: Style.josefinsans),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 10.sp,
                        ),
                        storeDetailsJCoupons.isNotEmpty
                            ? Container(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 80,
                                      margin: const EdgeInsets.only(
                                          top: 10.0, left: 10.0, right: 10.0),
                                      alignment: Alignment.center,
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              flex: 4,
                                              child: Container(
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        storeDetailsJCoupons
                                                                    .length >
                                                                9
                                                            ? 10
                                                            : storeDetailsJCoupons
                                                                .length,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, postion) {
                                                      return Container(
                                                        child: Stack(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          children: [
                                                            Visibility(
                                                              visible: true,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _showAlert(
                                                                        context,
                                                                        postion);
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                        margin: const EdgeInsets.only(
                                                                            left:
                                                                                3.0,
                                                                            right:
                                                                                3.0,
                                                                            bottom:
                                                                                8.0),
                                                                        height:
                                                                            80,
                                                                        width:
                                                                            80,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: Border.all(
                                                                              color: Style.colors.app_black.withOpacity(0.3),
                                                                              width: 1),
                                                                          borderRadius:
                                                                              const BorderRadius.all(Radius.circular(10.0)),
                                                                        ),
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                          child:
                                                                              AspectRatio(
                                                                            aspectRatio:
                                                                                1 / 1,
                                                                            child:
                                                                                Image.network(
                                                                              storeDetailsJCoupons[postion].cImage!,
                                                                              filterQuality: FilterQuality.high,
                                                                            ),
                                                                          ),
                                                                        )),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        cIntroduction == ""
                            ? Container()
                            : Container(
                                margin: const EdgeInsets.only(
                                    top: 15.0, left: 16.0, right: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Introduction",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: Style.colors.app_black,
                                          fontFamily: Style.josefinsans),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        cIntroduction.toString(),
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            color: Style.colors.grey,
                                            fontFamily: Style.montserrat,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Container(
                          margin: const EdgeInsets.only(
                              top: 15.0, left: 16.0, right: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.info!,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: Style.colors.app_black,
                                    fontFamily: Style.josefinsans),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(
                              top: 5.0, left: 16.0, right: 16.0),
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.category!} : ",
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: Style.colors.grey,
                                          fontFamily: Style.montserrat,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      cCategory!,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Style.colors.grey,
                                          fontFamily: Style.montserrat,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.place_type!} : ",
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: Style.colors.grey,
                                          fontFamily: Style.montserrat,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      cPlaceType!,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Style.colors.grey,
                                          fontFamily: Style.montserrat,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(
                              top: 15.0, left: 16.0, right: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.contacts!,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: Style.josefinsans),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(
                              top: 5.0, left: 16.0, right: 16.0),
                          child: Row(
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.ph_no!} : ",
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Style.colors.grey,
                                    fontFamily: Style.montserrat,
                                    fontWeight: FontWeight.w400),
                              ),
                              InkWell(
                                onTap: () {
                                  cPlaceType == "Public places"
                                      ? null
                                      : redirectToCall(cMobileNumbers!);
                                },
                                child: Text(
                                  cMobileNumbers!,
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Style.colors.grey,
                                      fontFamily: Style.montserrat,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(
                              top: 5.0, left: 16.0, right: 16.0),
                          child: Row(
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.email_id!} : ",
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Style.colors.grey,
                                    fontFamily: Style.montserrat,
                                    fontWeight: FontWeight.w400),
                              ),
                              InkWell(
                                onTap: () {
                                  cPlaceType == "Public places"
                                      ? null
                                      : redirectMailPage(cEmailids!);
                                },
                                child: Text(
                                  cEmailids!,
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Style.colors.grey,
                                      fontFamily: Style.montserrat,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(
                              top: 5.0, left: 16.0, right: 16.0),
                          child: Row(
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.address!} : ",
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Style.colors.grey,
                                    fontFamily: Style.montserrat,
                                    fontWeight: FontWeight.w400),
                              ),
                              Flexible(
                                child: InkWell(
                                  onTap: () {
                                    double latitude = double.parse(
                                        nLatitude!); // Replace with your desired latitude
                                    double longitude = double.parse(
                                        nLongitude!); // Replace with your desired longitude
                                    cPlaceType == "Public places"
                                        ? null
                                        : launchGoogleMaps(latitude, longitude);
                                  },
                                  child: Text(
                                    cAddress!,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Style.colors.grey,
                                        fontFamily: Style.montserrat,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // InkWell(
                        //   onTap: (){
                        //
                        //   },
                        //   child: Container(
                        //     margin: EdgeInsets.only(left: 60, right: 60, top: 30),
                        //     width: MediaQuery.of(context).size.width / 2,
                        //     decoration: BoxDecoration(
                        //         gradient: LinearGradient(
                        //             begin: Alignment.centerLeft,
                        //             end: Alignment.centerRight,
                        //             colors: [Style.colors.logoRed,Style.colors.logoRed.withOpacity(0.6)]),
                        //         borderRadius:
                        //         BorderRadius.all(Radius.circular(10.0))),
                        //     padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        //     child: const Text('GET COUPON',
                        //         textAlign: TextAlign.center,
                        //         style: TextStyle(
                        //             fontSize: 16,
                        //             color: Colors.white,
                        //             fontWeight: FontWeight.w500)),
                        //   ),
                        // ),

                        // SizedBox(
                        //   height: 15.sp,
                        // ),
                        // Container(
                        //   margin:
                        //       EdgeInsets.only(top: 15.0, left: 16.0, right: 16.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Text(
                        //         'Reviews',
                        //         style: TextStyle(
                        //             fontSize: 16.0,
                        //             color: Style.colors.app_black,
                        //             fontWeight: FontWeight.w600,
                        //             fontFamily: Style.josefinsans),
                        //       ),
                        //       GestureDetector(
                        //         onTap: () {
                        //           Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                   builder: (context) =>
                        //                       ReviewsListScreen()));
                        //         },
                        //         child: Text(
                        //           'See all',
                        //           style: TextStyle(
                        //               fontSize: 16.0,
                        //               color: Style.colors.logoRed,
                        //               fontWeight: FontWeight.w600,
                        //               fontFamily: Style.josefinsans),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10.sp,
                        // ),
                        // ListView.builder(
                        //     shrinkWrap: true,
                        //     physics: NeverScrollableScrollPhysics(),
                        //     itemCount: 3,
                        //     itemBuilder: (BuildContext context, index) {
                        //       return Padding(
                        //         padding: EdgeInsets.only(
                        //           top: index == 0 ? 0 : 10.sp,
                        //         ),
                        //         child: Container(
                        //           width: double.infinity,
                        //           height: MediaQuery.of(context).size.height * .2,
                        //           decoration: BoxDecoration(
                        //               image: DecorationImage(
                        //                   fit: BoxFit.cover,
                        //                   image: AssetImage(
                        //                       Resources.assets.review))),
                        //         ),
                        //       );
                        //     }),

                        const SizedBox(
                          height: 100.0,
                        )
                      ],
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
                  )
                ],
              )),
        ));
  }

  storeDetailsApi() async {
    ProgressDialog().showLoaderDialog(context);

    try {
      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      final response = await dio.get(ApiProvider.getVendorDetails + widget.storeId,
          options: Options(contentType: Headers.formUrlEncodedContentType));

      debugPrint("response ${widget.storeId} $response");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        StoreDetailsModel storeDetailsModel = StoreDetailsModel.fromJson(map);
        debugPrint(
            "storedetailsmodel ${storeDetailsModel.jResult!.jAlbums.toString()}");
        if (storeDetailsModel.nStatus == 1) {
          setState(() {
            checkEmpty = false;

            nId = storeDetailsModel.jResult!.nId!;
            nLatitude = storeDetailsModel.jResult!.nLatitude;
            nLongitude = storeDetailsModel.jResult!.nLongitude;
            cPlaceType = storeDetailsModel.jResult!.cPlaceType;
            cIntroduction = storeDetailsModel.jResult!.cintroduction;
            cSinceType = storeDetailsModel.jResult!.cSinceType;
            nCityId = storeDetailsModel.jResult!.nCityId;
            cCity = storeDetailsModel.jResult!.cCity;
            nDistrictId = storeDetailsModel.jResult!.nDistrictId;
            cDistrict = storeDetailsModel.jResult!.cDistrict;
            nTownId = storeDetailsModel.jResult!.nTownId;
            cTown = storeDetailsModel.jResult!.cTown;
            nCategoryId = storeDetailsModel.jResult!.nCategoryId;
            cCategory = storeDetailsModel.jResult!.cCategory;
            cName = storeDetailsModel.jResult!.cName;
            cNameInThai = storeDetailsModel.jResult!.cNameInThai;
            cMobileNumbers = storeDetailsModel.jResult!.cMobileNumbers;
            cEmailids = storeDetailsModel.jResult!.cEmailids;
            cAddress = storeDetailsModel.jResult!.cAddress;
            cTerms = storeDetailsModel.jResult!.cTerms;

            if (storeDetailsModel.jResult!.jCurrentDay!.open!.isEmpty &&
                storeDetailsModel.jResult!.jCurrentDay!.close!.isEmpty) {
              currentOpenTime =
                  "${storeDetailsModel.jResult!.jCurrentDay!.days!} (Leave)";
              currentCloseTime = "";
              checkCurrentLeave = true;
            } else if (storeDetailsModel
                    .jResult!.jCurrentDay!.open!.isNotEmpty &&
                storeDetailsModel.jResult!.jCurrentDay!.close!.isEmpty) {
              currentOpenTime =
                  "${storeDetailsModel.jResult!.jCurrentDay!.days!} (Open - 24 Hours)";
              currentCloseTime = "";
              checkCurrentLeave = false;
            } else {
              currentOpenTime =
                  "Open - ${storeDetailsModel.jResult!.jCurrentDay!.open!}";
              currentCloseTime =
                  " - Close - ${storeDetailsModel.jResult!.jCurrentDay!.close!}";
              checkCurrentLeave = false;
            }

            // storeDetailsJImagesList.addAll(storeDetailsJResult1.jImages!);
          });

          updateStoreImage(
              storeDetailsModel.jResult!.jImages!,
              storeDetailsModel.jResult!.jAlbums!,
              storeDetailsModel.jResult!.jCoupons!,
              storeDetailsModel.jResult!.jOpeningHours!);

          ProgressDialog().dismissDialog(context);
        } else {
          setState(() {
            checkEmpty = true;
            emptyTxt = storeDetailsModel.cMessage!;
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

      // debugPrint(response);
    } catch (e) {
      debugPrint("Exception $e");
      ProgressDialog().dismissDialog(context);
      setState(() {
        checkEmpty = true;
        emptyTxt = "Bad Network Connection try again..";
      });
    }
  }

  openWhatsapp() async {
    var whatsapp = "+66810673747";
    var whatsappurlAndroid = "whatsapp://send?phone=$whatsapp&text=";
    var whatappurlIos = "https://wa.me/$whatsapp?text=${Uri.parse("")}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunch(whatappurlIos)) {
        await launch(whatappurlIos, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp no installed")));
      }
    } else {
      // android , web
      if (await canLaunch(whatsappurlAndroid)) {
        await launch(whatsappurlAndroid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp no installed")));
      }
    }
  }

  void _showAlert(context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var outputDate = "";
        if (storeDetailsJCoupons[index].till_date != null) {
          DateTime parseDate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(storeDetailsJCoupons[index].till_date!);
          var inputDate = DateTime.parse(parseDate.toString());
          var outputFormat = DateFormat('dd-MMM-yyyy');
          outputDate = outputFormat.format(inputDate);
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          insetPadding: const EdgeInsets.all(10),
          contentPadding: const EdgeInsets.all(0),
          clipBehavior: Clip.antiAlias,
          content: Container(
            width: 400,
            height: MediaQuery.of(context).size.height / 1.8,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color(0xFFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
            ),
            child: Stack(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Image.network(
                          storeDetailsJImagesList.isNotEmpty
                              ? storeDetailsJImagesList[0].cListingImg!
                              : '',
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
                Container(
                    child: ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 15.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 120.0,
                              // decoration:
                              // BoxDecoration(
                              //   border: Border.all(
                              //       color: Style.colors.white.withOpacity(0.3), width: 1),
                              //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              // ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Image.network(
                                    storeDetailsJCoupons[index].cImage!,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Text(cName!,
                                            style: const TextStyle(
                                                color: Color(0xff27b552),
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      flex: 3,
                                    ),
                                    Expanded(
                                      child: Visibility(
                                        visible: storeDetailsJCoupons[index]
                                                .c_coupon_code!
                                                .isNotEmpty
                                            ? true
                                            : false,
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                child: Text(
                                                  "Coupon",
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                      fontFamily:
                                                          Style.josefinsans),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Style.colors.white,
                                                      width: 1.5),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(2.0)),
                                                  color: Colors.yellow,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2.0,
                                                          bottom: 2.0,
                                                          right: 5.0,
                                                          left: 5.0),
                                                  child: Text(
                                                    storeDetailsJCoupons[index]
                                                        .c_coupon_code!,
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Style.colors.white,
                                                        fontFamily:
                                                            Style.josefinsans),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      flex: 2,
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        TextSpan(
                                            text: "Add: ",
                                            style: TextStyle(
                                                color: Style.colors.logoRed,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w500)),
                                        TextSpan(
                                            text: cAddress,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        TextSpan(
                                            text: "Tel: ",
                                            style: TextStyle(
                                                color: Style.colors.logoRed,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w500)),
                                        TextSpan(
                                            text: cMobileNumbers,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w500)),
                                        TextSpan(
                                            text:
                                                " (Must call to validate this coupon)",
                                            style: TextStyle(
                                                color: Style.colors.onHold,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 8.0, left: 10.0, right: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Style.colors.green, width: 3),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              const TextSpan(
                                  text: "VALIDITY: ",
                                  style: TextStyle(
                                      color: Color(0xff0012f8),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600)),
                              TextSpan(
                                  text: "Single Use till $outputDate",
                                  style: const TextStyle(
                                      color: Color(0xff0012f8),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 8.0, left: 10.0, right: 10.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Description:",
                                style: TextStyle(
                                    color: Style.colors.logoRed,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500)),
                            TextSpan(
                                text: storeDetailsJCoupons[index].cDescription!,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 8.0, left: 10.0, right: 10.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "T&C:",
                                style: TextStyle(
                                    color: Style.colors.logoRed,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500)),
                            TextSpan(
                                text: storeDetailsJCoupons[index].cTerms!,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        downloadCoupon(
                            nId!, storeDetailsJCoupons[index].nCouponId!);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 20.0, left: 10.0, right: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Style.colors.white.withOpacity(0.3),
                              width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                          color: Style.colors.logoRed,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.download_outlined,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: 5.0,
                                ),
                                child: Text(
                                    AppLocalizations.of(context)!.download!,
                                    style: TextStyle(
                                        fontFamily: Style.montserrat,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Style.colors.white.withOpacity(0.3),
                              width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                          color: Style.colors.logoRed,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: 5.0,
                                ),
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .call_to_confirm!,
                                    style: TextStyle(
                                        fontFamily: Style.montserrat,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  login() async {
    try {
      final result =
          await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);
      setState(() {
        UserProfile _userProfile = result.userProfile!;
        // user id -> result.userProfile?.userId
        // user name -> result.userProfile?.displayName
        // user avatar -> result.userProfile?.pictureUrl
        // etc...

        debugPrint('displayNamedisplayName ${_userProfile.displayName}');
      });
    } on PlatformException catch (e) {
      // Error handling.
      debugPrint(e.toString());
    }
  }

  logOut() async {
    try {
      await LineSDK.instance.logout();
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }

  downloadCoupon(String id, String couponId) async {
    ProgressDialog().showLoaderDialog(context);

    try {
      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);
      String userId = await SharedPreference().getUserId();

      var parameters = {"n_user": userId, "n_coupon": couponId, "n_vendor": id};

      debugPrint(parameters.toString());

      final response = await dio.post(ApiProvider.downloadCoupon,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      debugPrint("response $response");

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        DownloadCouponModel profileModel = DownloadCouponModel.fromJson(map);

        if (profileModel.nStatus == 1) {
          ProgressDialog().dismissDialog(context);
          dialogSuccess(profileModel.cMessage!);
          // ToastHandler.showToast(message: profileModel.cMessage!);
        } else {
          ProgressDialog().dismissDialog(context);
          dialogWarning(profileModel.cMessage!);
          // ToastHandler.showToast(message: profileModel.cMessage!);
        }
      } else {
        ProgressDialog().dismissDialog(context);
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      debugPrint("Exception $e");
      ProgressDialog().dismissDialog(context);
      ToastHandler.showToast(message: "Bad Network Connection try again..");
    }
  }

  dialogSuccess(String msg) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: msg,
      btnOkOnPress: () {
        // bookUpdateApi(book_id);
        Navigator.pop(context);
      },
    )..show();
  }

  dialogWarning(String msg) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: msg,
      btnCancelOnPress: () {},
      // btnOkOnPress: () {
      //   // bookUpdateApi(book_id);
      //   // Navigator.pop(context);
      // },
    )..show();
  }
}
