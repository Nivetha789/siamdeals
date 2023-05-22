import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:siamdealz/ResponseModule/ProfileModel.dart';
import 'package:siamdealz/core/ApiProvider/api_provider.dart';
import 'package:siamdealz/utils/CustomAlertDialog.dart';
import 'package:siamdealz/utils/handler/toast_handler.dart';
import 'package:siamdealz/utils/style.dart';

import '../Utils/SharedPreference.dart';
import '../Utils/check_internet.dart';
import '../utils/ProgressDialog.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  String c_line = "";
  String c_full_name = "";
  String c_short_name = "";
  String c_emailid = "";
  String c_address = "";
  String c_user_since = "";
  String c_profile = "";

  @override
  void initState() {
    super.initState();
    check().then((intenet) {
      if (intenet) {
        getProfileApi();
      } else {
        Fluttertoast.showToast(
            msg: "Please check your internet connection",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            backgroundColor: Color(0xffF5C120),
            timeInSecForIosWeb: 1);
      }
      print("sssss");
      // No-Internet Case
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: BackButton(),
        title: Text(
          "Profile",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Style.colors.logoRed,
              fontSize: 18,
              fontFamily: Style.montserrat,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Style.colors.logoRed),
        backgroundColor: Colors.white,
        //   brightness: Brightness.light,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15.0),
            alignment: Alignment.center,
            child: Image.asset(
              'images/logo.png',
              height: 130,
              width: 130,
              alignment: Alignment.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.black12),
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        " Name",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                            color: Colors.black87),
                      ),
                      SizedBox(
                        width: 25.0,
                      ),
                      Flexible(
                        child: Text(
                          c_full_name,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.black12),
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Mobile Number",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                            color: Colors.black87),
                      ),
                      SizedBox(
                        width: 25.0,
                      ),
                      Flexible(
                        child: Text(
                          c_line,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: Colors.black12),
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "E-Mail",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                            color: Colors.black87),
                      ),
                      SizedBox(
                        width: 25.0,
                      ),
                      Flexible(
                        child: Text(
                          c_emailid,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0),
                        ),
                      )
                    ],
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.all(20.0),
                //   decoration: BoxDecoration(
                //     border: Border(
                //       bottom: BorderSide(width: 1.0, color: Colors.black12),
                //     ),
                //     color: Colors.white,
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     mainAxisSize: MainAxisSize.max,
                //     children: <Widget>[
                //       Text(
                //         "Address",
                //         style: TextStyle(
                //             fontSize: 14.0,
                //             fontWeight: FontWeight.w400,
                //             decoration: TextDecoration.none,
                //             color: Colors.black87),
                //       ),
                //       SizedBox(
                //         width: 25.0,
                //       ),
                //       Flexible(
                //         child: Text(
                //           c_address,
                //           textDirection: TextDirection.rtl,
                //           style: TextStyle(
                //             color: Colors.black,
                //             fontWeight: FontWeight.w600,
                //             decoration: TextDecoration.none,
                //             fontSize: 14.0,
                //           ),
                //         ),
                //       )
                //     ],
                //   ),
                // ),

                InkWell(
                  onTap: () {
                    var dialog = CustomAlertDialog(
                      title: "Logout",
                      message: "Are you sure, do you want to logout?",
                      onPostivePressed: () async {
                        Navigator.pop(context);
                        await SharedPreference().clearSharep().then((v) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen()));
                        });
                      },
                      positiveBtnText: 'Yes',
                      negativeBtnText: 'No',
                      onNegativePressed: () {},
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => dialog);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 60, left: 30, right: 30),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Style.colors.white.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Style.colors.logoRed,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                          left: 5.0,
                        ),
                        child: Text("Logout",
                            style: TextStyle(
                                fontFamily: Style.montserrat,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),

                // Container(
                //   margin: EdgeInsets.only(top: 50.0, bottom: 20.0),
                //   width: 250.0,
                //   height: 45.0,
                //   child: ElevatedButton(
                //     child: Text(
                //       'Change Password',
                //       style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 15.0,
                //           fontWeight: FontWeight.w400),
                //     ),
                //     onPressed: () {
                //       //loader(context);
                //       // Navigator.push(
                //       //   context,
                //       //   CupertinoPageRoute(
                //       //       builder: (context) => ForgetPassword()),
                //       // );
                //     },
                //   ),
                // ),InkWell(
                //                   onTap: () {
                //                     var dialog = CustomAlertDialog(
                //                       title: "Logout",
                //                       message: "Are you sure, do you want to logout?",
                //                       onPostivePressed: () async {
                //                         Navigator.pop(context);
                //                         await SharedPreference().clearSharep().then((v) {
                //                           Navigator.of(context).pushReplacement(
                //                               MaterialPageRoute(
                //                                   builder: (BuildContext context) =>
                //                                       LoginScreen()));
                //                         });
                //                       },
                //                       positiveBtnText: 'Yes',
                //                       negativeBtnText: 'No',
                //                       onNegativePressed: () {},
                //                     );
                //                     showDialog(
                //                         context: context,
                //                         builder: (BuildContext context) => dialog);
                //                   },
                //                   child: Container(
                //                     margin: EdgeInsets.only(top: 60, left: 30, right: 30),
                //                     decoration: BoxDecoration(
                //                       border: Border.all(
                //                           color: Style.colors.white.withOpacity(0.3), width: 1),
                //                       borderRadius: BorderRadius.all(Radius.circular(8.0)),
                //                       color: Style.colors.logoRed,
                //                     ),
                //                     child: Padding(
                //                       padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                //                       child: Container(
                //                         alignment: Alignment.center,
                //                         margin: EdgeInsets.only(
                //                           left: 5.0,
                //                         ),
                //                         child: Text("Logout",
                //                             style: TextStyle(
                //                                 fontFamily: Style.montserrat,
                //                                 fontSize: 15.0,
                //                                 fontWeight: FontWeight.w600,
                //                                 color: Colors.white)),
                //                       ),
                //                     ),
                //                   ),
                //                 ),

                SizedBox(
                  height: 100.0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  getProfileApi() async {
    ProgressDialog().showLoaderDialog(context);

    try {
      Dio dio = new Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);
      String userId = await SharedPreference().getUserId();

      var parameters = {"n_user": userId};

      final response = await dio.post(ApiProvider.getProfile,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      print("response " + response.toString());

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        ProfileModel profileModel = ProfileModel.fromJson(map);

        if (profileModel.nStatus == 1) {
          setState(() {
            c_line = profileModel.jResult![0].cLine!;
            c_full_name = profileModel.jResult![0].cFullName!;
            c_short_name = profileModel.jResult![0].cShortName!;
            c_emailid = profileModel.jResult![0].cEmailid!;
            c_address = profileModel.jResult![0].cAddress!;
            c_user_since = profileModel.jResult![0].cUserSince!;
            c_profile = profileModel.jResult![0].cProfile!;
          });

          ProgressDialog().dismissDialog(context);
        } else {
          ProgressDialog().dismissDialog(context);

          ToastHandler.showToast(message: "message");
        }
      } else {
        ProgressDialog().dismissDialog(context);
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // print(response);
    } catch (e) {
      print("Exception " + e.toString());
      ProgressDialog().dismissDialog(context);
      ToastHandler.showToast(message: "Bad Network Connection try again..");
    }
  }
}
