// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siamdealz/ResponseModule/DownloadedCouponListModel.dart';
import 'package:siamdealz/Utils/SharedPreference.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/ApiProvider/api_provider.dart';
import '../utils/ProgressDialog.dart';
import '../utils/check_internet.dart';
import '../utils/fab_menu_package.dart';
import '../utils/handler/toast_handler.dart';
import '../utils/style.dart';

class DownloadedCouponListScreen extends StatefulWidget {
  DownloadedCouponListScreenState createState() =>
      DownloadedCouponListScreenState();
}

class DownloadedCouponListScreenState
    extends State<DownloadedCouponListScreen> {
  StateSetter? stateSetter;

  bool checkInbox = false;
  bool inboxNoData = false;
  String noDataText = 'Data Not Found';

  int offset = 2;
  int limit = 10;
  int total = 0;
  bool loadmore = false;
  bool progressbar = true;

  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();

  List<DownloadedCouponListJResult> downloadCouponJResultList = [];
  String searchTxt = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    check().then((intenet) {
      if (intenet) {
        downloadedCouponListApi(searchTxt, "Search");
      } else {
        ToastHandler.showToast(
            message: "Please check your internet connection");
      }
    });
  }

  updateDownloadedList(
      List<DownloadedCouponListJResult> downloadCouponJResultList1) {
    setState(() {
      downloadCouponJResultList.addAll(downloadCouponJResultList1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: MyStyle.colors.white,
        appBar: AppBar(
          elevation: 4.0,
          leading: BackButton(),
          centerTitle: true,
          title: Text(
            "Downloaded Coupon",
            style: TextStyle(
                color: MyStyle.colors.logoRed,
                fontSize: 17.0,
                fontFamily: MyStyle.montserrat),
          ),
          iconTheme: IconThemeData(color: MyStyle.colors.logoRed),
          backgroundColor: Colors.white,
          //  brightness: Brightness.light,
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
              color: MyStyle.colors.white,
              labelColor: MyStyle.colors.white,
              labelBackgroundColor: Colors.green,
            ),
            // HawkFabMenuItem(
            //   label: 'Line',
            //   ontap: () {
            //     launch(('tel://${"+66810673747"}'));
            //   },
            //   icon: Image.asset("images/phone_call.png", height: 30, width: 30),
            //   color: MyStyle.colors.white,
            //   labelColor: MyStyle.colors.white,
            //   labelBackgroundColor: Colors.blue,
            // ),
          ],
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: EasyLoadMore(
              isFinished: downloadCouponJResultList.length >= total,
              onLoadMore: _loadMore,
              runOnEmptyResult: true,
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: ListView.builder(
                        itemCount: downloadCouponJResultList.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showAlert(context, index);
                            },
                            child: Card(
                              elevation: 4.0,
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 15.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(
                                        top: 15.0, bottom: 15.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                              alignment: Alignment.center,
                                              margin:
                                                  EdgeInsets.only(right: 5.0),
                                              // decoration:
                                              // BoxDecoration(
                                              //   border: Border.all(
                                              //       color: MyStyle.colors.white.withOpacity(0.3), width: 1),
                                              //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              // ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: AspectRatio(
                                                  aspectRatio: 1 / 1,
                                                  child: Image.network(
                                                    downloadCouponJResultList[
                                                            index]
                                                        .cCouponImage!,
                                                    filterQuality:
                                                        FilterQuality.high,
                                                  ),
                                                ),
                                              )),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                          width: 20,
                                                          child: Image.asset(
                                                            "images/voucher_icon.png",
                                                            width: 20.0,
                                                          )),
                                                      Flexible(
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10.0,
                                                                  right: 5.0),
                                                          child: Text(
                                                            downloadCouponJResultList[
                                                                    index]
                                                                .cCoupon!,
                                                            style: TextStyle(
                                                                fontSize: 17.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: MyStyle
                                                                    .colors
                                                                    .app_black,
                                                                fontFamily: MyStyle
                                                                    .josefinsans),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 8.0, right: 5.0),
                                                  height: 1.0,
                                                  color: MyStyle.colors.app_black
                                                      .withOpacity(0.1),
                                                ),
                                                // Container(
                                                //   margin: EdgeInsets.only(
                                                //       top: 10.0, right: 5.0),
                                                //   child: Row(
                                                //     children: [
                                                //       Text(
                                                //         "\u20B9 " +
                                                //             widget
                                                //                 .downloadCouponJResultList[
                                                //                     index]
                                                //                 .nCouponPrice! +
                                                //             " ",
                                                //         style: TextStyle(
                                                //             fontSize: 17.0,
                                                //             fontWeight:
                                                //                 FontWeight.w400,
                                                //             color: Style
                                                //                 .colors.green),
                                                //       ),
                                                //       Container(
                                                //         decoration: BoxDecoration(
                                                //           border: Border.all(
                                                //               color: Style
                                                //                   .colors.white
                                                //                   .withOpacity(
                                                //                       0.3),
                                                //               width: 1),
                                                //           borderRadius:
                                                //               BorderRadius.all(
                                                //                   Radius.circular(
                                                //                       8.0)),
                                                //           color: Colors.green,
                                                //         ),
                                                //         child: Padding(
                                                //           padding:
                                                //               const EdgeInsets
                                                //                       .only(
                                                //                   left: 10.0,
                                                //                   right: 10.0,
                                                //                   top: 5.0,
                                                //                   bottom: 5.0),
                                                //           child: Text(
                                                //             "Discount : " +
                                                //                 widget
                                                //                     .downloadCouponJResultList[
                                                //                         index]
                                                //                     .nDiscountPercentage! +
                                                //                 "%",
                                                //             style: TextStyle(
                                                //                 fontSize: 12.0,
                                                //                 fontWeight:
                                                //                     FontWeight
                                                //                         .w400,
                                                //                 color: Style
                                                //                     .colors
                                                //                     .white),
                                                //           ),
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),

                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 8.0, right: 5.0),
                                                  child: Text(
                                                    downloadCouponJResultList[
                                                            index]
                                                        .cDescription!,
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: MyStyle
                                                            .colors.app_black),
                                                  ),
                                                ),
                                                // SizedBox(
                                                //   height: 0.5.h,
                                                // ),
                                                // Text(
                                                //   offerMessage,
                                                //   style: MyStyle.textStyles.poppins(
                                                //     fontWeight: FontWeight.w600,
                                                //     color: Colors.green,
                                                //   ),
                                                // ),
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
                          );
                        }),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  downloadedCouponListApi(String searchTxt, String loadmore) async {
    if (progressbar) {
      ProgressDialog().showLoaderDialog(context);
    }

    // BaseOptions options = new BaseOptions(
    //   baseUrl: ApiProvider().Baseurl,
    //   connectTimeout: 5000,
    //   receiveTimeout: 3000,
    // );
    // Dio dio = new Dio(options);

    Dio dio = new Dio();
    // dio.options.connectTimeout = 5000; //5s
    // dio.options.receiveTimeout = 3000;

    String userId = await SharedPreference().getUserId();
    debugPrint("userid $userId");

    var parameters = {
      "n_user":userId,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
      "n_limit": 2,
      "n_page": 1,
    };
    debugPrint("request : " + parameters.toString());

    final response = await dio.post(ApiProvider.getDownloadCoupons,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: parameters);

    debugPrint("response : " + response.toString());
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.toString());
      DownloadedCouponListModel downloadedCouponListModel =
          DownloadedCouponListModel.fromJson(map);

      if (downloadedCouponListModel.nStatus == 1) {
        ProgressDialog().dismissDialog(context);
        setState(() {
          checkInbox = true;
          inboxNoData = false;
          if (downloadedCouponListModel.jResult!.isNotEmpty) {
            offset = downloadedCouponListModel.nTotalPage!;
            limit = limit;
            total = downloadedCouponListModel.nTotalRecords!;
          } else {
            checkInbox = false;
            inboxNoData = true;
            noDataText = "Record Not Found";
          }
        });
        if (loadmore == "Search") {
          downloadCouponJResultList.clear();
        }

        updateDownloadedList(downloadedCouponListModel.jResult!);
      } else {
        ProgressDialog().dismissDialog(context);
        setState(() {
          checkInbox = false;
          inboxNoData = true;
          noDataText = downloadedCouponListModel.cMessage!;
        });
      }
    } else {
      ProgressDialog().dismissDialog(context);
      setState(() {
        checkInbox = false;
        inboxNoData = true;
        noDataText = "Bad Network Connection try again..";
      });
    }
  }

  Future<bool> _loadMore() async {
    debugPrint("onLoadMore");
    await Future.delayed(Duration(seconds: 0, milliseconds: 100));
    // setState(() {
    //   progressbar = false;
    //   loadmore = false;
    // });
    downloadedCouponListApi(searchTxt, "loadmore");
    return false;
  }

  void _showAlert(context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var outputDate = "";
        if (downloadCouponJResultList[index].tillDate != null) {
          DateTime parseDate = new DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(downloadCouponJResultList[index].tillDate!);
          var inputDate = DateTime.parse(parseDate.toString());
          var outputFormat = DateFormat('dd-MMM-yyyy');
          outputDate = outputFormat.format(inputDate);
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          insetPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.all(0),
          clipBehavior: Clip.antiAlias,
          content: Container(
            width: 400,
            height: MediaQuery.of(context).size.height / 1.8,
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xFFFFFF),
              borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
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
                          downloadCouponJResultList[index].jImages!.isNotEmpty
                              ? downloadCouponJResultList[index]
                                  .jImages![0]
                                  .cListingImg!
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
                      margin:
                          EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 120.0,
                              // decoration:
                              // BoxDecoration(
                              //   border: Border.all(
                              //       color: MyStyle.colors.white.withOpacity(0.3), width: 1),
                              //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              // ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Image.network(
                                    downloadCouponJResultList[index]
                                        .cCouponImage!,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              alignment: Alignment.topCenter,
                            ),
                            flex: 1,
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                                downloadCouponJResultList[index]
                                                    .cName!,
                                                style: TextStyle(
                                                    color: Color(0xff27b552),
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                          flex: 3,
                                        ),
                                        Expanded(
                                          child: Visibility(
                                            visible:
                                                downloadCouponJResultList[index]
                                                        .cCouponCode!
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
                                                          fontFamily: MyStyle
                                                              .josefinsans),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: MyStyle
                                                              .colors.white,
                                                          width: 1.5),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  2.0)),
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
                                                        downloadCouponJResultList[
                                                                index]
                                                            .cCouponCode!,
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: MyStyle
                                                                .colors.white,
                                                            fontFamily: MyStyle
                                                                .josefinsans),
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
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: [
                                          TextSpan(
                                              text: "Add: ",
                                              style: TextStyle(
                                                  color: MyStyle.colors.logoRed,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w500)),
                                          TextSpan(
                                              text: downloadCouponJResultList[
                                                      index]
                                                  .cAddress,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: [
                                          TextSpan(
                                              text: "Tel: ",
                                              style: TextStyle(
                                                  color: MyStyle.colors.logoRed,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w500)),
                                          TextSpan(
                                              text: downloadCouponJResultList[
                                                      index]
                                                  .cMobileNumbers,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w500)),
                                          TextSpan(
                                              text:
                                                  " (Must call to validate this coupon)",
                                              style: TextStyle(
                                                  color: MyStyle.colors.onHold,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            flex: 3,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyStyle.colors.green, width: 3),
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                  text: "VALIDITY: ",
                                  style: TextStyle(
                                      color: Color(0xff0012f8),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600)),
                              TextSpan(
                                  text: "Single Use till " + outputDate,
                                  style: TextStyle(
                                      color: Color(0xff0012f8),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Description:",
                                style: TextStyle(
                                    color: MyStyle.colors.logoRed,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500)),
                            TextSpan(
                                text: downloadCouponJResultList[index]
                                    .cDescription,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "T&C:",
                                style: TextStyle(
                                    color: MyStyle.colors.logoRed,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500)),
                            TextSpan(
                                text: downloadCouponJResultList[index].cTerms,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500)),
                          ],
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
            .showSnackBar(SnackBar(content: new Text("WhatsApp is not installed on the device. Please install whatsapp")));
      }
    } else {
      // android , web
      // if (await canLaunch(whatsappURl_android)) {
      //   await launch(whatsappURl_android);
      // } else {
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: new Text("WhatsApp is not installed on the device. Please install whatsapp")));
      // }
      await launch(
          "https://wa.me/${whatsapp}?text=");
    }
  }
}
