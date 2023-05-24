import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:siamdealz/ResponseModule/LoginModel.dart';
import 'package:siamdealz/screens/DashboardScreen.dart';
import 'package:siamdealz/screens/RegisterScreen.dart';
import 'package:siamdealz/utils/handler/toast_handler.dart';

import '../core/ApiProvider/api_provider.dart';
import '../utils/ProgressDialog.dart';
import '../utils/SharedPreference.dart';
import '../utils/check_internet.dart';
import '../utils/style.dart';

class LoginScreen extends StatefulWidget {
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  final _userPasswordController = new TextEditingController();
  final _userUsernameController = new TextEditingController();

  final usernameFocus = FocusNode();
  final passwordFocus = FocusNode();

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
    _userUsernameController.text = '';
    _userPasswordController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(
        // Create an inner BuildContext so that the onPressed methods
        // can refer to the Scaffold with Scaffold.of().
        builder: (BuildContext context) {
          return Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      child: Image.asset(
                        'images/logo.png',
                        height: 130,
                        width: 200,
                        alignment: Alignment.center,
                      ),
                      margin: EdgeInsets.only(top: 30.0),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Welcome',
                        style: TextStyle(
                            color: Color(0xff495271),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            fontSize: 22.0),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 5.0),
                      child: Text(
                        'Login to your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xff495271),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40.0, left: 30, right: 30),
                      child: TextFormField(
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        focusNode: usernameFocus,
                        controller: _userUsernameController,
                        maxLines: 1,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        onChanged: (text) {
                          setState(() {
                            // userMobileCheck(text);
                          });
                        },
                        onFieldSubmitted: (v) {
                          getFocus(context, passwordFocus);
                        },
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          labelText: "Email ID",
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.portrait_rounded,
                            size: 18.0,
                            color: Color(0xff495271),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff495271).withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(
                                color: Colors.grey[300]!, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: new TextStyle(
                            color: Colors.black87,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 15, left: 30, right: 30, bottom: 10),
                      child: TextFormField(
                        autofocus: false,
                        obscureText: !_passwordVisible,
                        focusNode: passwordFocus,
                        controller: _userPasswordController,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        keyboardType: TextInputType.text,
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color(0xff495271).withOpacity(0.4),
                              size: 18,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            size: 18.0,
                            color: Color(0xff495271),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff495271).withOpacity(0.3),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(
                                color: Colors.grey[300]!, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: new TextStyle(
                            color: Colors.black87,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (validateFirstName()) {
                          if (validatePass()) {
                            check().then((intenet) {
                              if (intenet) {
                                loginApi();
                              } else {
                                ToastHandler.showToast(
                                    message:
                                        "Please check your internet connection");
                              }
                              // No-Internet Case
                            });
                          } else {
                            ToastHandler.showToast(
                                message:
                                    "Password should be more than 3 character");
                          }
                        } else {
                          ToastHandler.showToast(message: "Enter Email Id");
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 20, left: 30, right: 30),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Style.colors.white.withOpacity(0.3),
                              width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Style.colors.logoRed,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                              left: 5.0,
                            ),
                            child: Text("Login",
                                style: TextStyle(
                                    fontFamily: Style.montserrat,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 30),
                      child: Text(
                        "Don't have an account?",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff495271),
                            fontFamily: Style.josefinsans),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                RegisterScreen()));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin:
                            EdgeInsets.only(top: 15.0, left: 65.0, right: 65.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color(0xff495271).withOpacity(0.2),
                              width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Text(
                            "GET STARTED",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff00d3b4),
                                fontFamily: Style.josefinsans),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80.0,
                    ),
                    // Tooltip(
                    //   decoration: BoxDecoration(
                    //       gradient: LinearGradient(
                    //           begin: Alignment.centerLeft,
                    //           end: Alignment.centerRight,
                    //           colors: [MyColor().orange, MyColor().theme_dark_blue]),
                    //       borderRadius:
                    //       BorderRadius.all(Radius.circular(30.0))),
                    //   message: "Schemes",
                    //   child: Container(
                    //       alignment: Alignment.centerRight,
                    //       height: 50.0,
                    //       margin: EdgeInsets.only(right: 10),
                    //       child: FloatingActionButton(
                    //         hoverColor: Colors.orange,
                    //         elevation: 10,
                    //         onPressed: () {
                    //           Navigator.push(
                    //               context,
                    //               CupertinoPageRoute(
                    //                   builder: (BuildContext context) =>
                    //                       DashBoardSchemesScreen(
                    //                           "", "","","")));
                    //         },
                    //         backgroundColor: MyColor().theme_dark_blue,
                    //         child: Image.asset(
                    //           "images/gift.png",
                    //           color: MyColor().white,
                    //           width: 25.0,
                    //           height: 25.0,
                    //         ),
                    //       )),
                    // ),
                  ],
                ),
              ),
              // Positioned(
              //   child: _progressHUD,
              // ),
            ],
          );
        },
      ),
    );
  }

  bool validateFirstName() {
    // Always assume false until proven otherwise
    bool bHasContent = false;
//        String MobilePattern = "[0-9]{10}";

    if (_userUsernameController.text.length > 0) {
      // Got content
      bHasContent = true;
    } else {
      bHasContent = false;
    }
    return bHasContent;
  }

  bool validatePass() {
    // Always assume false until proven otherwise
    bool bHasContent = false;
//        String MobilePattern = "[0-9]{10}";

    if (_userPasswordController.text.length > 2) {
      // Got content
      bHasContent = true;
    } else {
      bHasContent = false;
    }
    return bHasContent;
  }

  getFocus(BuildContext context, FocusNode focus) {
    return FocusScope.of(context).requestFocus(focus);
  }

  loginApi() async {
    try {
      // _progressHUD.state.show();
      // BaseOptions options = new BaseOptions(
      //   baseUrl: ApiProvider().Baseurl,
      //   connectTimeout: 5000,
      //   receiveTimeout: 3000,
      // );
      // Dio dio = new Dio(options);
      ProgressDialog().showLoaderDialog(context);

      Dio dio = new Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;
      var parameters = {
        "c_username": _userUsernameController.text,
        "c_password": _userPasswordController.text
      };
      final response = await dio.post(ApiProvider.login,
          data: parameters,
          options: Options(
              validateStatus: (_) => true,
              contentType: Headers.formUrlEncodedContentType));

      debugPrint("response " + response.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        LoginModel loginModel = LoginModel.fromJson(map);

        if (loginModel.nStatus == 1) {
          // _progressHUD.state.dismiss();
          ProgressDialog().dismissDialog(context);

          // await SharedPreference().setAdminName(adminName);
          // await SharedPreference().setMobNum(mob);
          // await SharedPreference().setTokenKey(token_key);
          // await SharedPreference().setSubcribeTokenKey(subcription_tokenKey);
          // await SharedPreference().setAuthTokenKey(auth_tokenKey);

          // debugPrint("dcmsetStatus "+dcmStatus.toString());

          await SharedPreference().setLogin("1");

          await SharedPreference().setUserId(loginModel.jResult![0].nId!);
          await SharedPreference().setuserName(loginModel.jResult![0].cFullName!);
          await SharedPreference().setAddress(loginModel.jResult![0].cAddress!);
          await SharedPreference().setUserEmail(loginModel.jResult![0].cEmailid!);

          await SharedPreference().setLanguage(loginModel.jResult![0].cDefaultLanguage!);

          ToastHandler.showToast(message: loginModel.cMessage!);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => DashBoardScreen()));

        } else {
          // _progressHUD.state.dismiss();
          ToastHandler.showToast(message: loginModel.cMessage!);
          ProgressDialog().dismissDialog(context);
        }
      } else {
        // _progressHUD.state.dismiss();

        ToastHandler.showToast(message: "Bad Network Connection try again");
        ProgressDialog().dismissDialog(context);
      }

      debugPrint(response.toString());
    } catch (e) {
      // _progressHUD.state.dismiss();
      ProgressDialog().dismissDialog(context);
      debugPrint("Response: " + e.toString());
    }
  }
}
