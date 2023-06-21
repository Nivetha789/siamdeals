// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print, unused_local_variable, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:siamdealz/ResponseModule/BannerModel.dart';
import 'package:siamdealz/ResponseModule/MenuModule/MenuModel.dart';
import 'package:siamdealz/ResponseModule/ScrollTextModel.dart';
import 'package:siamdealz/ResponseModule/popupmodel.dart';
import 'package:siamdealz/screens/DownloadCouponListScreen.dart';
import 'package:siamdealz/screens/HtmlScreen.dart';
import 'package:siamdealz/screens/LoginScreen.dart';
import 'package:siamdealz/screens/ProfileScreen.dart';
import 'package:siamdealz/screens/SearchStoreListScreen.dart';
import 'package:siamdealz/screens/categorylist.dart';
import 'package:siamdealz/screens/top10democracy.dart';
import 'package:siamdealz/utils/CustomAlertDialog.dart';
import 'package:sizer/sizer.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ResponseModule/CategoryModel.dart';
import '../ResponseModule/CityModel.dart';
import '../ResponseModule/DemographicModel/DemographicModel.dart';
import '../core/ApiProvider/api_provider.dart';
import '../helper/AppLanguage.dart';
import '../helper/AppLocalizations.dart';
import '../utils/SharedPreference.dart';
import '../utils/check_internet.dart';
import '../utils/fab_menu_package.dart';
import '../utils/handler/toast_handler.dart';
import '../utils/resources.dart';
import '../utils/style.dart';
import 'CategoryScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with TickerProviderStateMixin {
  final CarouselController recommendedBannerController = CarouselController();
  final ScrollController scrollControllerForTopTenBanner = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController? _animationController;

  StateSetter? stateCitySetter;

  String checkLanguage = 'English';

  // City List
  final searchUnitController = TextEditingController();
  List<CityJResult> cityDataList = [];
  List<CityJResult> searchCityDataList = [];
  var cityId;
  String cityName = "Select City";
  bool checkCityListFirst = true;

  List<CategoryJResult> categoryJResultList = [];
  List<DemographicJResult> demographicJResultList = [];
  List<BannerJResult> bannerJResultList = [];

  List<PopupJResult> popupJResultList = [];
  List<MenuJResult> menuJResultList = [];

  bool checkBanner = true;
  int pageIndex = 0;

  List<String> languageList = ['English', 'Thai'];
  String? _selectedLanguage = "English";

  bool checkScrollText = false;
  String scrollText = "";

  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position _currentPosition;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  String _currentAddress = "";

  @override
  void initState() {
    super.initState();

    _selectedLanguage = languageList.first;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController!.repeat(reverse: true);

    // cityName = AppLocalizations.of(context)!.select_city!;

    // _startListeningSms();

    check().then((intenet) {
      if (intenet) {
        getDemoGraphicList();

        getMenuApi();
        getBannerList("home", "0");
        getpopupList("home", "0");
        getScrollText();
        checkcitydata();
      } else {
        ToastHandler.showToast(
            message: "Please check your internet connection");
      }
    });

    checkGps();

    // getSharedPrefs();
  }

  Future<void> checkcitydata() async {
    var citydata = await box.read('cityid');
    var cityname = await box.read('cityname');
    debugPrint("citydata $citydata");
    debugPrint("cityname $cityname");
    if (citydata == "" || citydata == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text("Please choose your City first"),
                actions: [
                  InkWell(
                    child: const Text("OK"),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      });
      //   return Text('Hello, World!');
      // })

      //  ProgressDialog().dismissDialog(context);
    } else {
      setState(() {
        cityName = cityname;
        cityId = citydata;
      });
      getCategoryList(citydata);
    }
    // setState(() {
    //   // _counter++;
    //   box.write('finalCount', _counter);
    // });
  }

  Future<void> checkpopupdata(id, name, type, description) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SingleChildScrollView(
                // height: MediaQuery.of(context).size.height / 2,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
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
                            itemBuilder:
                                (BuildContext context, int index, int realIdx) {
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
                                      child: Expanded(
                                        flex: 2,
                                        // width: 300.0,
                                        // height:
                                        //     MediaQuery.of(context).size.height /
                                        //         3,
                                        child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Image.network(
                                              popupJResultList[index]
                                                  .cBannerImage!,
                                              fit: BoxFit.fitWidth,
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
                                      ),
                                    );
                            },
                            options: CarouselOptions(
                                autoPlay:
                                    popupJResultList.isNotEmpty ? true : false,
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

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {},
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("AlertDialog"),
      content: const Text(
          "Would you like to continue learning how to use Flutter alerts?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  final box = GetStorage();

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          debugPrint("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      debugPrint("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    debugPrint(_currentPosition.longitude.toString()); //Output: 80.24599079
    debugPrint(_currentPosition.latitude.toString()); //Output: 29.6593457

    long = _currentPosition.longitude.toString();
    lat = _currentPosition.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      debugPrint(position.longitude.toString()); //Output: 80.24599079
      debugPrint(position.latitude.toString()); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });

    debugPrint("latitude $lat");
    debugPrint("longitute $long");

    _getAddressFromLatLng(_currentPosition);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition.latitude, _currentPosition.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality},${place.locality}, ${place.subAdministrativeArea} - ${place.postalCode}';

        debugPrint("_currentAddress $_currentAddress");
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  cityListener(String text) {
    if (text.isNotEmpty) {
      setState(() {
        searchCityDataList = cityDataList
            .where((u) =>
                (u.cCity!.toLowerCase().contains(text.toLowerCase()) ||
                    u.cCity!.toLowerCase().contains(text.toLowerCase())))
            .toList();

        // community = searchCommunityController.text;
      });
    } else {
      setState(() {
        searchCityDataList.clear();
        searchCityDataList.addAll(cityDataList);
      });
    }
  }

  updateCityText(String id, String text) {
    stateCitySetter!(() {
      cityId = id;
      cityName = text;
      box.write('cityid', id);
      box.write('cityname', text);
      debugPrint("asdfghjkl $id");

      // checkBanner = true;
      getBannerList("city", cityId);
      getCategoryList(id);
      getcitypopupList("city", cityId);
    });
  }

  //country
  CityTypeBottomList(context) {
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
                                    AppLocalizations.of(context)!.select_city!,
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
                              controller: searchUnitController,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    AppLocalizations.of(context)!.search_city!,
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
                                debugPrint("text $text");
                                setState(() {
                                  cityListener(text);
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 20.0),
                          child: ListView.builder(
                              itemCount: searchCityDataList.length,
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
                                      searchUnitController.text = "";
                                      updateCityText(
                                          searchCityDataList[postion].nId!,
                                          searchCityDataList[postion].cCity!);
                                      getCategoryList(
                                          searchCityDataList[postion].nId!);
                                      // getcityList("city",
                                      //     searchCityDataList[postion].nId!);
                                      Navigator.pop(context);
                                      // searchCategoryDataList[postion].addremove =
                                      // !searchCategoryDataList[postion]
                                      //     .addremove!;
                                      //uyghjb  addRemoveCountry(
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
                                              searchCityDataList[postion]
                                                  .cCity!,
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

  updateCityList(List<CityJResult> cityDataList1) {
    cityDataList.clear();
    setState(() {
      cityDataList.addAll(cityDataList1);
    });

    if (checkCityListFirst) {
      CityTypeBottomList(context);
    }
  }

  updateCategoryList(List<CategoryJResult> categoryJResultList1) {
    print("fddfkjsfjhsdf $categoryJResultList");
    categoryJResultList.clear();
    categoryJResultList = [];
    setState(() {
      categoryJResultList.addAll(categoryJResultList1);
    });
  }

  updateMenuList(List<MenuJResult> menuJResultList1) {
    menuJResultList.clear();
    setState(() {
      menuJResultList.add(MenuJResult(nPageId: "0", cPages: "Profile"));
      menuJResultList
          .add(MenuJResult(nPageId: "0", cPages: "Downloaded Coupons"));
      menuJResultList.addAll(menuJResultList1);
    });
  }

  updateDemoGraphicList(List<DemographicJResult> demographicJResultList1) {
    demographicJResultList.clear();
    setState(() {
      demographicJResultList.addAll(demographicJResultList1);
    });
  }

  updateBannerList(List<BannerJResult> bannerJResultList1) {
    debugPrint("PAvithramanoharan ${bannerJResultList1.toString()}");
    for (int i = 0; i < bannerJResultList1.length; i++) {
      debugPrint("PAVITHRAMANOHARAN ${bannerJResultList1[i]}");
    }
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

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);
    // switch (_selectedLanguage) {
    //   case "English":
    //     appLanguage.changeLanguage(Locale("en"));
    //     break;
    //   case "Thai":
    //     appLanguage.changeLanguage(Locale("th"));
    //     break;
    //   default:
    //     appLanguage.changeLanguage(Locale("en"));
    //     break;
    // }
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Style.colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              box.remove('cityid');
              box.remove("popuphomeid");

              box.remove("popupcityid");
              box.remove('cityname');
              box.remove('categoryid');
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => this.widget));
            },
            child: Image.asset(
              Resources.assets.logo,
            ),
          ),
        ),
        centerTitle: false,
        title: checkScrollText
            ? InkWell(
                onTap: () {
                  if (cityId == null || cityId == "") {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      return await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content:
                                  const Text("Please choose your City first"),
                              actions: [
                                InkWell(
                                  child: const Text("OK"),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    });
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Top10Democracy(
                                id: dealzid, cityid: cityId, name: dealzname)));
                  }
                },
                child: TextScroll(
                  scrollText,
                  mode: TextScrollMode.endless,
                  velocity: const Velocity(pixelsPerSecond: Offset(100, 0)),
                  delayBefore: const Duration(milliseconds: 2000),
                  pauseBetween: const Duration(milliseconds: 1000),
                  style: TextStyle(
                    color: Style.colors.logoOrange,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.right,
                  selectable: true,
                ),
              )
            : Container(
                child: Text(
                  AppLocalizations.of(context)!.appName!,
                  style: TextStyle(color: Style.colors.logoRed, fontSize: 17.0),
                ),
              ),
        // title: checkBanner
        //     ? FadeTransition(
        //   opacity: _animationController!,
        //   child: Container(
        //     width: MediaQuery.of(context).size.width,
        //     decoration: BoxDecoration(
        //       color: Style.colors.primary.withOpacity(0.2),
        //       borderRadius: BorderRadius.circular(8.0),
        //       border: Border.all(
        //           color: Style.colors.primary.withOpacity(0.5)),
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        //       child: Container(
        //         alignment: Alignment.centerLeft,
        //         margin: EdgeInsets.only(left: 10.0),
        //         child: Column(
        //           children: [
        //             Text(
        //               "Find Best Places!",
        //               style: TextStyle(
        //                   color: Style.colors.primary,
        //                   fontSize: 14.0,
        //                   fontWeight: FontWeight.w500),
        //               textAlign: TextAlign.start,
        //             ),
        //             Text(
        //               "Near by you!",
        //               style: TextStyle(
        //                   color: Style.colors.primary,
        //                   fontSize: 13.0,
        //                   fontWeight: FontWeight.w400),
        //               textAlign: TextAlign.start,
        //             ),
        //           ],
        //           mainAxisAlignment: MainAxisAlignment.start,
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //         ),
        //       ),
        //     ),
        //   ),
        // )
        //     : Container(
        //   child: Text(
        //     AppLocalizations.of(context)!.appName!,
        //     style: TextStyle(color: Style.colors.logoRed, fontSize: 17.0),
        //   ),
        // ),
        iconTheme: IconThemeData(color: Style.colors.logoRed),
        backgroundColor: Colors.white,
        //  brightness: Brightness.light,
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
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SearchStoreListScreen(0, cityId, "", false)));
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
              Expanded(
                flex: 11,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    stateCitySetter = setState;
                    return ListView(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: DropdownButton(
                                  underline: const DropdownButtonHideUnderline(
                                      child: SizedBox()),
                                  iconSize: 0.0,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0)),
                                  items: languageList.map((String location) {
                                    return DropdownMenuItem(
                                      value: location,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          location,
                                          style: TextStyle(
                                              color: Style.colors.app_black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  hint: Container(
                                    margin: const EdgeInsets.only(
                                        top: 20.0, left: 16.0, right: 16.0),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 5.0),
                                            child: Text(
                                              _selectedLanguage!,
                                              style: TextStyle(
                                                  color: Style.colors.app_black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w400),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Container(
                                            child: Icon(
                                              Icons.language_sharp,
                                              size: 20.0,
                                              color: Style.colors.logoRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() async {
                                      _selectedLanguage = value!;
                                      debugPrint(
                                          "_selectedLanguage $_selectedLanguage");
                                      switch (_selectedLanguage) {
                                        case "English":
                                          appLanguage.changeLanguage(
                                              const Locale("en"));
                                          break;
                                        case "Thai":
                                          appLanguage.changeLanguage(
                                              const Locale("th"));
                                          break;
                                        default:
                                          appLanguage.changeLanguage(
                                              const Locale("en"));
                                          break;
                                      }
                                      await SharedPreference()
                                          .setLanguage(_selectedLanguage!);
                                    });
                                  },
                                )),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      searchCityDataList.clear();
                                      searchCityDataList.addAll(cityDataList);
                                    });

                                    if (checkCityListFirst) {
                                      check().then((intenet) {
                                        if (intenet != null && intenet) {
                                          // CityTypeBottomList(context);
                                          getCityList();
                                        } else {
                                          ToastHandler.showToast(
                                              message:
                                                  "Please check your internet connection");
                                        }
                                      });
                                    } else {
                                      CityTypeBottomList(context);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        top: 20.0, left: 16.0, right: 16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 5.0),
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              cityName,
                                              style: TextStyle(
                                                  color: Style.colors.app_black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            child: Icon(
                                              Icons.location_city_sharp,
                                              size: 20.0,
                                              color: Style.colors.logoRed,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        Container(
                          color: Colors.grey.withOpacity(0.3),
                          width: MediaQuery.of(context).size.width,
                          height: 1.0,
                          margin: const EdgeInsets.only(top: 10.0),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.location_on_outlined,
                                              size: 20.0,
                                              color: Style.colors.logoRed),
                                          Flexible(
                                            child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5.0),
                                                child: Text(
                                                  _currentAddress,
                                                  style: TextStyle(
                                                      fontFamily: Style.brandon,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14.0,
                                                      color: Style
                                                          .colors.app_black),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        getLocation();
                                      },
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Icon(Icons.my_location,
                                            size: 20.0,
                                            color: Style.colors.logoRed),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.grey.withOpacity(0.3),
                          width: MediaQuery.of(context).size.width,
                          height: 1.0,
                          margin: const EdgeInsets.only(top: 10.0),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          height: 90.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 16.0, right: 16.0, top: 10.0),
                                child: ListView.builder(
                                    itemCount: demographicJResultList.length,
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
                                            if (cityId == null ||
                                                cityId == "") {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback(
                                                      (_) async {
                                                return await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        content: const Text(
                                                            "Please choose your City first"),
                                                        actions: [
                                                          InkWell(
                                                            child: const Text(
                                                                "OK"),
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              });
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => Top10Democracy(
                                                          id: demographicJResultList[
                                                                  postion]
                                                              .nId!,
                                                          cityid: cityId,
                                                          name: demographicJResultList[
                                                                  postion]
                                                              .cDemographic!)));
                                            }
                                            setState(() {});
                                          },
                                          child: Container(
                                            width: 120.0,
                                            margin: const EdgeInsets.only(
                                                left: 10.0),
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(5.0),
                                                    bottomRight:
                                                        Radius.circular(5.0))),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 10.0),
                                                    child: Text(
                                                        demographicJResultList[
                                                                postion]
                                                            .cDemographic!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 13.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.black,
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
                                                                cityId)));
                                              },
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .view_all!,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Style
                                                            .colors.logoRed,
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
                                          physics:
                                              const ClampingScrollPhysics(),
                                          itemBuilder: (BuildContext context,
                                              int index) {
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
                                                                  cityId,
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
                                                          color: Style
                                                              .colors.grey
                                                              .withOpacity(
                                                                  .2))),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
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
                                                                fit: BoxFit
                                                                    .cover,
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
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily: Style
                                                                  .montserrat)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                    SizedBox(
                                      height: 10.sp,
                                    ),
                                    SizedBox(
                                      height: 15.sp,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        Visibility(
                          visible: checkBanner,
                          child: Column(
                            children: [
                              bannerJResultList.isNotEmpty
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 15.0),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .city_spotLight!,
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: Style.josefinsans)),
                                    )
                                  : Container(),
                              bannerJResultList.isNotEmpty
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 15.0),
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
                                              width: 300.0,
                                              height: 200.0,
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: bannerJResultList[index]
                                                            .cBannerLink ==
                                                        null
                                                    ? Image.network(
                                                        bannerJResultList[index]
                                                            .cBannerImage!,
                                                        fit: BoxFit.fitWidth,
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
                                                          bannerJResultList[
                                                                  index]
                                                              .cBannerImage!,
                                                          fit: BoxFit.fitWidth,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          );
                                        },
                                        options: CarouselOptions(
                                            autoPlay:
                                                bannerJResultList.isNotEmpty
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
                                    )
                                  : Container(),
                              bannerJResultList.isNotEmpty
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 5.0),
                                      child: CarouselIndicator(
                                        count: bannerJResultList.length,
                                        index: pageIndex,
                                        color:
                                            Style.colors.grey.withOpacity(0.3),
                                        activeColor: Style.colors.logoRed,
                                        width: 10.0,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        box.remove('cityid');
                        box.remove("popuphomeid");

                        box.remove("popupcityid");
                        box.remove('cityname');
                        box.remove('categoryid');
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => this.widget));
                      },
                      child: SizedBox(
                        width: 80.0,
                        height: 80.0,
                        child: Image.asset(
                          'images/logo.png',
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          AppLocalizations.of(context)!.description!,
                          style: TextStyle(
                              color: Style.colors.app_black,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              fontSize: 14.0),
                        )),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                child: Divider(
                  thickness: 0.5,
                  height: 1.0,
                  color: Style.colors.logoRed.withOpacity(0.1).withOpacity(0.3),
                ),
              ),
              // GestureDetector(
              //   onTap: () async {
              //     Navigator.pop(context);

              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => Top10Democracy(
              //                 id: dealzid, cityid: cityId, name: dealzname)));
              //   },
              //   child: Container(
              //     margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              //     width: MediaQuery.of(context).size.width,
              //     child: Column(
              //       children: [
              //         Container(
              //           alignment: Alignment.centerLeft,
              //           width: MediaQuery.of(context).size.width,
              //           child: Padding(
              //             padding: const EdgeInsets.only(
              //               left: 20.0,
              //               top: 10.0,
              //             ),
              //             child: Text(
              //               "DealZ Near Me",
              //               style: TextStyle(
              //                   color: Colors.black87,
              //                   fontSize: 14.0,
              //                   fontWeight: FontWeight.w400,
              //                   fontFamily: Style.sfproddisplay),
              //             ),
              //           ),
              //         ),
              //         Container(
              //           margin: const EdgeInsets.only(
              //             top: 10.0,
              //           ),
              //           child: Divider(
              //             thickness: 0.5,
              //             height: 1.0,
              //             color: const Color(0xff818EA7).withOpacity(0.3),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              Container(
                margin:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                child: ListView.builder(
                    itemCount: menuJResultList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, postion) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);

                          if (menuJResultList[postion].nPageId == "0") {
                            switch (menuJResultList[postion].cPages) {
                              case "Profile":
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen()));
                                break;
                              case "Downloaded Coupons":
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DownloadedCouponListScreen()));
                                break;
                            }
                          } else {
                            if (menuJResultList[postion]
                                .cDescription!
                                .isNotEmpty) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HtmlScreen(
                                          menuJResultList[postion].nPageId!)));
                            } else {
                              if (menuJResultList[postion]
                                  .cPageLink!
                                  .isNotEmpty) {
                                await launchUrl(
                                  Uri.parse(
                                      menuJResultList[postion].cPageLink!),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ToastHandler.showToast(
                                    message: "Redirect link Not found");
                              }
                            }
                          }
                        },
                        child: Container(
                          margin:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, top: 10.0, bottom: 5.0),
                                  child: Text(
                                    menuJResultList[postion].cPages!,
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: Style.sfproddisplay),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, bottom: 5.0),
                                child: Divider(
                                  thickness: 0.5,
                                  height: 1.0,
                                  color:
                                      const Color(0xff818EA7).withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              InkWell(
                onTap: () {
                  var dialog = CustomAlertDialog(
                    title: "Logout",
                    message: "Are you sure, do you want to logout?",
                    onPostivePressed: () async {
                      Navigator.pop(context);

                      box.remove('cityid');
                      box.remove("popuphomeid");

                      box.remove("popupcityid");
                      box.remove('cityname');
                      box.remove('categoryid');
                      await SharedPreference().clearSharep().then((v) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => LoginScreen()));
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
                  margin: const EdgeInsets.only(top: 60, left: 30, right: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Style.colors.white.withOpacity(0.3), width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    color: Style.colors.logoRed,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(
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
              const SizedBox(
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp no installed")));
      }
    } else {
      // android , web
      if (await canLaunch(whatsappURl_android)) {
        await launchUrl(Uri.parse(whatsappURl_android));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp no installed")));
      }
    }
  }

  openbannerlaunchurl(url) async {
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

  getCityList() async {
    try {
      //  ProgressDialog().showLoaderDialog(context);

      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      final response = await dio.get(
        ApiProvider.getCity,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        CityModel cityModel = CityModel.fromJson(map);

        if (cityModel.nStatus == 1) {
          //  ProgressDialog().dismissDialog(context);

          setState(() {
            checkCityListFirst = false;
          });

          updateCityList(cityModel.jResult!);
        } else {
          //   ProgressDialog().dismissDialog(context);
        }
      } else {
        //    ProgressDialog().dismissDialog(context);

        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      //  ProgressDialog().dismissDialog(context);
      debugPrint("Response11: $e");
    }
  }

  var dealzid;
  var dealzname;
  getDemoGraphicList() async {
    try {
      //   ProgressDialog().showLoaderDialog(context);

      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      final response = await dio.get(
        ApiProvider.getDemographic,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        DemographicModel demographicModel = DemographicModel.fromJson(map);

        if (demographicModel.nStatus == 1) {
          //   ProgressDialog().dismissDialog(context);
          for (var i = 0; i < demographicModel.jResult!.length; i++) {
            if (demographicModel.jResult![i].cDemographic ==
                "DealZ Near Me     коло меня") {
              print(
                  "pamuishra   ${demographicModel.jResult![i].cDemographic}            ");

              setState(() {
                dealzid = demographicModel.jResult![i].nId;
                dealzname = demographicModel.jResult![i].cDemographic;
              });
            }
          }
          updateDemoGraphicList(demographicModel.jResult!);
        } else {
          //  ProgressDialog().dismissDialog(context);
        }
      } else {
        // ProgressDialog().dismissDialog(context);

        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      //  ProgressDialog().dismissDialog(context);
      debugPrint("Response22: $e");
    }
  }

  getCategoryList(id) async {
    debugPrint("Id $id");
    try {
      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      var parameters = {"n_parent": 0, "n_city": id};
      final response = await dio.post(ApiProvider.getCategory,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      if (response.statusCode == 200) {
        debugPrint(
            "pavithraManoharan12345678913hgjhdgsfjfsdjfhg ${response.data}");
        Map<String, dynamic> map = jsonDecode(response.toString());
        CategoryModel categoryModel = CategoryModel.fromJson(map);
        // print("fddfkjsfjhsdf122 ${categoryModel.nStatus}");
        setState(() {
          categoryJResultList = [];
        });
        if (categoryModel.nStatus == 1) {
          updateCategoryList(categoryModel.jResult!);
        }
      } else {
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      //ProgressDialog().dismissDialog(context);
      debugPrint("Response33: $e");
    }
  }

  getMenuApi() async {
    try {
      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      final response = await dio.get(
        ApiProvider.getMenuPages,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        MenuModel menuModel = MenuModel.fromJson(map);

        if (menuModel.nStatus == 1) {
          updateMenuList(menuModel.jResult!);
        }
      } else {
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      //  ProgressDialog().dismissDialog(context);
      debugPrint("Response44: $e");
    }
  }

  getBannerList(String type, String actionId) async {
    try {
      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);
      debugPrint("vsfdsfsdfdsf ${type}  actionid${actionId}");
      var parameters = {"c_type": type, "n_city": actionId};

      final response = await dio.post(ApiProvider.getBanner,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        debugPrint("vsfdsfsdsf ${response.toString()}");
        BannerModel bannerModel = BannerModel.fromJson(map);
        debugPrint("PAvithramanoharan ${bannerModel.jResult}");
        if (bannerModel.nStatus == 1) {
          updateBannerList(bannerModel.jResult!);
        }
      } else {
        // bannerJResultList.clear();
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      // bannerJResultList.clear();
      //  ProgressDialog().dismissDialog(context);
      debugPrint("Response55: $e");
    }
  }

  getpopupList(String type, String actionId) async {
    try {
      Dio dio = Dio();
      debugPrint("vsfdsfsdfdsf ${type}  actionid${actionId}");
      var parameters = {"c_type": type, "n_city": actionId};

      final response = await dio.post(ApiProvider.getPopup,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);
      debugPrint("vsfdsfsdsf12333 ${response.data["j_result"][0]["n_id"]}");
      var popuphomeid = await box.read('popuphomeid');

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        debugPrint("vsfdsfsdsf12333 ${map["j_result"][0]}");
        PopupModel popupModel = PopupModel.fromJson(map);
        debugPrint("PAvithramanoharan123444 ${popupModel.jResult}");
        if (popuphomeid != map["j_result"][0]["n_id"]) {
          if (popupModel.nStatus == 1) {
            updatePopupList(
                popupModel.jResult!,
                map["j_result"][0]["n_id"],
                map["j_result"][0]["c_title"],
                map["j_result"][0]["n_popup_type"],
                map["j_result"][0]["c_description"]);
          }
        }
        // if (popupModel.nStatus == 1) {
        //   updatePopupList(popupModel.jResult!);
        // }
      } else {
        // bannerJResultList.clear();
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      // bannerJResultList.clear();
      //  ProgressDialog().dismissDialog(context);
      debugPrint("Response55: $e");
    }
  }

  getcitypopupList(String type, String actionId) async {
    try {
      Dio dio = Dio();
      debugPrint("vsfdsfsdfdsf ${type}  actionid${actionId}");
      var parameters = {"c_type": type, "n_city": actionId};

      final response = await dio.post(ApiProvider.getPopup,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);
      debugPrint("vsfdsfsdsf12333 ${response.data["j_result"][0]["n_id"]}");
      var popupcityid = await box.read('popupcityid');
      debugPrint("popupcityid $popupcityid");
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        debugPrint("vsfdsfsdsf12333 ${map["j_result"][0]["c_banner_image"]}");
        PopupModel popupModel = PopupModel.fromJson(map);
        debugPrint("PAvithramanoharan123444 ${popupModel.jResult}");
        if (popupcityid != map["j_result"][0]["n_id"]) {
          if (popupModel.nStatus == 1) {
            updatePopupList(
                popupModel.jResult!,
                map["j_result"][0]["n_id"],
                map["j_result"][0]["c_title"],
                map["j_result"][0]["n_popup_type"],
                map["j_result"][0]["c_description"]);
          }
        }
      } else {
        // bannerJResultList.clear();
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      // bannerJResultList.clear();
      //  ProgressDialog().dismissDialog(context);
      debugPrint("Response55: $e");
    }
  }

  getScrollText() async {
    try {
      Dio dio = Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      // var parameters = {"LoginRegNo": regno, "UserRegNo": toRegNo};
      // dio.options.contentType = Headers.formUrlEncodedContentType;
      // final response = await dio.post(
      //     ApiProvider.getCity,
      //     options: Options(contentType: Headers.formUrlEncodedContentType),
      //     data: parameters);

      final response = await dio.get(ApiProvider.getScrollText,
          options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        ScrollTextModel scrollTextModel = ScrollTextModel.fromJson(map);

        if (scrollTextModel.nStatus == 1) {
          setState(() {
            checkScrollText = true;
            scrollText = scrollTextModel.jResult![0].cText!;
          });
        }
      } else {
        setState(() {
          checkScrollText = false;
        });
        // bannerJResultList.clear();
        debugPrint("Response666: " + "Bad Network Connection try again..");
        // ToastHandler.showToast(message: "Bad Network Connection try again..");
      }
      // debugPrint(response);
    } catch (e) {
      // bannerJResultList.clear();.
      debugPrint("Response66: $e");
    }
  }

// _startListeningSms() async {
//   String otp =
//       "<#> 56456151 is your OTP to Sign-In to Your app name. It's valid for 30 mins. Don't share it with anyone. xyZaBcD2EFg";
//   if (otp.isNotEmpty || otp != null) {
//     String otp1 = otp.split(" ")[1];
//     debugPrint("otp1 " + otp1);
//   }
// }
}
