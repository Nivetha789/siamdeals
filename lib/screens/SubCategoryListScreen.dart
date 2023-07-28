import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Utils/ProgressDialog.dart';
import '../ResponseModule/CategoryModel.dart';
import '../Utils/check_internet.dart';
import '../core/ApiProvider/api_provider.dart';
import '../helper/AppLocalizations.dart';
import '../utils/fab_menu_package.dart';
import '../utils/handler/toast_handler.dart';
import '../utils/style.dart';
import 'categorylist.dart';

class SubCategoryListScreen extends StatefulWidget {
  int categoryId = 0;
  final cityid;
  String categoryName = "";
  bool checkCategory = false;

  SubCategoryListScreen(
      this.categoryId, this.cityid, this.categoryName, this.checkCategory);

  @override
  State<StatefulWidget> createState() {
    return _SubCategoryListScreen();
  }
}

class _SubCategoryListScreen extends State<SubCategoryListScreen> {
  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();

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

  @override
  void initState() {
    super.initState();
    check().then((intenet) {
      if (intenet) {
        getSubCategoryList();
        // searchVendorListApi(searchTxt, "Search");
      } else {
        ToastHandler.showToast(
            message: "Please check your internet connection");
      }
    });
  }

  updateSubCategoryText(String id, String text) {
    stateSetter!(() {
      subCategoryId = id;
      subCategoryName = text;
      // print("id +name :"+subCategoryId+"  nn "+subCategoryName);
      // setState(() {
      //   for (int i = 0; i < subCategoryDataList.length; i++) {
      //     if (subCategoryDataList[i].addRemove!) {
      //       subCategoryDataList[i].addRemove = false;
      //     }
      //   }
      // });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CategoryStoreListScreen(
                         widget.categoryId,
                      widget.cityid,
                      subCategoryName,
                      true,
                    int.parse(subCategoryId)
                  )));
    });
  }

  updateSubCategoryList(List<CategoryJResult> subCategoryDataList1) {
    subCategoryDataList.clear();
    setState(() {
      subCategoryDataList.addAll(subCategoryDataList1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.0,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                size: 20.0,
                color: Style.colors.logoRed,
              )),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.sub_category!,
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
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                stateSetter = setState;
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                            color: Colors.white30,
                          ),
                          margin: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 20.0),
                          child: ListView.builder(
                              itemCount: subCategoryDataList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, postion) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      print("PAVITHRAMANOHARAN");
                                      // searchCategoryController.text = "";
                                      updateSubCategoryText(
                                          subCategoryDataList[postion].nId!,
                                          subCategoryDataList[postion]
                                              .cCategory!);
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
                                          width: MediaQuery.of(context)
                                              .size
                                              .width,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0,
                                                top: 10.0,
                                                bottom: 5.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex:1,
                                                  child: Image.network(
                                                      subCategoryDataList[
                                                              postion]
                                                          .cCategoryImage!,
                                                      height: 30,
                                                      width: 30),
                                                ),
                                                Expanded(
                                                  flex:8,
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 7.0),
                                                    child: Text(
                                                      subCategoryDataList[
                                                                  postion]
                                                              .cCategory!
                                                              .isNotEmpty
                                                          ? subCategoryDataList[
                                                                  postion]
                                                              .cCategory!
                                                          : "",
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily: Style
                                                              .sfproddisplay),
                                                    ),
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
            )));
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

  getSubCategoryList() async {
    ProgressDialog().showLoaderDialog(context);

    try {
      Dio dio = Dio();
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
        print("paramsub ${parameters}");
        Map<String, dynamic> map = jsonDecode(response.toString());
        CategoryModel categoryModel = CategoryModel.fromJson(map);
        print("ressub ${response.data}");
        if (categoryModel.nStatus == 1) {
          setState(() {
            checkSubCategoryEmpty = false;
          });

          updateSubCategoryList(categoryModel.jResult!);

          if(mounted) {
            ProgressDialog().dismissDialog(context);
          }
        } else {
          setState(() {
            checkSubCategoryEmpty = true;
            emptySubCategoryTxt = categoryModel.cMessage!;
          });
          if(mounted) {
            ProgressDialog().dismissDialog(context);
          }
        }
      } else {
        if(mounted) {
          ProgressDialog().dismissDialog(context);
        }
        setState(() {
          checkSubCategoryEmpty = true;
          emptySubCategoryTxt = "Bad Network Connection try again..";
        });
      }

      // print(response);
    } catch (e) {
      if(mounted) {
        ProgressDialog().dismissDialog(context);
      }
      setState(() {
        checkSubCategoryEmpty = true;
        emptySubCategoryTxt = "Bad Network Connection try again..";
      });
    }
  }
}
