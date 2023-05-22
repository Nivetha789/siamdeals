import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:siamdealz/ResponseModule/CountryModel.dart';
import 'package:siamdealz/screens/DashboardScreen.dart';
import 'package:siamdealz/utils/handler/toast_handler.dart';

import '../ResponseModule/RegisterModel.dart';
import '../core/ApiProvider/api_provider.dart';
import '../utils/ProgressDialog.dart';
import '../utils/SharedPreference.dart';
import '../utils/check_internet.dart';
import '../utils/style.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final _userUsernameController = new TextEditingController();
  final _emailIdController = new TextEditingController();
  final _mobileNumController = new TextEditingController();
  final _addressController = new TextEditingController();
  final _userConfirmPasswordController = new TextEditingController();
  final _userPasswordController = new TextEditingController();

  final usernameFocus = FocusNode();
  final emailIdFocus = FocusNode();
  final mobileNumFocus = FocusNode();
  final addressNumFocus = FocusNode();

  final confirmPasswordFocus = FocusNode();
  final passwordFocus = FocusNode();

  List<String> languageList = ['English', 'Thai'];
  String? _selectedLanguage;
  String? defaultLanguage;

  String shortName = "";

  //country code
  final countryCodeController = new TextEditingController();
  final searchCountryCodeController = new TextEditingController();
  List<CountryJResult> countryCodeList = [];
  List<CountryJResult> searchCountryCodeList = [];
  String _selectCountryCode = "91";
  String countryCodeId = "";
  String countryName = "";

  @override
  void initState() {
    super.initState();

    _passwordVisible = false;
    _userUsernameController.text = '';
    _userPasswordController.text = '';

    check().then((intenet) {
      if (intenet) {
        getCountryList();
      } else {
        ToastHandler.showToast(
            message: "Please check your internet connection");
      }
    });
  }

  updateCountryList(List<CountryJResult> countryCodeList1) {
    countryCodeList.clear();
    setState(() {
      countryCodeList.addAll(countryCodeList1);
    });
  }

  countryCodeTextListener(String text) {
    if (text.isNotEmpty) {
      setState(() {
        searchCountryCodeList = countryCodeList
            .where((u) =>
                (u.countryName!.toLowerCase().contains(text.toLowerCase()) ||
                    u.countryName!.toLowerCase().contains(text.toLowerCase())))
            .toList();

        // community = searchCommunityController.text;
      });
    } else {
      setState(() {
        searchCountryCodeList.clear();
        searchCountryCodeList.addAll(countryCodeList);
      });
    }
  }

  updateCountryCodeText(String id, String countryCode1, String text) {
    setState(() {
      countryCodeId = id;
      _selectCountryCode = countryCode1;
      countryName = text;
    });
  }

  //country code
  countryCodeBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.75,
                color: Colors.transparent,
                child: Container(
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
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
                                child: const Text(
                                  "Select Country Code",
                                  style: TextStyle(
                                      color: Color(0xff495271),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  searchCountryCodeController.text = "";
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Icon(
                                      Icons.cancel_rounded,
                                      color: const Color(0xff495271)
                                          .withOpacity(0.3),
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                          child: TextFormField(
                            autofocus: false,
                            controller: searchCountryCodeController,
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search Country Code",
                              hintStyle: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xff495271)
                                      .withOpacity(0.3)
                                      .withOpacity(0.7)),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18.0,
                                color: const Color(0xff495271).withOpacity(0.3),
                              ),
                            ),
                            style: const TextStyle(color: Color(0xff495271)),
                            onChanged: (text) {
                              setState(() {
                                countryCodeTextListener(text);
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 20.0),
                        child: ListView.builder(
                            itemCount: searchCountryCodeList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, postion) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    searchCountryCodeController.text = "";
                                    Navigator.pop(context);

                                    updateCountryCodeText(
                                        searchCountryCodeList[postion].id!,
                                        searchCountryCodeList[postion]
                                            .countryCode!,
                                        searchCountryCodeList[postion]
                                            .countryName!);
                                  });
//                                listScreens(drawerlist[postion].name);
//                          Fluttertoast.showToast(
//                              msg: "This is Toast messaget " +
//                                  doctorsList[postion].name,
//                              toastLength: Toast.LENGTH_SHORT,
//                              gravity: ToastGravity.BOTTOM,
//                              timeInSecForIos: 1);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              top: 10.0,
                                              bottom: 5.0),
                                          child: Text(
                                            searchCountryCodeList[postion]
                                                .countryName!,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        width:
                                            MediaQuery.of(context).size.width,
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
          );
        });
  }

  bool sendotp = true;
  var otp = "0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'Sign Up',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: const Color(0xff495271),
              fontSize: 18,
              fontFamily: Style.montserrat,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: const BackButton(),
        iconTheme: const IconThemeData(color: Color(0xff495271)),
        backgroundColor: Colors.white,
        //    brightness: Brightness.light,
      ),
      body: Builder(
        // Create an inner BuildContext so that the onPressed methods
        // can refer to the Scaffold with Scaffold.of().
        builder: (BuildContext context) {
          return sendotp
              ? Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Container(
                      //   alignment: Alignment.centerLeft,
                      //   margin: EdgeInsets.only(top: 5.0,left: 30.0),
                      //   child: Text(
                      //     'Sign Up',
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //         color: Color(0xff495271),
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.w600),
                      //   ),
                      // ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 40.0, left: 16.0, right: 16.0),
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
                            labelText: "Name",
                            labelStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.portrait_rounded,
                              size: 18.0,
                              color: Color(0xff495271),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      const Color(0xff495271).withOpacity(0.3)),
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
                        margin: const EdgeInsets.only(
                            top: 15.0, left: 16.0, right: 16.0),
                        child: TextFormField(
                          autofocus: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          focusNode: emailIdFocus,
                          controller: _emailIdController,
                          maxLines: 1,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          onChanged: (text) {
                            setState(() {
                              // userMobileCheck(text);
                            });
                          },
                          onFieldSubmitted: (v) {
                            getFocus(context, mobileNumFocus);
                          },
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            labelText: "Email Id",
                            labelStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 18.0,
                              color: Color(0xff495271),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      const Color(0xff495271).withOpacity(0.3)),
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
                        margin: const EdgeInsets.only(
                            top: 15.0, left: 16.0, right: 16.0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    border: Border.all(
                                        width: 1.0, color: Colors.grey[300]!)),
                                margin: const EdgeInsets.only(right: 5.0),
                                child:
                                    // CountryListPick(
                                    //     pickerBuilder: (context, CountryCode countryCode1) {
                                    //       countryCode=countryCode1;
                                    //       print("countryyy "+countryCode.toString());
                                    InkWell(
                                  onTap: () {
                                    setState(() {
                                      searchCountryCodeList.clear();
                                      searchCountryCodeList
                                          .addAll(countryCodeList);
                                    });

                                    countryCodeBottomSheet(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Image.asset(
                                      //   countryCode1.flagUri,
                                      //   package: 'country_list_pick',
                                      //   height: 20.0,
                                      //   width: 20.0,
                                      // ),
                                      // Flexible(
                                      //   child: Container(
                                      //     margin: EdgeInsets.only(left: 5.0),
                                      //     child: Text(countryCode1.code,
                                      //         textAlign: TextAlign.start,
                                      //         style:TextStyle(
                                      //             fontSize: 14,
                                      //             fontWeight: FontWeight.w400,
                                      //             color: Colors.black87,
                                      //         )),
                                      //   ),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4.0,
                                            top: 20.0,
                                            bottom: 20.0,
                                            right: 4.0),
                                        child: Text("+" + _selectCountryCode,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black87,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                // },
                                // // To disable option set to false
                                // theme: CountryTheme(
                                //   isShowFlag: true,
                                //   isShowCode: true,
                                //   isShowTitle: false,
                                //   isDownIcon: true,
                                //   alphabetSelectedBackgroundColor: Color(0xff495271),
                                //   showEnglishName: true,
                                // ),
                                // // Set default value
                                // initialSelection: 'IN',
                                // // or
                                // // initialSelection: 'US'
                                // onChanged: (countryCode) {
                                //   print(countryCode.name);
                                //   print(countryCode.code);
                                //   print(countryCode.dialCode);
                                //   print(countryCode.flagUri);
                                //
                                //   // _dialCode = code.dialCode.substring(1);
                                // },
                                // // Whether to allow the widget to set a custom UI overlay
                                // useUiOverlay: true,
                                // // Whether the country list should be wrapped in a SafeArea
                                // useSafeArea: true),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: Container(
                                child: TextFormField(
                                  textAlign: TextAlign.left,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  focusNode: mobileNumFocus,
                                  controller: _mobileNumController,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLength: 15,
                                  buildCounter: (BuildContext? context,
                                          {int? currentLength,
                                          int? maxLength,
                                          bool? isFocused}) =>
                                      null,
                                  decoration: InputDecoration(
                                    labelText: "Mobile Number",
                                    labelStyle: const TextStyle(
                                      fontSize: 13.0,
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.phone_iphone,
                                      size: 20.0,
                                      color: const Color(0xff495271)
                                          .withOpacity(0.3),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: const Color(0xff495271)
                                              .withOpacity(0.3),
                                          width: 1.0),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderSide: BorderSide(
                                          color: Colors.grey[300]!, width: 1.0),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        20.0, 20.0, 20.0, 20.0),
                                  ),
                                  style: new TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(top: 15.0, left: 16.0, right: 16.0),
                      //   child: TextFormField(
                      //     autofocus: false,
                      //     textInputAction: TextInputAction.next,
                      //     keyboardType: TextInputType.text,
                      //     focusNode: addressNumFocus,
                      //     controller: _addressController,
                      //     maxLines: 1,
                      //     maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      //     onChanged: (text) {
                      //       setState(() {
                      //         // userMobileCheck(text);
                      //       });
                      //     },
                      //     onFieldSubmitted: (v) {
                      //       getFocus(context, passwordFocus);
                      //     },
                      //     textAlign: TextAlign.left,
                      //     decoration: InputDecoration(
                      //       labelText: "Address",
                      //       labelStyle: TextStyle(
                      //         fontSize: 14.0,
                      //         color: Colors.grey,
                      //       ),
                      //       border: OutlineInputBorder(),
                      //       prefixIcon: Icon(
                      //         Icons.location_on_outlined,
                      //         size: 18.0,
                      //         color: Color(0xff495271),
                      //       ),
                      //       focusedBorder: OutlineInputBorder(
                      //         borderSide: BorderSide(
                      //             color: Color(0xff495271).withOpacity(0.3)),
                      //         borderRadius: BorderRadius.circular(8.0),
                      //       ),
                      //       enabledBorder: OutlineInputBorder(
                      //         // width: 0.0 produces a thin "hairline" border
                      //         borderSide:
                      //             BorderSide(color: Colors.grey[300]!, width: 1.0),
                      //         borderRadius: BorderRadius.circular(8.0),
                      //       ),
                      //     ),
                      //     style: new TextStyle(
                      //         color: Colors.black87,
                      //         fontSize: 14.0,
                      //         fontWeight: FontWeight.w500),
                      //   ),
                      // ),
                      Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey[300]!, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                          ),
                          margin: const EdgeInsets.only(
                              top: 15.0, left: 16.0, right: 16.0),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            child: DropdownButton(
                              underline: new DropdownButtonHideUnderline(
                                  child: const SizedBox()),
                              isExpanded: true,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                              items: languageList.map((String location) {
                                return DropdownMenuItem(
                                  value: location,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 15.0),
                                          child: const Icon(
                                            Icons.language_sharp,
                                            size: 18.0,
                                            color: Color(0xff495271),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            location,
                                            style: const TextStyle(
                                                color: Color(0xff495271),
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          margin:
                                              const EdgeInsets.only(left: 15.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              icon: const Icon(Icons.arrow_drop_down_sharp,
                                  size: 20.0, color: Color(0xff495271)),
                              alignment: Alignment.centerLeft,
                              hint: Container(
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 15.0),
                                      child: const Icon(
                                        Icons.language_sharp,
                                        size: 18.0,
                                        color: Color(0xff495271),
                                      ),
                                    ),
                                    Container(
                                      child: const Text(
                                        "Language",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      margin: const EdgeInsets.only(left: 15.0),
                                    ),
                                  ],
                                ),
                              ),
                              value: _selectedLanguage,
                              onChanged: (String? value) => setState(() {
                                _selectedLanguage = value ?? "";
                              }),
                            ),
                          )),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 15.0, left: 16.0, right: 16.0),
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
                            getFocus(context, confirmPasswordFocus);
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xff495271).withOpacity(0.4),
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
                            labelStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.lock_outlined,
                              size: 18.0,
                              color: Color(0xff495271),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      const Color(0xff495271).withOpacity(0.3),
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
                      Container(
                        margin: const EdgeInsets.only(
                            top: 15.0, left: 16.0, right: 16.0),
                        child: TextFormField(
                          autofocus: false,
                          obscureText: !_confirmPasswordVisible,
                          focusNode: confirmPasswordFocus,
                          controller: _userConfirmPasswordController,
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
                                _confirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xff495271).withOpacity(0.4),
                                size: 18,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                });
                              },
                            ),
                            labelText: "Confirm Password",
                            labelStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.lock_outlined,
                              size: 18.0,
                              color: Color(0xff495271),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      const Color(0xff495271).withOpacity(0.3),
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
                            if (validateEmail()) {
                              // if (validateAddress()) {
                              if (_selectedLanguage!.isNotEmpty) {
                                if (_userPasswordController.text.isNotEmpty) {
                                  if (_userConfirmPasswordController
                                      .text.isNotEmpty) {
                                    if (validatePassword()) {
                                      if (validateConfirmPassword()) {
                                        if (_userPasswordController.text ==
                                            _userConfirmPasswordController
                                                .text) {
                                          check().then((intenet) {
                                            if (intenet) {
                                              setState(() {
                                                sendotp = false;
                                              });

                                              otpsend();
                                              // registerApi();
                                            } else {
                                              ToastHandler.showToast(
                                                  message:
                                                      "Please check your internet connection");
                                            }
                                            // No-Internet Case
                                          });
                                        } else {
                                          ToastHandler.showToast(
                                              message: "Password mismatch");
                                        }
                                      } else {
                                        ToastHandler.showToast(
                                            message:
                                                "Confirm password should be more than 3 character");
                                      }
                                    } else {
                                      ToastHandler.showToast(
                                          message:
                                              "Password should be more than 3 character");
                                    }
                                  } else {
                                    ToastHandler.showToast(
                                        message: "Enter confirm password");
                                  }
                                } else {
                                  ToastHandler.showToast(
                                      message: "Enter password");
                                }
                              } else {
                                ToastHandler.showToast(
                                    message: "Select Language");
                              }
                              // } else {
                              //   ToastHandler.showToast(message: "Enter Address");
                              // }
                            } else {
                              ToastHandler.showToast(
                                  message: "Enter valid Email Id");
                            }
                          } else {
                            ToastHandler.showToast(message: "Enter Name");
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 30, left: 16, right: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Style.colors.white.withOpacity(0.3),
                                width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            color: Style.colors.logoRed,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(
                                left: 5.0,
                              ),
                              child: Text("Send OTP",
                                  style: TextStyle(
                                      fontFamily: Style.montserrat,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 100.0,
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
                )
              : Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 70,
                      ),
                      // Image.network("Add Image Link"),
                      Text(
                        "Enter verification Code",
                        style: TextStyle(
                            color: const Color(0xff495271),
                            fontSize: 18,
                            fontFamily: Style.montserrat,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Code sent to ${_emailIdController.text}",
                        style: TextStyle(
                            color: const Color(0xff495271),
                            fontSize: 13,
                            fontFamily: Style.montserrat,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      OTPTextField(
                          length: 6,
                          width: MediaQuery.of(context).size.width,
                          fieldWidth: 50,
                          fieldStyle: FieldStyle.box,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: Style.montserrat,
                              fontWeight: FontWeight.w500),
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          onCompleted: (pin) {
                            otp = pin.toString();
                            print("Completed: " + pin + otp);
                          },
                          otpFieldStyle: OtpFieldStyle(
                            borderColor: Colors.black,
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: (() {
                                otpsend();
                              }),
                              child: Text(
                                "Resend OTP",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontFamily: Style.montserrat,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (() {
                              verifyotp();
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: 30, left: 16, right: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Style.colors.white.withOpacity(0.3),
                                    width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                color: Style.colors.logoRed,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 15.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                    left: 5.0,
                                  ),
                                  child: Text("Verify OTP",
                                      style: TextStyle(
                                          fontFamily: Style.montserrat,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //Add Button Widget Here
                    ],
                  ),
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

  bool validateAddress() {
    // Always assume false until proven otherwise
    bool bHasContent = false;
//        String MobilePattern = "[0-9]{10}";

    if (_addressController.text.length > 0) {
      // Got content
      bHasContent = true;
    } else {
      bHasContent = false;
    }
    return bHasContent;
  }

  bool validateMob() {
    // Always assume false until proven otherwise
    bool bHasContent = false;
    String MobilePattern = "[0-9]{9}";
    RegExp regExp = new RegExp(MobilePattern);
    if (regExp.hasMatch(_mobileNumController.text)) {
      // Got content
      bHasContent = true;
    } else {
      bHasContent = false;
    }
    return bHasContent;
  }

  bool validateEmail() {
    // Always assume false until proven otherwise
    bool bHasContent = false;
    String emailPattern = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+";
    RegExp regExp = new RegExp(emailPattern);
    if (regExp.hasMatch(_emailIdController.text)) {
      // Got content
      bHasContent = true;
    } else {
      bHasContent = false;
    }
    return bHasContent;
  }

  bool validatePassword() {
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

  bool validateConfirmPassword() {
    // Always assume false until proven otherwise
    bool bHasContent = false;
//        String MobilePattern = "[0-9]{10}";

    if (_userConfirmPasswordController.text.length > 2) {
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

  otpsend() async {
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
      var parameters = {"c_emailid": _emailIdController.text};
      final response = await dio.post(ApiProvider.sendotp,
          data: parameters,
          options: Options(
              validateStatus: (_) => true,
              contentType: Headers.formUrlEncodedContentType));

      print("response " + response.toString());
      if (response.statusCode == 200) {
        print("PAVITHRAMANOJAaharan ${response.data["status"]}");

        //   Map<String, dynamic> map = jsonDecode(response.toString());
        //   RegisterModel registerModel = RegisterModel.fromJson(map);

        if (response.data["status"] == 1) {
          // _progressHUD.state.dismiss();
          ProgressDialog().dismissDialog(context);
          ToastHandler.showToast(
              message: "OTP has been Sended ${_emailIdController.text}");
        }

        //     // await SharedPreference().setAdminName(adminName);
        //     // await SharedPreference().setMobNum(mob);
        //     // await SharedPreference().setTokenKey(token_key);
        //     // await SharedPreference().setSubcribeTokenKey(subcription_tokenKey);
        //     // await SharedPreference().setAuthTokenKey(auth_tokenKey);

        //     // print("dcmsetStatus "+dcmStatus.toString());

        //     await SharedPreference().setLogin("1");
        //     await SharedPreference()
        //         .setUserId(registerModel.jResult![0].nId!.toString());
        //     await SharedPreference()
        //         .setuserName(registerModel.jResult![0].cFullName!);
        //     await SharedPreference()
        //         .setAddress(registerModel.jResult![0].cAddress!);
        //     await SharedPreference()
        //         .setUserEmail(registerModel.jResult![0].cEmailid!);

        //     await SharedPreference().setLanguage(_selectedLanguage!);

        //     ToastHandler.showToast(message: registerModel.cMessage!);

        //     Navigator.pop(context);
        //     Navigator.of(context).pushReplacement(MaterialPageRoute(
        //         builder: (BuildContext context) => DashBoardScreen()));
        //   } else {
        //     // _progressHUD.state.dismiss();
        //     ToastHandler.showToast(message: registerModel.cMessage!);
        //     ProgressDialog().dismissDialog(context);
        //   }
        // } else {
        //   // _progressHUD.state.dismiss();

        //   ToastHandler.showToast(message: "Bad Network Connection try again");
        //   ProgressDialog().dismissDialog(context);
        // }

        // print(response);
      }
    } catch (e) {
      // _progressHUD.state.dismiss();
      ProgressDialog().dismissDialog(context);
      print("Response: " + e.toString());
    }
  }

  verifyotp() async {
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
      var parameters = {"n_otp": otp, "c_emailid": _emailIdController.text};
      final response = await dio.post(ApiProvider.verifyotp,
          data: parameters,
          options: Options(
              validateStatus: (_) => true,
              contentType: Headers.formUrlEncodedContentType));

      print("response " + response.toString());
      if (response.statusCode == 200) {
        print("PAVITHRAMANOJAaharan ${response.data["n_status"]}");

        //   Map<String, dynamic> map = jsonDecode(response.toString());
        //   RegisterModel registerModel = RegisterModel.fromJson(map);

        if (response.data["n_status"] == 1) {
          // _progressHUD.state.dismiss();
          registerApi();
          ProgressDialog().dismissDialog(context);
        } else {
          ProgressDialog().dismissDialog(context);
          ToastHandler.showToast(message: response.data["c_message"]);
        }
      }
    } catch (e) {
      // _progressHUD.state.dismiss();
      ProgressDialog().dismissDialog(context);
      print("Response: " + e.toString());
    }
  }

  registerApi() async {
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
        "c_line": _mobileNumController.text,
        "c_full_name": _userUsernameController.text,
        "c_short_name": "",
        "c_emailid": _emailIdController.text,
        "c_address": "",
        "c_default_language": _selectedLanguage,
        "c_password": _userPasswordController.text,
      };
      final response = await dio.post(ApiProvider.register,
          data: parameters,
          options: Options(
              validateStatus: (_) => true,
              contentType: Headers.formUrlEncodedContentType));

      print("response " + response.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        RegisterModel registerModel = RegisterModel.fromJson(map);

        if (registerModel.nStatus == 1) {
          // _progressHUD.state.dismiss();
          ProgressDialog().dismissDialog(context);

          // await SharedPreference().setAdminName(adminName);
          // await SharedPreference().setMobNum(mob);
          // await SharedPreference().setTokenKey(token_key);
          // await SharedPreference().setSubcribeTokenKey(subcription_tokenKey);
          // await SharedPreference().setAuthTokenKey(auth_tokenKey);

          // print("dcmsetStatus "+dcmStatus.toString());

          await SharedPreference().setLogin("1");
          await SharedPreference()
              .setUserId(registerModel.jResult![0].nId!.toString());
          await SharedPreference()
              .setuserName(registerModel.jResult![0].cFullName!);
          await SharedPreference()
              .setAddress(registerModel.jResult![0].cAddress!);
          await SharedPreference()
              .setUserEmail(registerModel.jResult![0].cEmailid!);

          await SharedPreference().setLanguage(_selectedLanguage!);

          ToastHandler.showToast(message: registerModel.cMessage!);

          Navigator.pop(context);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => DashBoardScreen()));
        } else {
          // _progressHUD.state.dismiss();
          setState(() {
            sendotp = true;
          });
          ToastHandler.showToast(message: registerModel.cMessage!);
          ProgressDialog().dismissDialog(context);
        }
      } else {
        // _progressHUD.state.dismiss();
        setState(() {
          sendotp = true;
        });
        ToastHandler.showToast(message: "Bad Network Connection try again");
        ProgressDialog().dismissDialog(context);
      }

      print(response);
    } catch (e) {
      setState(() {
        sendotp = true;
      });
      // _progressHUD.state.dismiss();
      ProgressDialog().dismissDialog(context);
      print("Response: " + e.toString());
    }
  }

  getCountryList() async {
    // ProgressDialog().showLoaderDialog(context);
    try {
      ProgressDialog().showLoaderDialog(context);
      Dio dio = new Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      final response = await dio.get(ApiProvider.getCountryList,
          options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        CountryModel countryModel = CountryModel.fromJson(map);

        if (countryModel.nStatus == 1) {
          ProgressDialog().dismissDialog(context);
          updateCountryList(countryModel.jResult!);
        }
      } else {
        ProgressDialog().dismissDialog(context);
        // bannerJResultList.clear();
        print("Response: " + "Bad Network Connection try again..");
        // ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // print(response);
    } catch (e) {
      // bannerJResultList.clear();
      ProgressDialog().dismissDialog(context);
      print("Response: " + e.toString());
    }
  }
}
