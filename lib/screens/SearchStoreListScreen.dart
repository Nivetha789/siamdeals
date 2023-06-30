// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import 'package:siamdealz/screens/StoreDetailsScreen.dart';
import 'package:siamdealz/screens/categorylist.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ResponseModule/BannerModel.dart';
import '../ResponseModule/CategoryModel.dart';
import '../ResponseModule/DemographicModel/DemographicModel.dart';
import '../ResponseModule/SearchVendorModule/SearchVendorModel.dart';
import '../core/ApiProvider/api_provider.dart';
import '../helper/AppLocalizations.dart';
import '../utils/ProgressDialog.dart';
import '../utils/check_internet.dart';
import '../utils/fab_menu_package.dart';
import '../utils/handler/toast_handler.dart';
import '../utils/style.dart';
import 'CategoryScreen.dart';
import 'top10democracy.dart';

class SearchStoreListScreen extends StatefulWidget {
  int categoryId = 0;
  final cityid;
  String categoryName = "";
  bool checkCategory = false;

  SearchStoreListScreen(
      this.categoryId, this.cityid, this.categoryName, this.checkCategory);

  SearchStoreListScreenState createState() => SearchStoreListScreenState();
}

class SearchStoreListScreenState extends State<SearchStoreListScreen> {
  // Sub Category List
  final searchCategoryController = TextEditingController();
  List<CategoryJResult> subCategoryDataList = [];
  List<CategoryJResult> searchSubCategoryList = [];
  String subCategoryId = "";
  String subCategoryName = '';
  bool checkSubCategoryListFirst = true;

  final searchController = TextEditingController();
  bool checkSubCategoryEmpty = false;
  String emptySubCategoryTxt = "";

  StateSetter? stateSetter;

  bool checkInbox = false;
  bool inboxNoData = false;
  String noDataText = 'Data Not Found';

  int offset = 0;
  int limit = 10;
  int total = 0;
  bool loadmore = false;
  bool progressbar = true;

  String searchTxt = "";
  bool searchClearImg = false;
  bool searchEditingComplete = false;

  int categoryId = 0;
  String categoryName = "";
  String searchHint = "";

  List<SearchVendorJResult> searchVendorJResultList = [];

  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();

  bool checkBanner = false;
  List<BannerJResult> bannerJResultList = [];
  int pageIndex = 0;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    categoryId = widget.categoryId;

    if (widget.checkCategory) {
      categoryName = widget.categoryName;
      searchHint = "Search";
    } else {
      categoryName = "Search";
      searchHint = "Search for stores ,products,brands,dishes..";
    }

    check().then((intenet) {
      if (intenet) {
        print("Sdfsdfskdjfhskdfjh ${widget.checkCategory}");
        if (widget.checkCategory) {
          getSubCategoryList();

          categoryName = widget.categoryName;
          searchHint = "Search";
        } else {
          categoryName = "Search";
          searchHint = "Search for stores ,products,brands,dishes..";
        }

        searchVendorListApi(searchTxt, "Search");
      } else {
        ToastHandler.showToast(
            message: "Please check your internet connection");
      }
    });
  }

  subCategoryListener(String text) {
    if (text.isNotEmpty) {
      setState(() {
        searchSubCategoryList = subCategoryDataList
            .where((u) =>
                (u.cCategory!.toLowerCase().contains(text.toLowerCase()) ||
                    u.cCategory!.toLowerCase().contains(text.toLowerCase())))
            .toList();

        // community = searchCommunityController.text;
      });
    } else {
      setState(() {
        searchSubCategoryList.clear();
        searchSubCategoryList.addAll(subCategoryDataList);
      });
    }
  }

  updateSubCategoryText(String id, String text) {
    stateSetter!(() {
      subCategoryId = id;
      subCategoryName = text;
      setState(() {
        for (int i = 0; i < subCategoryDataList.length; i++) {
          if (subCategoryDataList[i].addRemove!) {
            subCategoryDataList[i].addRemove = false;
          }
        }
        // subCategoryDataList[0].addRemove = true;

        categoryId = int.parse(id);
      });

      offset = 0;
      limit = 10;

      check().then((intenet) {
        if (intenet) {
          searchVendorListApi(searchTxt, "Search");
        } else {
          ToastHandler.showToast(
              message: "Please check your internet connection");
        }
      });
    });
  }

  //country
  SubCategoryBottomList(context) {
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
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .select_category!,
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
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Icon(Icons.cancel_sharp,
                                        size: 20.0, color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 10.0),
                          height: 40.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xff495271).withOpacity(0.4),
                                width: 0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin:
                                const EdgeInsets.only(top: 10.0, bottom: 5.0),
                            child: TextFormField(
                              autofocus: false,
                              controller: searchCategoryController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: AppLocalizations.of(context)!
                                    .search_category!,
                                hintStyle: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff495271)
                                        .withOpacity(0.3)
                                        .withOpacity(0.7)),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 18.0,
                                  color:
                                      const Color(0xff495271).withOpacity(0.3),
                                ),
                              ),
                              style: TextStyle(
                                  color: const Color(0xff495271),
                                  fontFamily: Style.sfproddisplay),
                              onChanged: (text) {
                                setState(() {
                                  subCategoryListener(text);
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 20.0),
                          child: ListView.builder(
                              itemCount: searchSubCategoryList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, postion) {
                                // if (checkSubCaste) {
                                //   if (getMyExpectationsInfoDataList[0]
                                //       .subsectList
                                //       .length >
                                //       0) {
                                //     for (int i = 0;
                                //     i <
                                //         getMyExpectationsInfoDataList[0]
                                //             .subsectList
                                //             .length;
                                //     i++) {
                                //       if (searchSubCastDataList[postion].id ==
                                //           getMyExpectationsInfoDataList[0]
                                //               .subsectList[i]
                                //               .id) {
                                //         searchSubCastDataList[postion]
                                //             .addremove = true;
                                //       }
                                //     }
                                //   }
                                // }

                                // if (widget.checkEdit!) {
                                //   if (getHobbiesDataList[0].hobbiesList.length > 0) {
                                //     for (int i = 0; i < getHobbiesDataList[0].hobbiesList.length; i++) {
                                //       if (searchhobbiesList[postion].id == getHobbiesDataList[0].hobbiesList[i].id) {
                                //         searchhobbiesList[postion].addremove = true;
                                //       }
                                //     }
                                //   }
                                // }

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      debugPrint("PAVITHRAMANOHARAN");
                                      searchCategoryController.text = "";
                                      updateSubCategoryText(
                                          searchSubCategoryList[postion].nId!,
                                          searchSubCategoryList[postion]
                                              .cCategory!);

                                      Navigator.pop(context);
                                      // searchCategoryDataList[postion].addremove =
                                      // !searchCategoryDataList[postion]
                                      //     .addremove!;
                                      // addRemoveCountry(
                                      //     searchCategoryDataList[postion]
                                      //         .addremove!,
                                      //     postion);
                                    });
                                  },
                                  child: Container(
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
                                              searchSubCategoryList[postion]
                                                      .cCategory!
                                                      .isNotEmpty
                                                  ? searchSubCategoryList[
                                                          postion]
                                                      .cCategory!
                                                  : "",
                                              style: TextStyle(
                                                  color: Colors.black87,
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

  updateSubCategoryList(List<CategoryJResult> subCategoryDataList1) {
    subCategoryDataList.clear();
    setState(() {
      subCategoryDataList.addAll(subCategoryDataList1);
    });

    if (!checkSubCategoryListFirst) {
      SubCategoryBottomList(context);
    }
  }

  updateVendorList(List<SearchVendorJResult> searchVendorJResultList1) {
    setState(() {
      searchVendorJResultList.addAll(searchVendorJResultList1);
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
          leading: const BackButton(),
          centerTitle: !widget.checkCategory,
          title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: subCategoryName.isEmpty
                  ? Text(
                      categoryName,
                      style: TextStyle(
                          color: Style.colors.logoRed,
                          fontSize: 17.0,
                          fontFamily: Style.montserrat),
                    )
                  : Text(
                      "$categoryName($subCategoryName)",
                      style: TextStyle(
                          color: Style.colors.logoRed,
                          fontSize: 17.0,
                          fontFamily: Style.montserrat),
                    )),
          iconTheme: IconThemeData(color: Style.colors.logoRed),
          backgroundColor: Colors.white,
          //    brightness: Brightness.light,
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
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  stateSetter = setState;
                  return Column(
                    children: [
                      Container(
                        // flex: 1,
                        child: Container(
                          margin:
                              const EdgeInsets.only(left: 16.0, right: 16.0),
                          alignment: Alignment.center,
                          height: 70,
                          child: Container(
                            height: 50.0,
                            alignment: Alignment.topLeft,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6)),
                                border: Border.all(
                                    width: 1,
                                    color: const Color(0xffC0C0C0)
                                        .withOpacity(0.7))),
                            child: Row(
                              children: [
                                Expanded(
                                  // width: 100,
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        TextFormField(
                                          autofocus: false,
                                          textInputAction:
                                              TextInputAction.search,
                                          keyboardType: TextInputType.text,
                                          controller: searchController,
                                          textAlign: TextAlign.start,
                                          // inputFormatters: <TextInputFormatter>[
                                          //   FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                                          // ],
                                          decoration: InputDecoration(
                                            // labelText: "Search",
                                            // labelStyle: TextStyle(
                                            //   fontSize: 14.0,
                                            //   color: Color(0xff495271),
                                            // ),
                                            hintText: searchHint,
                                            hintStyle: TextStyle(
                                                fontSize: 14.0,
                                                fontFamily: Style.montserrat,
                                                fontWeight: FontWeight.w500),
                                            border: InputBorder.none,
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xff495271),
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500),
                                          onChanged: (String text) {
                                            setState(() {
                                              searchTxt = text;
                                              if (searchTxt.isEmpty) {
                                                searchClearImg = false;
                                                offset = 0;
                                                limit = 10;

                                                check().then((intenet) {
                                                  if (intenet) {
                                                    searchVendorListApi(
                                                        searchTxt, "Search");
                                                  } else {
                                                    ToastHandler.showToast(
                                                        message:
                                                            "Please check your internet connection");
                                                  }
                                                });
                                              } else {
                                                searchClearImg = true;
                                              }
                                            });
                                          },
                                        ),
                                        Visibility(
                                          visible: searchClearImg,
                                          child: InkWell(
                                            onTap: () {
                                              searchController.text = "";
                                              searchTxt = "";
                                              searchClearImg = false;

                                              searchClearImg = false;
                                              offset = 0;
                                              limit = 10;

                                              check().then((intenet) {
                                                if (intenet) {
                                                  searchVendorListApi(
                                                      searchTxt, "Search");
                                                } else {
                                                  ToastHandler.showToast(
                                                      message:
                                                          "Please check your internet connection");
                                                }
                                              });

                                              FocusScopeNode currentFocus =
                                                  FocusScope.of(context);
                                              if (!currentFocus
                                                      .hasPrimaryFocus &&
                                                  currentFocus.focusedChild !=
                                                      null) {
                                                currentFocus.focusedChild!
                                                    .unfocus();
                                              }
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: 30.0,
                                              height: 30.0,
                                              margin: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: Icon(
                                                Icons.cancel_outlined,
                                                color: Style.colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                    width: 1,
                                    color: const Color(0xffC0C0C0)
                                        .withOpacity(0.7)),
                                Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        // searchController.text = "";
                                        // searchTxt = "";

                                        if (searchTxt.isNotEmpty) {
                                          offset = 0;
                                          limit = 10;

                                          check().then((intenet) {
                                            if (intenet) {
                                              searchVendorListApi(
                                                  searchTxt, "Search");
                                            } else {
                                              ToastHandler.showToast(
                                                  message:
                                                      "Please check your internet connection");
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: searchTxt.isEmpty
                                              ? Icon(
                                                  Icons.search_rounded,
                                                  color: const Color(0xffC0C0C0)
                                                      .withOpacity(0.7),
                                                )
                                              : Icon(
                                                  Icons.search_rounded,
                                                  color: Style.colors.logoRed,
                                                )),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Visibility(
                      //   visible: checkBanner,
                      //   child: bannerJResultList.isNotEmpty
                      //       ? Expanded(
                      //           flex: 4,
                      //           child: Container(
                      //             child: Column(
                      //               children: [
                      //                 Container(
                      //                   child: Text(
                      //                       AppLocalizations.of(context)!
                      //                           .city_spotLight!,
                      //                       style: TextStyle(
                      //                           fontSize: 16.0,
                      //                           fontWeight: FontWeight.w600,
                      //                           fontFamily: Style.josefinsans)),
                      //                   margin: const EdgeInsets.only(
                      //                       top: 15.0, left: 16.0),
                      //                   alignment: Alignment.centerLeft,
                      //                 ),
                      //                 Container(
                      //                   margin: const EdgeInsets.only(top: 15.0),
                      //                   child: CarouselSlider.builder(
                      //                     itemCount: bannerJResultList.length,
                      //                     itemBuilder: (BuildContext context,
                      //                         int index, int realIdx) {
                      //                       return Card(
                      //                         shape: RoundedRectangleBorder(
                      //                             borderRadius:
                      //                                 BorderRadius.circular(20)),
                      //                         child: SizedBox(
                      //                           width: 330.0,
                      //                           height: 200.0,
                      //                           child: SizedBox(
                      //                             child: Image.network(
                      //                               bannerJResultList[index]
                      //                                   .cBannerImage!,
                      //                               fit: BoxFit.fitWidth,
                      //                             ),
                      //                             width: MediaQuery.of(context)
                      //                                 .size
                      //                                 .width,
                      //                           ),
                      //                         ),
                      //                         clipBehavior: Clip.antiAlias,
                      //                       );
                      //                     },
                      //                     options: new CarouselOptions(
                      //                         autoPlay:
                      //                             bannerJResultList.length > 0
                      //                                 ? true
                      //                                 : false,
                      //                         viewportFraction: 1.0,
                      //                         height: 200,
                      //                         enlargeCenterPage: false,
                      //                         enableInfiniteScroll: false,
                      //                         onPageChanged: (index, reason) {
                      //                           setState(() {
                      //                             pageIndex = index;
                      //                             // _current = index;
                      //                           });
                      //                         }),
                      //                   ),
                      //                 ),
                      //                 Container(
                      //                   child: CarouselIndicator(
                      //                     count: bannerJResultList.length,
                      //                     index: pageIndex,
                      //                     color:
                      //                         Style.colors.grey.withOpacity(0.3),
                      //                     activeColor: Style.colors.logoRed,
                      //                     width: 10.0,
                      //                   ),
                      //                   margin: const EdgeInsets.only(top: 5.0),
                      //                 )
                      //               ],
                      //             ),
                      //           ),
                      //         )
                      //       : Container(),
                      // ),
                      demographicJResultList.isEmpty
                          ? const SizedBox(height: 0)
                          : Container(
                              color: Colors.grey.withOpacity(0.3),
                              width: MediaQuery.of(context).size.width,
                              height: 1.0,
                              margin: const EdgeInsets.only(top: 10.0),
                            ),
                      demographicJResultList.isEmpty
                          ? const SizedBox(height: 0)
                          : Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              height: 90.0,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 16.0, right: 16.0, top: 10.0),
                                    child: ListView.builder(
                                        itemCount:
                                            demographicJResultList.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, postion) {
                                          return Card(
                                            elevation: 2,
                                            color: Style.colors.logoRed,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.sp),
                                            ),
                                            margin: const EdgeInsets.only(
                                                right: 10.0, bottom: 10.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Top10Democracy(
                                                                id: demographicJResultList[
                                                                        postion]
                                                                    .nId!,
                                                                cityid: widget
                                                                    .cityid,
                                                                name: demographicJResultList[
                                                                        postion]
                                                                    .cDemographic!)));

                                                setState(() {});
                                              },
                                              child: Container(
                                                width: 120.0,
                                                margin: const EdgeInsets.only(
                                                    left: 10.0),
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topRight:
                                                                Radius.circular(
                                                                    5.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    5.0))),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10.0,
                                                                right: 10.0),
                                                        child: Text(
                                                            demographicJResultList[
                                                                    postion]
                                                                .cDemographic!,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 13.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily: Style
                                                                    .montserrat)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                      categoryJResultList.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: 20.0, left: 16.0, right: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .category!,
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      Style.josefinsans)),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CategoryListScreen(
                                                              widget.cityid)));
                                            },
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .view_all!,
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Style.colors.logoRed,
                                                      fontFamily:
                                                          Style.josefinsans)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 25.h,
                                    margin: const EdgeInsets.only(top: 15.0),
                                    child: GridView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: .0.sp,
                                          mainAxisSpacing: 0.sp,
                                          childAspectRatio: .60.sp,
                                        ),
                                        itemCount: categoryJResultList.length,
                                        physics: const ClampingScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                right: 7.sp, bottom: 7.sp),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CategoryStoreListScreen(
                                                                int.parse(
                                                                    categoryJResultList[
                                                                            index]
                                                                        .nId!),
                                                                widget.cityid,
                                                                categoryJResultList[
                                                                        index]
                                                                    .cCategory!,
                                                                true)));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7.sp),
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: Style.colors.grey
                                                            .withOpacity(.2))),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 5.5.h,
                                                      width: 13.w,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      30.sp)),
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: NetworkImage(
                                                                  categoryJResultList[
                                                                          index]
                                                                      .cCategoryImage!))),
                                                    ),
                                                    SizedBox(
                                                      height: 1.h,
                                                    ),
                                                    Text(
                                                        categoryJResultList[
                                                                index]
                                                            .cCategory!,
                                                        style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily: Style
                                                                .montserrat)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),

                                  // Visibility(
                                  //   visible: checkBanner,
                                  //   child: Column(
                                  //     children: [
                                  //       bannerJResultList.isNotEmpty
                                  //           ? Container(
                                  //               margin: const EdgeInsets.only(
                                  //                   top: 15.0),
                                  //               alignment: Alignment.centerLeft,
                                  //               child: Text(
                                  //                   AppLocalizations.of(context)!
                                  //                       .city_spotLight!,
                                  //                   style: TextStyle(
                                  //                       fontSize: 16.0,
                                  //                       fontWeight: FontWeight.w600,
                                  //                       fontFamily:
                                  //                           Style.josefinsans)),
                                  //             )
                                  //           : Container(),
                                  //       bannerJResultList.isNotEmpty
                                  //           ? Container(
                                  //               margin: const EdgeInsets.only(
                                  //                   top: 15.0),
                                  //               child: CarouselSlider.builder(
                                  //                 itemCount:
                                  //                     bannerJResultList.length,
                                  //                 itemBuilder:
                                  //                     (BuildContext context,
                                  //                         int index, int realIdx) {
                                  //                   return Card(
                                  //                     shape: RoundedRectangleBorder(
                                  //                         borderRadius:
                                  //                             BorderRadius.circular(
                                  //                                 20)),
                                  //                     clipBehavior: Clip.antiAlias,
                                  //                     child: SizedBox(
                                  //                       width: 300.0,
                                  //                       height: 200.0,
                                  //                       child: SizedBox(
                                  //                         width:
                                  //                             MediaQuery.of(context)
                                  //                                 .size
                                  //                                 .width,
                                  //                         child: bannerJResultList[
                                  //                                         index]
                                  //                                     .cBannerLink ==
                                  //                                 null
                                  //                             ? Image.network(
                                  //                                 bannerJResultList[
                                  //                                         index]
                                  //                                     .cBannerImage!,
                                  //                                 fit: BoxFit
                                  //                                     .fitWidth,
                                  //                               )
                                  //                             : InkWell(
                                  //                                 onTap: () async {
                                  //                                   // debugPrint(
                                  //                                   //     "Dfsdjfhsdjkfhsdjfdsf ${bannerJResultList[index].cBannerLink!}");
                                  //                                   // String
                                  //                                   //     url =
                                  //                                   //     bannerJResultList[index]
                                  //                                   //         .cBannerLink;
                                  //                                   // var url =
                                  //                                   //     bannerJResultList[index]
                                  //                                   //         .cBannerLink!;
                                  //                                   // if (await canLaunch(
                                  //                                   //     url)) {
                                  //                                   //   await launch(
                                  //                                   //       url);
                                  //                                   // } else {
                                  //                                   //   throw 'Could not launch $url';
                                  //                                   // }
                                  //                                   // openbannerlaunchurl(
                                  //                                   //     bannerJResultList[index]
                                  //                                   //         .cBannerLink!);
                                  //                                 },
                                  //                                 child:
                                  //                                     Image.network(
                                  //                                   bannerJResultList[
                                  //                                           index]
                                  //                                       .cBannerImage!,
                                  //                                   fit: BoxFit
                                  //                                       .fitWidth,
                                  //                                 ),
                                  //                               ),
                                  //                       ),
                                  //                     ),
                                  //                   );
                                  //                 },
                                  //                 options: CarouselOptions(
                                  //                     autoPlay: bannerJResultList
                                  //                             .isNotEmpty
                                  //                         ? true
                                  //                         : false,
                                  //                     viewportFraction: 1.0,
                                  //                     height: 200,
                                  //                     enlargeCenterPage: false,
                                  //                     enableInfiniteScroll: false,
                                  //                     onPageChanged:
                                  //                         (index, reason) {
                                  //                       setState(() {
                                  //                         pageIndex = index;
                                  //                         // _current = index;
                                  //                       });
                                  //                     }),
                                  //               ),
                                  //             )
                                  //           : Container(),
                                  //       bannerJResultList.isNotEmpty
                                  //           ? Container(
                                  //               margin:
                                  //                   const EdgeInsets.only(top: 5.0),
                                  //               child: CarouselIndicator(
                                  //                 count: bannerJResultList.length,
                                  //                 index: pageIndex,
                                  //                 color: Style.colors.grey
                                  //                     .withOpacity(0.3),
                                  //                 activeColor: Style.colors.logoRed,
                                  //                 width: 10.0,
                                  //               ),
                                  //             )
                                  //           : Container(),
                                  //     ],
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: 10.sp,
                                  // ),
                                  SizedBox(
                                    height: 15.sp,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      particularDemocracylist.isEmpty
                          ? Container()
                          : Container(
                              height: 300,
                              // flex: 1,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  // physics: const NeverScrollableScrollPhysics(),
                                  itemCount: particularDemocracylist.length,
                                  itemBuilder: (BuildContext context, index) {
                                    String openTime = "";
                                    String closeTime = "";
                                    bool checkLeave = false;

                                    if (particularDemocracylist[index]
                                                .jCurrentDay!
                                                .open ==
                                            null &&
                                        particularDemocracylist[index]
                                                .jCurrentDay!
                                                .close ==
                                            null) {
                                      openTime = " (Leave)";
                                      closeTime = "";
                                      checkLeave = true;
                                    } else if (particularDemocracylist[index]
                                                .jCurrentDay!
                                                .open !=
                                            null &&
                                        particularDemocracylist[index]
                                                .jCurrentDay!
                                                .close ==
                                            null) {
                                      openTime = " (Open - 24 Hours)";
                                      closeTime = "";
                                      checkLeave = false;
                                    } else {
                                      openTime =
                                          "(Open - ${particularDemocracylist[index].jCurrentDay!.open}";
                                      closeTime =
                                          " - Close - ${particularDemocracylist[index].jCurrentDay!.close})";
                                      checkLeave = false;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12.0, right: 8, top: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StoreDetailsScreen(
                                                particularDemocracylist[index]
                                                    .nId!,
                                                particularDemocracylist[index]
                                                    .cName!,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.sp)),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 20.5.h,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                10.sp),
                                                        topRight:
                                                            Radius.circular(
                                                                10.sp)),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            particularDemocracylist[
                                                                        index]
                                                                    .jImages!
                                                                    .isNotEmpty
                                                                ? particularDemocracylist[
                                                                        index]
                                                                    .jImages![0]
                                                                    .cListingImg!
                                                                : ''))),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0,
                                                    right: 8,
                                                    top: 0,
                                                    bottom: 13),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 15.0),
                                                          child: Text(
                                                            particularDemocracylist[
                                                                    index]
                                                                .cName!,
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                color: Style
                                                                    .colors
                                                                    .app_black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                        // Container(
                                                        //   margin:
                                                        //       const EdgeInsets
                                                        //               .only(
                                                        //           top:
                                                        //               15.0),
                                                        //   child: Text(
                                                        //     "${particularDemocracylist[index].nkilometre}KM",
                                                        //     style: TextStyle(
                                                        //         fontSize:
                                                        //             15.0,
                                                        //         color: Style
                                                        //             .colors
                                                        //             .app_black,
                                                        //         fontWeight:
                                                        //             FontWeight
                                                        //                 .w500),
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 5.0),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "${AppLocalizations.of(context)!.category!} : ",
                                                            style: TextStyle(
                                                                fontSize: 13.0,
                                                                color: Style
                                                                    .colors
                                                                    .app_black,
                                                                fontFamily: Style
                                                                    .montserrat,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                          Text(
                                                            particularDemocracylist[
                                                                        index]
                                                                    .cCategory!
                                                                    .isNotEmpty
                                                                ? particularDemocracylist[
                                                                        index]
                                                                    .cCategory!
                                                                : " - ",
                                                            style: TextStyle(
                                                                fontSize: 13.0,
                                                                color: Style
                                                                    .colors
                                                                    .app_black,
                                                                fontFamily: Style
                                                                    .montserrat,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 5.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.access_time,
                                                            color: checkLeave
                                                                ? Colors.red
                                                                : Style.colors
                                                                    .green,
                                                            size: 18.0,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 2.0),
                                                            child: Text(
                                                              particularDemocracylist[
                                                                          index]
                                                                      .jCurrentDay!
                                                                      .days! +
                                                                  openTime,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      13.0,
                                                                  color: checkLeave
                                                                      ? Colors
                                                                          .red
                                                                      : Style
                                                                          .colors
                                                                          .green,
                                                                  fontFamily: Style
                                                                      .montserrat,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 100,
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 2.0),
                                                            child: Text(
                                                              closeTime,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      13.0,
                                                                  color: checkLeave
                                                                      ? Colors
                                                                          .red
                                                                      : Style
                                                                          .colors
                                                                          .green,
                                                                  fontFamily: Style
                                                                      .montserrat,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                        ],
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
                                  }),
                            ),

                      // subCategoryDataList.isNotEmpty
                      //     ? Expanded(
                      //         flex: 1,
                      //         child: Container(
                      //           child: Container(
                      //             width: MediaQuery.of(context).size.width,
                      //             margin: const EdgeInsets.only(
                      //                 left: 11.0, right: 11.0),
                      //             child: Container(
                      //               child: ListView(
                      //                 scrollDirection: Axis.horizontal,
                      //                 children: [
                      //                   Container(
                      //                     child: ListView.builder(
                      //                         itemCount:
                      //                             subCategoryDataList.length > 4
                      //                                 ? 3
                      //                                 : 0,
                      //                         shrinkWrap: true,
                      //                         scrollDirection: Axis.horizontal,
                      //                         itemBuilder:
                      //                             (BuildContext context, index) {
                      //                           return GestureDetector(
                      //                             onTap: () {
                      //                               setState(() {
                      //                                 if (subCategoryDataList[index]
                      //                                     .addRemove!) {
                      //                                   searchVendorJResultList
                      //                                       .clear();
                      //                                   categoryId =
                      //                                       widget.categoryId;
                      //                                   subCategoryDataList[index]
                      //                                           .addRemove =
                      //                                       !subCategoryDataList[
                      //                                               index]
                      //                                           .addRemove!;
                      //                                 } else {
                      //                                   for (int i = 0;
                      //                                       i <
                      //                                           subCategoryDataList
                      //                                               .length;
                      //                                       i++) {
                      //                                     if (subCategoryDataList[i]
                      //                                         .addRemove!) {
                      //                                       subCategoryDataList[i]
                      //                                           .addRemove = false;
                      //                                     }
                      //                                   }
                      //                                   subCategoryDataList[index]
                      //                                       .addRemove = true;

                      //                                   categoryId = int.parse(
                      //                                       subCategoryDataList[
                      //                                               index]
                      //                                           .nId!);
                      //                                 }
                      //                               });

                      //                               offset = 0;
                      //                               limit = 10;

                      //                               check().then((intenet) {
                      //                                 if (intenet) {
                      //                                   searchVendorListApi(
                      //                                       searchTxt, "Search");
                      //                                 } else {
                      //                                   ToastHandler.showToast(
                      //                                       message:
                      //                                           "Please check your internet connection");
                      //                                 }
                      //                               });
                      //                             },
                      //                             child: Container(
                      //                               margin: const EdgeInsets.only(
                      //                                   left: 5.0,
                      //                                   right: 5.0,
                      //                                   top: 10.0,
                      //                                   bottom: 10.0),
                      //                               decoration: BoxDecoration(
                      //                                   border:
                      //                                       subCategoryDataList[index]
                      //                                               .addRemove!
                      //                                           ? Border.all(
                      //                                               color:
                      //                                                   Style.colors
                      //                                                       .logoRed)
                      //                                           : Border.all(
                      //                                               color: Style
                      //                                                   .colors
                      //                                                   .app_black),
                      //                                   color: subCategoryDataList[
                      //                                               index]
                      //                                           .addRemove!
                      //                                       ? Style.colors.logoRed
                      //                                           .withOpacity(0.2)
                      //                                       : Colors.white,
                      //                                   borderRadius:
                      //                                       BorderRadius.circular(
                      //                                           30.0)),
                      //                               child: Container(
                      //                                 child: Column(
                      //                                   mainAxisAlignment:
                      //                                       MainAxisAlignment
                      //                                           .spaceEvenly,
                      //                                   children: [
                      //                                     Padding(
                      //                                       padding:
                      //                                           const EdgeInsets
                      //                                                   .only(
                      //                                               left: 15.0,
                      //                                               right: 15.0),
                      //                                       child: Text(
                      //                                         subCategoryDataList[
                      //                                                 index]
                      //                                             .cCategory!,
                      //                                         style: TextStyle(
                      //                                             color: Style
                      //                                                 .colors
                      //                                                 .app_black,
                      //                                             fontSize: 12.0,
                      //                                             fontWeight:
                      //                                                 FontWeight
                      //                                                     .w500,
                      //                                             fontFamily: Style
                      //                                                 .montserrat),
                      //                                       ),
                      //                                     ),
                      //                                   ],
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                           );
                      //                         }),
                      //                   ),
                      //                   InkWell(
                      //                     onTap: () {
                      //                       searchSubCategoryList.clear();
                      //                       setState(() {
                      //                         searchSubCategoryList
                      //                             .addAll(subCategoryDataList);
                      //                       });
                      //                       SubCategoryBottomList(context);
                      //                     },
                      //                     child: Container(
                      //                       child: Text(
                      //                         AppLocalizations.of(context)!
                      //                             .view_all!,
                      //                         style: TextStyle(
                      //                             color: Style.colors.logoRed,
                      //                             fontSize: 12.0,
                      //                             fontWeight: FontWeight.w500,
                      //                             fontFamily: Style.montserrat),
                      //                         textAlign: TextAlign.center,
                      //                       ),
                      //                       alignment: Alignment.center,
                      //                       margin:
                      //                           const EdgeInsets.only(left: 10.0),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       )
                      //     : Container(),

                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            // Visibility(
                            //   visible: checkInbox,
                            //   child: Container(
                            //     child: LoadMore(
                            //       isFinish: searchVendorJResultList.length >= total,
                            //       onLoadMore: _loadMore,
                            //       whenEmptyLoad: false,
                            //       delegate: const DefaultLoadMoreDelegate(),
                            //       textBuilder: DefaultLoadMoreTextBuilder.english,
                            //       child: ListView(
                            //         children: [
                            //           ListView.builder(
                            //               shrinkWrap: true,
                            //               physics:
                            //                   const NeverScrollableScrollPhysics(),
                            //               itemCount: searchVendorJResultList.length,
                            //               itemBuilder:
                            //                   (BuildContext context, index) {
                            //                 String openTime = "";
                            //                 String closeTime = "";
                            //                 bool checkLeave = false;

                            //                 if (searchVendorJResultList[index]
                            //                         .jCurrentDay!
                            //                         .open!
                            //                         .isEmpty &&
                            //                     searchVendorJResultList[index]
                            //                         .jCurrentDay!
                            //                         .close!
                            //                         .isEmpty) {
                            //                   openTime = " (Leave)";
                            //                   closeTime = "";
                            //                   checkLeave = true;
                            //                 } else if (searchVendorJResultList[
                            //                             index]
                            //                         .jCurrentDay!
                            //                         .open!
                            //                         .isNotEmpty &&
                            //                     searchVendorJResultList[index]
                            //                         .jCurrentDay!
                            //                         .close!
                            //                         .isEmpty) {
                            //                   openTime = " (Open - 24 Hours)";
                            //                   closeTime = "";
                            //                   checkLeave = false;
                            //                 } else {
                            //                   openTime =
                            //                       "(Open - ${searchVendorJResultList[index].jCurrentDay!.open!}";
                            //                   closeTime =
                            //                       " - Close - ${searchVendorJResultList[index].jCurrentDay!.close!})";
                            //                   checkLeave = false;
                            //                 }

                            //                 return Padding(
                            //                   padding: const EdgeInsets.only(
                            //                       left: 12.0, right: 8, top: 8),
                            //                   child: GestureDetector(
                            //                     onTap: () {
                            //                       Navigator.push(
                            //                           context,
                            //                           MaterialPageRoute(
                            //                               builder: (context) =>
                            //                                   StoreDetailsScreen(
                            //                                       searchVendorJResultList[
                            //                                               index]
                            //                                           .nId!,
                            //                                       searchVendorJResultList[
                            //                                               index]
                            //                                           .cName!)));
                            //                     },
                            //                     child: Card(
                            //                       elevation: 3,
                            //                       shape: RoundedRectangleBorder(
                            //                           borderRadius:
                            //                               BorderRadius.circular(
                            //                                   10.sp)),
                            //                       child: Column(
                            //                         children: [
                            //                           Container(
                            //                             height: 20.5.h,
                            //                             decoration: BoxDecoration(
                            //                                 borderRadius:
                            //                                     BorderRadius.only(
                            //                                         topLeft: Radius
                            //                                             .circular(
                            //                                                 10.sp),
                            //                                         topRight:
                            //                                             Radius.circular(
                            //                                                 10.sp)),
                            //                                 image: DecorationImage(
                            //                                     fit: BoxFit.cover,
                            //                                     image: NetworkImage(searchVendorJResultList[index]
                            //                                             .jImages!
                            //                                             .isNotEmpty
                            //                                         ? searchVendorJResultList[
                            //                                                 index]
                            //                                             .jImages![0]
                            //                                             .cListingImg!
                            //                                         : ''))),
                            //                           ),
                            //                           Padding(
                            //                             padding:
                            //                                 const EdgeInsets.only(
                            //                                     left: 12.0,
                            //                                     right: 8,
                            //                                     top: 0,
                            //                                     bottom: 13),
                            //                             child: Column(
                            //                               crossAxisAlignment:
                            //                                   CrossAxisAlignment
                            //                                       .start,
                            //                               children: [
                            //                                 Container(
                            //                                   child: Text(
                            //                                     searchVendorJResultList[
                            //                                             index]
                            //                                         .cName!,
                            //                                     style: TextStyle(
                            //                                         fontSize: 15.0,
                            //                                         color: Style
                            //                                             .colors
                            //                                             .app_black,
                            //                                         fontWeight:
                            //                                             FontWeight
                            //                                                 .w500),
                            //                                   ),
                            //                                   margin:
                            //                                       const EdgeInsets
                            //                                               .only(
                            //                                           top: 15.0),
                            //                                 ),
                            //                                 Container(
                            //                                   margin:
                            //                                       const EdgeInsets
                            //                                               .only(
                            //                                           top: 5.0),
                            //                                   child: Row(
                            //                                     children: [
                            //                                       Text(
                            //                                         "${AppLocalizations.of(context)!.category!} : ",
                            //                                         style: TextStyle(
                            //                                             fontSize:
                            //                                                 13.0,
                            //                                             color: Style
                            //                                                 .colors
                            //                                                 .app_black,
                            //                                             fontFamily:
                            //                                                 Style
                            //                                                     .montserrat,
                            //                                             fontWeight:
                            //                                                 FontWeight
                            //                                                     .w400),
                            //                                       ),
                            //                                       Text(
                            //                                         searchVendorJResultList[
                            //                                                     index]
                            //                                                 .cCategory!
                            //                                                 .isNotEmpty
                            //                                             ? searchVendorJResultList[
                            //                                                     index]
                            //                                                 .cCategory!
                            //                                             : " - ",
                            //                                         style: TextStyle(
                            //                                             fontSize:
                            //                                                 13.0,
                            //                                             color: Style
                            //                                                 .colors
                            //                                                 .app_black,
                            //                                             fontFamily:
                            //                                                 Style
                            //                                                     .montserrat,
                            //                                             fontWeight:
                            //                                                 FontWeight
                            //                                                     .w400),
                            //                                       ),
                            //                                     ],
                            //                                   ),
                            //                                 ),
                            //                                 Container(
                            //                                   margin:
                            //                                       const EdgeInsets
                            //                                               .only(
                            //                                           top: 5.0),
                            //                                   child: Row(
                            //                                     children: [
                            //                                       Icon(
                            //                                         Icons
                            //                                             .access_time,
                            //                                         color: checkLeave
                            //                                             ? Colors.red
                            //                                             : Style
                            //                                                 .colors
                            //                                                 .green,
                            //                                         size: 18.0,
                            //                                       ),
                            //                                       Padding(
                            //                                         padding:
                            //                                             const EdgeInsets
                            //                                                     .only(
                            //                                                 left:
                            //                                                     2.0),
                            //                                         child: Text(
                            //                                           searchVendorJResultList[
                            //                                                       index]
                            //                                                   .jCurrentDay!
                            //                                                   .days! +
                            //                                               openTime,
                            //                                           style: TextStyle(
                            //                                               fontSize:
                            //                                                   13.0,
                            //                                               color: checkLeave
                            //                                                   ? Colors
                            //                                                       .red
                            //                                                   : Style
                            //                                                       .colors
                            //                                                       .green,
                            //                                               fontFamily:
                            //                                                   Style
                            //                                                       .montserrat,
                            //                                               fontWeight:
                            //                                                   FontWeight
                            //                                                       .w400),
                            //                                         ),
                            //                                       ),
                            //                                       Padding(
                            //                                         padding:
                            //                                             const EdgeInsets
                            //                                                     .only(
                            //                                                 left:
                            //                                                     2.0),
                            //                                         child: Text(
                            //                                           closeTime,
                            //                                           style: TextStyle(
                            //                                               fontSize:
                            //                                                   13.0,
                            //                                               color: checkLeave
                            //                                                   ? Colors
                            //                                                       .red
                            //                                                   : Style
                            //                                                       .colors
                            //                                                       .green,
                            //                                               fontFamily:
                            //                                                   Style
                            //                                                       .montserrat,
                            //                                               fontWeight:
                            //                                                   FontWeight
                            //                                                       .w400),
                            //                                         ),
                            //                                       ),
                            //                                     ],
                            //                                   ),
                            //                                 ),
                            //                               ],
                            //                             ),
                            //                           ),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 );
                            //               }),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Visibility(
                              visible: inboxNoData,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Container(
                                  //   child: Text(
                                  //     'No Data Found',
                                  //     style: TextStyle(
                                  //         letterSpacing: 1.0,
                                  //         fontSize: 15.0,
                                  //         fontWeight: FontWeight.w600,
                                  //         color: MyColor().theme_dark_purple),
                                  //   ),
                                  // ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child: Text(
                                      noDataText,
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                          color: Style.colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ));
  }

  getSubCategoryList() async {
    ProgressDialog().showLoaderDialog(context);

    try {
      Dio dio = new Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      var parameters = {"n_parent": widget.categoryId, "n_city": widget.cityid};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      final response = await dio.post(ApiProvider.getCategory,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      if (response.statusCode == 200) {
        debugPrint("asdfghjkl ${response.data}");
        Map<String, dynamic> map = jsonDecode(response.toString());
        CategoryModel categoryModel = CategoryModel.fromJson(map);

        if (categoryModel.nStatus == 1) {
          setState(() {
            checkSubCategoryEmpty = false;
          });

          updateSubCategoryList(categoryModel.jResult!);

          getBannerList("category");

          ProgressDialog().dismissDialog(context);
        } else {
          setState(() {
            checkSubCategoryEmpty = true;
            emptySubCategoryTxt = categoryModel.cMessage!;
          });
          ProgressDialog().dismissDialog(context);
        }
      } else {
        ProgressDialog().dismissDialog(context);
        setState(() {
          checkSubCategoryEmpty = true;
          emptySubCategoryTxt = "Bad Network Connection try again..";
        });
      }

      // debugPrint(response);
    } catch (e) {
      ProgressDialog().dismissDialog(context);
      setState(() {
        checkSubCategoryEmpty = true;
        emptySubCategoryTxt = "Bad Network Connection try again..";
      });
    }
  }

  getBannerList(String type) async {
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

      var parameters = {"c_type": type, "n_actionid": widget.categoryId};

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
        debugPrint("Response: " + "Bad Network Connection try again..");
        // ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      // bannerJResultList.clear();
      setState(() {
        checkBanner = false;
      });
      ProgressDialog().dismissDialog(context);
      debugPrint("Response: $e");
    }
  }

  List<SearchVendorJResult> particularDemocracylist = [];

  List<CategoryJResult> categoryJResultList = [];
  List<DemographicJResult> demographicJResultList = [];

  searchVendorListApi(String searchTxt, String loadmore) async {
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

    var parameters = {
      // "n_limit": limit,
      "c_search": searchTxt,
      // "n_category_id": categoryId
    };
    debugPrint("request : $parameters");

    final response = await dio.post(ApiProvider.getSearchlist,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: parameters);
    particularDemocracylist = [];
    categoryJResultList = [];
    demographicJResultList = [];
    debugPrint("response12333 : $response");
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.toString());
      ProgressDialog().dismissDialog(context);
      print("Pavithra ${map["j_result"]["vendor_list"]}");

      if (map["n_status"] == 1) {
        setState(() {
          // ProgressDialog().dismissDialog(context);
          checkInbox = true;
          inboxNoData = false;
        });
        print("Pavithra ${map["j_result"]["vendor_list"]}");
        print("Pavithrad ${map["j_result"]["category_list"]}");

        print("Pavithrad ${map["j_result"]["demographic_list"]}");

        for (var i = 0; i < map["j_result"]["vendor_list"].length; i++) {
          particularDemocracylist.add(
              SearchVendorJResult.fromJson(map["j_result"]["vendor_list"][i]));
        }
        for (var i = 0; i < map["j_result"]["category_list"].length; i++) {
          categoryJResultList.add(
              CategoryJResult.fromJson(map["j_result"]["category_list"][i]));
        }
        for (var i = 0; i < map["j_result"]["demographic_list"].length; i++) {
          demographicJResultList.add(DemographicJResult.fromJson(
              map["j_result"]["demographic_list"][i]));
        }
        if (demographicJResultList.isEmpty &&
            particularDemocracylist.isEmpty &&
            categoryJResultList.isEmpty) {
          setState(() {
            checkInbox = false;
            inboxNoData = true;
            noDataText = "Record Not Found";
          });
        }
      } else {
        // ProgressDialog().dismissDialog(context);
        setState(() {
          checkInbox = false;
          inboxNoData = true;
          noDataText = "Please fill the details to search";
        });
      }
      debugPrint("response12 : $map");
      // SearchVendorModel searchVendorModel = SearchVendorModel.fromJson(map);

      // if (searchVendorModel.nStatus == 1) {
      //   ProgressDialog().dismissDialog(context);
      //   setState(() {
      // checkInbox = true;
      // inboxNoData = false;
      //     if (searchVendorModel.jResult!.length > 0) {
      //       offset = offset + limit;
      //       limit = limit;
      //       total = searchVendorModel.nTotalRecords!;
      //     } else {
      //       checkInbox = false;
      //       inboxNoData = true;
      //       noDataText = "Record Not Found";
      //     }
      //   });
      //   if (loadmore == "Search") {
      //     searchVendorJResultList.clear();
      //   }

      //   updateVendorList(searchVendorModel.jResult!);
      // } else {
      // ProgressDialog().dismissDialog(context);
      // setState(() {
      //   checkInbox = false;
      //   inboxNoData = true;
      //   noDataText = searchVendorModel.cMessage!;
      // });
      // }
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
    await Future.delayed(const Duration(seconds: 0, milliseconds: 100));
    // setState(() {
    //   progressbar = false;
    //   loadmore = false;
    // });
    searchVendorListApi(searchTxt, "loadmore");
    return false;
  }

  openWhatsapp() async {
    var whatsapp = "+66810673747";
    var whatsappURl_android = "whatsapp://send?phone=$whatsapp&text=";
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
}
