// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loadmore/loadmore.dart';
import 'package:siamdealz/ResponseModule/popupmodel.dart';
import 'package:siamdealz/screens/SearchStoreListScreen.dart';
import 'package:siamdealz/screens/StoreDetailsScreen.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ResponseModule/BannerModel.dart';
import '../ResponseModule/CategoryModel.dart';
import '../ResponseModule/SearchVendorModule/SearchVendorModel.dart';
import '../Utils/ProgressDialog.dart';
import '../core/ApiProvider/api_provider.dart';
import '../helper/AppLocalizations.dart';
import '../utils/check_internet.dart';
import '../utils/fab_menu_package.dart';
import '../utils/handler/toast_handler.dart';
import '../utils/style.dart';

class CategoryStoreListScreen extends StatefulWidget {
  int categoryId = 0;
  final cityid;
  String categoryName = "";
  int subCategoryId = 0;
  bool checkCategory = false;

  CategoryStoreListScreen(this.categoryId, this.cityid, this.categoryName,
      this.checkCategory, this.subCategoryId);

  SearchStoreListScreenState createState() => SearchStoreListScreenState();
}

class SearchStoreListScreenState extends State<CategoryStoreListScreen> {
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
    super.initState();
    getpopupList("category", widget.categoryId.toString());
    categoryId = widget.categoryId;
    // getSubCategoryList();
    if (widget.checkCategory) {
      categoryName = widget.categoryName;
      searchHint = "Search";
    } else {
      categoryName = "Search";
      searchHint = "Search for stores ,products,brands,dishes..";
    }

    check().then((intenet) {
      if (intenet) {
        Future.delayed(Duration.zero, () {
          if (widget.checkCategory) {
            this.getSubCategoryList();
            this.getBannerList("category");
            this.searchVendorListApi(searchTxt, "Search");
            categoryName = widget.categoryName;
            searchHint = "Search";
          } else {
            categoryName = "Search";
            searchHint = "Search for stores ,products,brands,dishes..";
          }
        });

        // searchVendorListApi(searchTxt, "Search");
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
      categoryId = int.parse(subCategoryDataList[0].nId!);
      searchVendorListApi(searchTxt, "Search");
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

  openbannerlaunchurl(url) async {
    print("dsfjhsdgfhsfsdf $url");
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      await launchUrl(
        Uri.parse("http://" + url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    }
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
                                      print("PAVITHRAMANOHARAN");
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
                                            child: Row(
                                              children: [
                                                Image.network(
                                                    searchSubCategoryList[
                                                            postion]
                                                        .cCategoryImage!,
                                                    height: 30,
                                                    width: 30),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 7.0),
                                                  child: Text(
                                                    searchSubCategoryList[
                                                                postion]
                                                            .cCategory!
                                                            .isNotEmpty
                                                        ? searchSubCategoryList[
                                                                postion]
                                                            .cCategory!
                                                        : "",
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily: Style
                                                            .sfproddisplay),
                                                  ),
                                                ),
                                              ],
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
    categoryId = int.parse(subCategoryDataList[0].nId!);
    // if (!checkSubCategoryListFirst) {
    //   SubCategoryBottomList(context);
    // }
  }

  updateVendorList(List<SearchVendorJResult> searchVendorJResultList1) {
    searchVendorJResultList.clear();
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

  updatePopupList(
      List<PopupJResult> popupJResultList1, id, name, type, description) {
    debugPrint("PAvithramanoharan ${popupJResultList1.toString()}");
    for (int i = 0; i < popupJResultList1.length; i++) {
      debugPrint("PAVITHRAMANOHARAN ${popupJResultList1[i]}");
    }
    checkpopupdata(id, name, type, description);
    popupJResultList.clear();
    setState(() {
      popupJResultList.addAll(popupJResultList1);
    });
  }

  final box = GetStorage();

  Future<void> checkpopupdata(id, name, type, description) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      return await showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)), //this right here
              child: Container(
                height: MediaQuery.of(context).size.height / 2.2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              name == "City Popup" || name == "City"
                                  ? box.write("popupcityid", id).then(((value) {
                                      Navigator.pop(context);
                                    }))
                                  : box.write("popuphomeid", id).then(((value) {
                                      Navigator.pop(context);
                                    }));
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      popupJResultList.isNotEmpty
                          ? CarouselSlider.builder(
                              itemCount: popupJResultList.length,
                              itemBuilder: (BuildContext context, int index,
                                  int realIdx) {
                                return popupJResultList[index].npopuptype ==
                                            "2" ||
                                        popupJResultList[index].npopuptype == 2
                                    ? SingleChildScrollView(
                                        child: HtmlWidget(
                                          popupJResultList[index].cdescription!,
                                        ),
                                      )
                                    : Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        clipBehavior: Clip.antiAlias,
                                        child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Image.network(
                                              popupJResultList[index]
                                                  .cBannerImage!,
                                              fit: BoxFit.fill,
                                            )
                                            // : InkWell(
                                            //     onTap: () async {
                                            //       // debugPrint(
                                            //       //     "Dfsdjfhsdjkfhsdjfdsf ${bannerJResultList[index].cBannerLink!}");
                                            //       // String
                                            //       //     url =
                                            //       //     bannerJResultList[index]
                                            //       //         .cBannerLink;
                                            //       // var url =
                                            //       //     bannerJResultList[index]
                                            //       //         .cBannerLink!;
                                            //       // if (await canLaunch(
                                            //       //     url)) {
                                            //       //   await launch(
                                            //       //       url);
                                            //       // } else {
                                            //       //   throw 'Could not launch $url';
                                            //       // }
                                            //       openbannerlaunchurl(
                                            //           bannerJResultList[index]
                                            //               .cBannerLink!);
                                            //     },
                                            //     child: Image.network(
                                            //       bannerJResultList[index]
                                            //           .cBannerImage!,
                                            //       fit: BoxFit.fitWidth,
                                            //     ),
                                            //   ),
                                            ),
                                      );
                              },
                              options: CarouselOptions(
                                  autoPlay: popupJResultList.isNotEmpty
                                      ? true
                                      : false,
                                  viewportFraction: 1.0,
                                  height: type == "2" ? 250 : 150,
                                  enlargeCenterPage: false,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      pageIndex = index;
                                      // _current = index;
                                    });
                                  }),
                            )
                          : Container(),
                      popupJResultList.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              margin: const EdgeInsets.only(top: 5.0),
                              child: CarouselIndicator(
                                count: popupJResultList.length,
                                index: pageIndex,
                                color: Style.colors.grey.withOpacity(0.3),
                                activeColor: Style.colors.logoRed,
                                width: 10.0,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            );
          });
    });
    //   return Text('Hello, World!');
    // })

    //  ProgressDialog().dismissDialog(context);

    // setState(() {
    //   // _counter++;
    //   box.write('finalCount', _counter);
    // });
  }

  List<PopupJResult> popupJResultList = [];

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
          body: ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  stateSetter = setState;
                  return Column(
                    children: [
                      Container(
                        height: 60,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchStoreListScreen(
                                        0, widget.cityid, "", false)));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: 5.0, bottom: 5.0, left: 16.0, right: 16.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7.0)),
                            height: MediaQuery.of(context).size.height,
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10.0),
                                  child: Icon(
                                    Icons.search,
                                    size: 20.0,
                                    color: Style.colors.logoRed,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      AppLocalizations.of(context)!.mainSearch!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: TextStyle(
                                          color: Style.colors.app_black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: Style.montserrat,
                                          fontSize: 15.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: checkBanner,
                        child: bannerJResultList.isNotEmpty
                            ? Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 15.0, left: 16.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .city_spotLight!,
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: Style.josefinsans)),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 6.0, right: 6.0, top: 5.0),
                                      child: CarouselSlider.builder(
                                        itemCount: bannerJResultList.length,
                                        itemBuilder: (BuildContext context,
                                            int index, int realIdx) {
                                          return Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            clipBehavior: Clip.antiAlias,
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 160,
                                              child: bannerJResultList[index]
                                                          .cBannerLink ==
                                                      null
                                                  ? Image.network(
                                                      bannerJResultList[index]
                                                          .cBannerImage!,
                                                      fit: BoxFit.fill,
                                                    )
                                                  : InkWell(
                                                      onTap: () async {
                                                        // debugPrint(
                                                        //     "Dfsdjfhsdjkfhsdjfdsf ${bannerJResultList[index].cBannerLink!}");
                                                        // String
                                                        //     url =
                                                        //     bannerJResultList[index]
                                                        //         .cBannerLink;
                                                        // var url =
                                                        //     bannerJResultList[index]
                                                        //         .cBannerLink!;
                                                        // if (await canLaunch(
                                                        //     url)) {
                                                        //   await launch(
                                                        //       url);
                                                        // } else {
                                                        //   throw 'Could not launch $url';
                                                        // }
                                                        openbannerlaunchurl(
                                                            bannerJResultList[
                                                                    index]
                                                                .cBannerLink!);
                                                      },
                                                      child: Image.network(
                                                        bannerJResultList[index]
                                                            .cBannerImage!,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                            ),
                                          );
                                        },
                                        options: CarouselOptions(
                                            autoPlay:
                                                bannerJResultList.length > 0
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
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(
                                          left: 10.0, right: 10.0, top: 5.0),
                                      child: CarouselIndicator(
                                        count: bannerJResultList.length,
                                        index: pageIndex,
                                        color:
                                            Style.colors.grey.withOpacity(0.3),
                                        activeColor: Style.colors.logoRed,
                                        width: 10.0,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                      ),
                      Visibility(
                        visible: false,
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 15.0, left: 16.0, right: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.sub_category!,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: Style.josefinsans)),
                              Visibility(
                                visible: false,
                                child: InkWell(
                                  onTap: () {
                                    searchSubCategoryList.clear();
                                    setState(() {
                                      searchSubCategoryList
                                          .addAll(subCategoryDataList);
                                    });
                                    SubCategoryBottomList(context);
                                  },
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        AppLocalizations.of(context)!.view_all!,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                            color: Style.colors.logoRed,
                                            fontFamily: Style.josefinsans)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      /*subCategoryDataList.isNotEmpty
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              margin: const EdgeInsets.only(
                                  left: 11.0, right: 11.0),
                              child: Container(
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Container(
                                      height: 30,
                                      child: ListView.builder(
                                          itemCount: subCategoryDataList.length,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (subCategoryDataList[index]
                                                      .addRemove!) {
                                                    searchVendorJResultList
                                                        .clear();
                                                    categoryId =
                                                        widget.categoryId;
                                                    subCategoryDataList[index]
                                                            .addRemove =
                                                        !subCategoryDataList[
                                                                index]
                                                            .addRemove!;
                                                  } else {
                                                    for (int i = 0;
                                                        i <
                                                            subCategoryDataList
                                                                .length;
                                                        i++) {
                                                      if (subCategoryDataList[i]
                                                          .addRemove!) {
                                                        subCategoryDataList[i]
                                                            .addRemove = false;
                                                      }
                                                    }
                                                    subCategoryDataList[index]
                                                        .addRemove = true;

                                                    categoryId = int.parse(
                                                        subCategoryDataList[
                                                                index]
                                                            .nId!);
                                                  }
                                                });

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
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5.0,
                                                    right: 5.0,
                                                    top: 10.0,
                                                    bottom: 10.0),
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    border:
                                                        subCategoryDataList[index]
                                                                .addRemove!
                                                            ? Border.all(
                                                                color:
                                                                    Style.colors
                                                                        .logoRed)
                                                            : Border.all(
                                                                color: Style
                                                                    .colors
                                                                    .app_black),
                                                    color: subCategoryDataList[
                                                                index]
                                                            .addRemove!
                                                        ? Style.colors.logoRed
                                                            .withOpacity(0.2)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0)),
                                                child: Container(
                                                  height: 30,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 15.0,
                                                                right: 15.0),
                                                        child: Row(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                              child:
                                                                  Image.network(
                                                                subCategoryDataList[
                                                                        index]
                                                                    .cCategoryImage!,
                                                                height: 30,
                                                                width: 30,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: const EdgeInsets.only(
                                                                left: 6.0),
                                                              child: Text(
                                                                subCategoryDataList[
                                                                        index]
                                                                    .cCategory!,
                                                                style: TextStyle(
                                                                    color: Style
                                                                        .colors
                                                                        .app_black,
                                                                    fontSize:
                                                                        12.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontFamily: Style
                                                                        .montserrat),
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
                                  ],
                                ),
                              ),
                            )
                          : Container(),*/
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            Visibility(
                              visible: checkInbox,
                              child: Container(
                                child: LoadMore(
                                  isFinish:
                                      searchVendorJResultList.length >= total,
                                  onLoadMore: _loadMore,
                                  whenEmptyLoad: false,
                                  delegate: const DefaultLoadMoreDelegate(),
                                  textBuilder:
                                      DefaultLoadMoreTextBuilder.english,
                                  child: ListView(
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              searchVendorJResultList.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            String openTime = "";
                                            String closeTime = "";
                                            bool checkLeave = false;

                                            if (searchVendorJResultList[index]
                                                    .jCurrentDay!
                                                    .open!
                                                    .isEmpty &&
                                                searchVendorJResultList[index]
                                                    .jCurrentDay!
                                                    .close!
                                                    .isEmpty) {
                                              openTime = " (Leave)";
                                              closeTime = "";
                                              checkLeave = true;
                                            } else if (searchVendorJResultList[
                                                        index]
                                                    .jCurrentDay!
                                                    .open!
                                                    .isNotEmpty &&
                                                searchVendorJResultList[index]
                                                    .jCurrentDay!
                                                    .close!
                                                    .isEmpty) {
                                              openTime = " (Open - 24 Hours)";
                                              closeTime = "";
                                              checkLeave = false;
                                            } else {
                                              openTime =
                                                  "(Open - ${searchVendorJResultList[index].jCurrentDay!.open!}";
                                              closeTime =
                                                  " - Close - ${searchVendorJResultList[index].jCurrentDay!.close!})";
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
                                                                  searchVendorJResultList[
                                                                          index]
                                                                      .nId!,
                                                                  searchVendorJResultList[
                                                                          index]
                                                                      .cName!)));
                                                },
                                                child: Card(
                                                  elevation: 3,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.sp)),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 20.5.h,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10.sp),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10.sp)),
                                                            image: DecorationImage(
                                                                fit: BoxFit
                                                                    .fill,
                                                                image: NetworkImage(searchVendorJResultList[index]
                                                                        .jImages!
                                                                        .isNotEmpty
                                                                    ? searchVendorJResultList[index]
                                                                        .jImages![0]
                                                                        .cListingImg!
                                                                    : ''))),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 12.0,
                                                                right: 8,
                                                                top: 0,
                                                                bottom: 13),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top:
                                                                          15.0),
                                                              child: Text(
                                                                searchVendorJResultList[
                                                                        index]
                                                                    .cName!,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15.0,
                                                                    color: Style
                                                                        .colors
                                                                        .app_black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 5.0),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      "${AppLocalizations.of(context)!.category!} : ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13.0,
                                                                          color: Style
                                                                              .colors
                                                                              .app_black,
                                                                          fontFamily: Style
                                                                              .montserrat,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      searchVendorJResultList[index]
                                                                              .cCategory!
                                                                              .isNotEmpty
                                                                          ? searchVendorJResultList[index]
                                                                              .cCategory!
                                                                          : " - ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13.0,
                                                                          color: Style
                                                                              .colors
                                                                              .app_black,
                                                                          fontFamily: Style
                                                                              .montserrat,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 5.0),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .access_time,
                                                                    color: checkLeave
                                                                        ? Colors
                                                                            .red
                                                                        : Style
                                                                            .colors
                                                                            .green,
                                                                    size: 18.0,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            2.0),
                                                                    child: Text(
                                                                      searchVendorJResultList[index]
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
                                                                                  .colors.green,
                                                                          fontFamily: Style
                                                                              .montserrat,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            2.0),
                                                                    child: Text(
                                                                      closeTime,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13.0,
                                                                          color: checkLeave
                                                                              ? Colors
                                                                                  .red
                                                                              : Style
                                                                                  .colors.green,
                                                                          fontFamily: Style
                                                                              .montserrat,
                                                                          fontWeight:
                                                                              FontWeight.w400),
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
            ],
          ),
        ));
  }

  getSubCategoryList() async {
    try {
      // ProgressDialog().showLoaderDialog(context);

      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      var parameters = {"n_parent": widget.categoryId, "n_city": widget.cityid};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);
      print("paramsssss ${parameters}");
      dio.options.contentType = Headers.formUrlEncodedContentType;
      final response = await dio.post(ApiProvider.getCategory,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      if (response.statusCode == 200) {
        print("resssssss ${response.data}");
        Map<String, dynamic> map = jsonDecode(response.toString());
        CategoryModel categoryModel = CategoryModel.fromJson(map);

        if (categoryModel.nStatus == 1) {
          // if(mounted){
          //   ProgressDialog().dismissDialog(context);
          // }
          setState(() {
            checkSubCategoryEmpty = false;
          });

          updateSubCategoryList(categoryModel.jResult!);
        } else {
          // if(mounted) {
          //   ProgressDialog().dismissDialog(context);
          // }
          setState(() {
            checkSubCategoryEmpty = true;
            emptySubCategoryTxt = categoryModel.cMessage!;
          });
        }
      } else {
        // if(mounted) {
        //   ProgressDialog().dismissDialog(context);
        // }
        setState(() {
          checkSubCategoryEmpty = true;
          emptySubCategoryTxt = "Bad Network Connection try again..";
        });
      }

      // print(response);
    } catch (e) {
      // if(mounted) {
      //   ProgressDialog().dismissDialog(context);
      // }
    }
  }

  getBannerList(String type) async {
    try {
      // ProgressDialog().showLoaderDialog(context);
      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      var parameters = {
        "c_type": type,
        "n_city": widget.cityid.toString(),
        "n_category": widget.categoryId.toString(),
      };
      final response = await dio.post(ApiProvider.getBanner,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);
      print("bannerResponse " + response.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        BannerModel bannerModel = BannerModel.fromJson(map);
        if (bannerModel.nStatus == 1) {
          // ProgressDialog().dismissDialog(context);
          setState(() {
            checkBanner = true;
          });
          updateBannerList(bannerModel.jResult!);
        }
      } else {
        // ProgressDialog().dismissDialog(context);
        setState(() {
          checkBanner = false;
        });
        // bannerJResultList.clear();
        print("Response:  Bad Network Connection try again..");
        // ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // print(response);
    } catch (e) {
      // bannerJResultList.clear();
      setState(() {
        checkBanner = false;
      });
      // ProgressDialog().dismissDialog(context);
      print("Response: $e");
    }
  }

  searchVendorListApi(String searchTxt, String loadmore) async {
    // ProgressDialog().showLoaderDialog(context);

    // BaseOptions options =  BaseOptions(
    //   baseUrl: ApiProvider().Baseurl,
    //   connectTimeout: 5000,
    //   receiveTimeout: 3000,
    // );
    // Dio dio =  Dio(options);

    Dio dio = Dio();
    // dio.options.connectTimeout = 5000; //5s
    // dio.options.receiveTimeout = 3000;
    // print("response123232  $categoryId, $searchTxt");
    var parameters = {
      "n_limit": limit,
      "c_search": searchTxt,
      "n_category_id": widget.subCategoryId
    };
    debugPrint("vendorListParams : $parameters");

    final response = await dio.post(ApiProvider.getSearchVendor,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: parameters);

    print("vendorListRes : $response");
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.toString());
      SearchVendorModel searchVendorModel = SearchVendorModel.fromJson(map);

      if (searchVendorModel.nStatus == 1) {
        // if(mounted) {
        //   ProgressDialog().dismissDialog(context);
        // }
        if (mounted) {
          setState(() {
            checkInbox = true;
            inboxNoData = false;
            if (searchVendorModel.jResult!.length > 0) {
              offset = offset + limit;
              limit = limit;
              total = searchVendorModel.nTotalRecords!;
            } else {
              checkInbox = false;
              inboxNoData = true;
              noDataText = "Record Not Found";
            }
          });
        }
        if (loadmore == "Search") {
          searchVendorJResultList.clear();
        }

        updateVendorList(searchVendorModel.jResult!);
      } else {
        // if(mounted) {
        //   ProgressDialog().dismissDialog(context);
        // }
        setState(() {
          checkInbox = false;
          inboxNoData = true;
          noDataText = searchVendorModel.cMessage!;
        });
      }
    } else {
      // if(mounted) {
      //   ProgressDialog().dismissDialog(context);
      // }
      setState(() {
        checkInbox = false;
        inboxNoData = true;
        noDataText = "Bad Network Connection try again..";
      });
    }
  }

  Future<bool> _loadMore() async {
    print("onLoadMore");
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
            .showSnackBar(SnackBar(content: Text("whatsapp no installed")));
      }
    } else {
      // android , web
      if (await canLaunch(whatsappURl_android)) {
        await launch(whatsappURl_android);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("whatsapp no installed")));
      }
    }
  }

  getpopupList(String type, String actionId) async {
    Dio dio = Dio();
    debugPrint(
        "vsfdsfsdfdsf ${type}  actionid${widget.categoryId} ${widget.cityid}");
    var parameters = {
      "c_type": type,
      "n_city": widget.cityid.toString(),
      "n_category": widget.categoryId.toString(),
    };
    print(parameters);
    final response = await dio.post(ApiProvider.getPopup,
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: parameters);
    debugPrint("vsfdsfsdsf12333 ${response.data}");
    var popuphomeid = await box.read('categoryid');

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.toString());

      // debugPrint("vsfdsfsdsf12333 ${map["j_result"][0].toString()}");
      PopupModel popupModel = PopupModel.fromJson(map);
      debugPrint("PAvithramanoharan123444 ${popupModel.jResult}");
      if (popupModel.nStatus == 1) {
        if (popuphomeid != map["j_result"][0]["n_id"]) {
          updatePopupList(
              popupModel.jResult!,
              map["j_result"][0]["n_id"],
              map["j_result"][0]["c_title"],
              map["j_result"][0]["n_popup_type"],
              map["j_result"][0]["c_description"]);
        }
      } else {}
      // if (popupModel.nStatus == 1) {
      //   updatePopupList(popupModel.jResult!);
      // }
    } else {
      // bannerJResultList.clear();
      ToastHandler.showToast(message: "Bad Network Connection try again..");
    }
  }
}
