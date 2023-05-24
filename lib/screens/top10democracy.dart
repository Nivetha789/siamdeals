// ignore_for_file: prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
// import 'package:getwidget/getwidget.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:siamdealz/core/ApiProvider/api_provider.dart';
import 'package:siamdealz/utils/style.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../ResponseModule/SearchVendorModule/SearchVendorModel.dart';
import '../helper/AppLocalizations.dart';
import '../utils/ProgressDialog.dart';
import '../utils/handler/toast_handler.dart';
import 'StoreDetailsScreen.dart';

class Top10Democracy extends StatefulWidget {
  const Top10Democracy({Key? key, this.id, this.cityid, this.name})
      : super(key: key);

  final id;
  final cityid;
  final name;

  @override
  State<Top10Democracy> createState() => _Top10DemocracyState();
}

class _Top10DemocracyState extends State<Top10Democracy> {
  bool checkInbox = false;
  bool haspermission = false;
  String long = "", lat = "";
  List<SearchVendorJResult> particularDemocracylist = [];
  late LocationPermission permission;
  late StreamSubscription<Position> positionStream;
  bool servicestatus = false;

  String _currentAddress = "";
  late Position _currentPosition;
  List<String> items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];
  @override
  void initState() {
    super.initState();
    getLocation(0, 0);
    // getDistanceList();
    getDistancefilterList();
    // getSharedPrefs();
  }

  getLocation(int value, distance) async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    debugPrint(_currentPosition.longitude.toString()); //Output: 80.24599079
    debugPrint(_currentPosition.latitude.toString()); //Output: 29.6593457

    long = _currentPosition.longitude.toString();
    lat = _currentPosition.latitude.toString();
    value == 0 ? particulardemocracy("1") : particulardemocracywithsort("2");
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

    debugPrint("latitude " + lat);
    debugPrint("longitute " + long);

    _getAddressFromLatLng(_currentPosition);
  }

  //**particular democracy api start **//
  Future<dynamic> particulardemocracy(nview) async {
    ProgressDialog().showLoaderDialog(context);
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request('POST',
        Uri.parse('${ApiProvider.BASE_URL}demographic/getdemographiclisting'));
    request.bodyFields = {
      'n_limit': '10',
      'n_offset': '2',
      'n_page': '1',
      'c_search': '',
      'c_demographic': widget.id,
      'n_latitude': lat,
      'n_longitude': long,
      'n_view': nview
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    particularDemocracylist = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> map =
          jsonDecode(await response.stream.bytesToString());

      for (var i = 0; i < map["j_result"].length; i++) {
        particularDemocracylist
            .add(SearchVendorJResult.fromJson(map["j_result"][i]));
      }
      setState(() {
        ProgressDialog().dismissDialog(context);
      });

      // debugPrint("pavithra ${await response.stream.bytesToString()}");
    } else {
      setState(() {
        ProgressDialog().dismissDialog(context);
      });
      debugPrint(" ${response.reasonPhrase}");
    }
  }

  Future<dynamic> particulardemocracywithsort(nview) async {
    debugPrint("DFSDFSDFSDFSD");
    ProgressDialog().showLoaderDialog(context);
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var request = http.Request('POST',
        Uri.parse('${ApiProvider.BASE_URL}demographic/getDemographicListing'));
    request.bodyFields = {
      'n_limit': '10',
      'n_offset': '2',
      'n_page': '1',
      'c_search': '',
      'c_demographic': widget.id,
      'n_latitude': lat,
      'n_longitude': long,
      'n_view': nview.toString(),
      'n_distance': selectedOption.toString(),
      'n_category': selectedsubcategory.join(', ').toString(),
      'n_district': selectedtowncategory.join(', ').toString(),
      'n_town': "",
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    particularDemocracylist = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> map =
          jsonDecode(await response.stream.bytesToString());
      setState(() {
        ProgressDialog().dismissDialog(context);
      });
      for (var i = 0; i <= map["j_result"].length; i++) {
        particularDemocracylist
            .add(SearchVendorJResult.fromJson(map["j_result"][i]));
      }
      setState(() {
        ProgressDialog().dismissDialog(context);
      });

      // debugPrint("pavithra ${await response.stream.bytesToString()}");
    } else {
      setState(() {
        ProgressDialog().dismissDialog(context);
      });
      debugPrint(" ${response.reasonPhrase}");
    }
  }

  List<Map<String, dynamic>> distancelist = [];

  List<Map<String, dynamic>> districtlist = [];
  getDistanceList() async {
    try {
      //   ProgressDialog().showLoaderDialog(context);

      Dio dio = Dio();

      final response = await dio.get(
        ApiProvider.getDistanceList,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      debugPrint("PAVITHRAM2132434234 ${response.toString()}");
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        distancelist = List<Map<String, dynamic>>.from(map["data"]);
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

  var selectedSubcategories;

  List<Map<String, dynamic>> categoryList = [];

  // List<Map<String, dynamic>> subcategoryList = [];
  // List<Map<String, dynamic>> subcategoryList = [];

  List selectedsubcategory = [];

  List selectedtowncategory = [];
  List<Map<String, dynamic>> subcategoryList = [];
  Set<Map<String, dynamic>> seenItems = {};
  List<MultiSelectItem<Object?>> convertedList = [];

  List<Map<String, dynamic>> towncategoryList = [];
  List<MultiSelectItem<Object?>> townconvertedList = [];
  getDistancefilterList() async {
    try {
      //   ProgressDialog().showLoaderDialog(context);
      Set<dynamic> uniqueSubcategories = Set<dynamic>();
      Dio dio = Dio();
      var parameters = {"n_city": widget.cityid};
      final response = await dio.post(ApiProvider.getfilterList,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        debugPrint("PAVITHRAMMMM ${map["data"]["town_list"]}");
        distancelist =
            List<Map<String, dynamic>>.from(map["data"]["distance_list"]);
        selectedOption =
            map["data"]["distance_list"][0]["distance_id"].toString();
        districtlist =
            List<Map<String, dynamic>>.from(map["data"]["town_list"]);
        selectedtowncategory = [map["data"]["town_list"][0]["district_id"]];
        debugPrint(selectedtowncategory.toString());

        categoryList =
            List<Map<String, dynamic>>.from(map["data"]["category_list"]);
        selectedsubcategory = [
          map["data"]["category_list"][0]['sub_category'][0]["subcategory_id"]
        ];
        Set<String> uniqueItems = {};
        Set<String> uniquetownItems = {};
        subcategoryList = [];
        towncategoryList = [];
        debugPrint(
            "fdghjhghjdrghjdfghjfgf $selectedOption $selectedtowncategory $selectedsubcategory");
        for (var category in categoryList) {
          var subCategories = category['sub_category'];

          // Iterate over sub_categories if it's not empty
          if (subCategories != null && subCategories.isNotEmpty) {
            for (var subCategory in subCategories) {
              // debugPrint("dfgjdkfghkfhgdfgh${subCategory}");
              // selectedsubcategory = subCategory[0]["subcategory_id"];
              var subCategoryString =
                  subCategory.toString(); // Convert to string
              if (!uniqueItems.contains(subCategoryString)) {
                subcategoryList.add(subCategory);
                uniqueItems.add(subCategoryString);
              }
            }
          }
        }
        // debugPrint(
        //     "fdghjhghjdrghjdfghjfgf $selectedOption $selectedtowncategory $selectedsubcategory");

        convertedList = subcategoryList.map((animal) {
          return MultiSelectItem<Object?>(
            animal['subcategory_id'],
            animal['c_category'],
          );
        }).toList();

        // convertedList.forEach((item) {
        //   // debugPrint('Subcategory ID: ${item.value}, Category: ${item.label}');
        // });

        // Iterate over sub_categories if it's not empty
        if (districtlist != null && districtlist.isNotEmpty) {
          for (var distrctt in districtlist) {
            // selectedtowncategory = distrctt[0]["district_id"];

            // selectedtowncategory = distrctt[0]["district_id"];
            var districtString = distrctt.toString(); // Convert to string
            if (!uniquetownItems.contains(districtString)) {
              towncategoryList.add(distrctt);
              uniquetownItems.add(districtString);
            }
          }
        }
        debugPrint(
            "fdghjhghjdrghjdfghjfgf $selectedOption $selectedtowncategory $selectedsubcategory");

        townconvertedList = towncategoryList.map((town) {
          return MultiSelectItem<Object?>(
            town['district_id'],
            town['c_town'],
          );
        }).toList();

        // townconvertedList.forEach((item) {
        //   debugPrint('Subcategory ID: ${item.value}, Category: ${item.label}');
        // });
      } else {
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }

      // debugPrint(response);
    } catch (e) {
      //  ProgressDialog().dismissDialog(context);
      debugPrint("Response22: $e");
    }
  }

  List multipleSelected = [];

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition.latitude, _currentPosition.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality},${place.locality}, ${place.subAdministrativeArea} - ${place.postalCode}';

        debugPrint("_currentAddress " + _currentAddress);
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  String selectedOption = "";

  String selecteddistrict = "";
  List<dynamic> selectedCategories = [];
  List? _myActivities;
  // List? selectedsubcategory = [];
  String noDataText = 'Data Not Found';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Style.colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: const BackButton(),
        centerTitle: true,
        title: Text(
          widget.name,
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Style.colors.logoRed,
              fontSize: 17.0,
              fontFamily: Style.montserrat),
        ),
        iconTheme: IconThemeData(color: Style.colors.logoRed),
        backgroundColor: Colors.white,
        //   brightness: Brightness.light,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 20.0, color: Style.colors.logoRed),
                          Flexible(
                            child: Container(
                                margin: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  _currentAddress,
                                  style: TextStyle(
                                      fontFamily: Style.brandon,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14.0,
                                      color: Style.colors.app_black),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          getLocation(1, "1");
                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.my_location,
                              size: 20.0, color: Style.colors.logoRed),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 10),
              Container(
                width: 110,
                height: 47,
                child: MultiSelectDialogField(
                  // backgroundColor: Colors.transparent,
                  items: convertedList,
                  separateSelectedItems: false,
                  chipDisplay: MultiSelectChipDisplay<String>(
                    chipWidth: 70,
                    height: 0,
                    scroll: true,
                    chipColor: Colors.blue,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  // chipDisplay: ,
                  buttonText:
                      // selectedsubcategory.isEmpty ||
                      //         selectedsubcategory == null ||
                      //         selectedsubcategory.length == 0
                      //     ? Text("selectText")
                      // :
                      Text("Category"),

                  selectedColor: Colors.blue,
                  decoration: BoxDecoration(
                    // color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.0,
                      // assign the color to the border color
                      color: Colors.grey,
                    ),
                  ),
                  buttonIcon: const Icon(
                    Icons.filter_list_sharp,
                    // color: Colors.blue,
                  ),

                  onConfirm: (results) {
                    debugPrint("Sdsfsdfsdfsdf $results");
                    setState(() {
                      selectedsubcategory = results;
                    });
                    debugPrint(selectedsubcategory.join(', '));

                    debugPrint("selectedSubcategories $selectedsubcategory");
                    particulardemocracywithsort(2);
                    //_selectedAnimals = results;
                  },
                  onSaved: (results) {
                    debugPrint("Sdsfsdfsdfsdf $results");
                    setState(() {
                      selectedsubcategory = results!;
                    });
                    debugPrint("selectedsubcategory $selectedsubcategory");
                    //_selectedAnimals = results;
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                width: 110,
                height: 47,
                child: MultiSelectDialogField(
                  // backgroundColor: Colors.transparent,
                  items: townconvertedList,
                  separateSelectedItems: false,
                  chipDisplay: MultiSelectChipDisplay<String>(
                    chipWidth: 70,
                    height: 0,
                    scroll: true,
                    chipColor: Colors.blue,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  // chipDisplay: ,
                  buttonText:
                      // selectedsubcategory.isEmpty ||
                      //         selectedsubcategory == null ||
                      //         selectedsubcategory.length == 0
                      //     ? Text("selectText")
                      // :
                      Text("Town"),

                  selectedColor: Colors.blue,
                  decoration: BoxDecoration(
                    // color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.0,
                      // assign the color to the border color
                      color: Colors.grey,
                    ),
                  ),
                  buttonIcon: const Icon(
                    Icons.filter_list_sharp,
                    // color: Colors.blue,
                  ),

                  onConfirm: (results) {
                    debugPrint("Sdsfsdfsdfsdf $results");
                    setState(() {
                      selectedtowncategory = results;
                    });
                    debugPrint(selectedtowncategory.join(', '));

                    debugPrint("selectedSubcategories $selectedtowncategory");
                    particulardemocracywithsort(2);
                    //_selectedAnimals = results;
                  },
                  onSaved: (results) {
                    debugPrint("Sdsfsdfsdfsdf $results");
                    setState(() {
                      selectedtowncategory = results!;
                    });
                    debugPrint("selectedsubcategory $selectedtowncategory");
                    //_selectedAnimals = results;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1.0,
                    // assign the color to the border color
                    color: Colors.grey,
                  ),
                ),
                // width: 100,
                height: 40,

                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    // const Icon(Icons.filter_list_sharp),
                    Container(
                      alignment: Alignment.topCenter,
                      width: 80,
                      height: 40,
                      child: DropdownButtonFormField(
                        isDense: true,
                        isExpanded: true,
                        // value: selectedOption,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(0.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ), // value: _chosenValue,
                        //elevation: 5,
                        style: const TextStyle(color: Colors.black),
                        icon: Icon(Icons.filter_list),
                        items: distancelist.map((Map<String, dynamic> option) {
                          return DropdownMenuItem(
                            value: option['distance_id'].toString(),
                            child: SizedBox(
                                width: 100,
                                child: Text(
                                  option['distance_val'],
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                )),
                          );
                        }).toList(),
                        hint: const Text("Distance"),
                        onChanged: (newValue) {
                          debugPrint("distancelist $distancelist");
                          debugPrint("newValue $newValue");
                          // getLocation(2, newValue.toString());
                          setState(() {
                            selectedOption = newValue!;
                          });
                          debugPrint("selectedOption $selectedOption");

                          particulardemocracywithsort(2);
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          Container(
            color: Colors.grey.withOpacity(0.3),
            width: MediaQuery.of(context).size.width,
            height: 1.0,
            margin: const EdgeInsets.only(top: 10.0),
          ),
          particularDemocracylist.isEmpty
              ? Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 250),
                    child: Text(
                      noDataText,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Style.colors.grey),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: particularDemocracylist.length,
                      itemBuilder: (BuildContext context, index) {
                        String openTime = "";
                        String closeTime = "";
                        bool checkLeave = false;

                        if (particularDemocracylist[index].jCurrentDay!.open ==
                                null &&
                            particularDemocracylist[index].jCurrentDay!.close ==
                                null) {
                          openTime = " (Leave)";
                          closeTime = "";
                          checkLeave = true;
                        } else if (particularDemocracylist[index]
                                    .jCurrentDay!
                                    .open !=
                                null &&
                            particularDemocracylist[index].jCurrentDay!.close ==
                                null) {
                          openTime = " (Open - 24 Hours)";
                          closeTime = "";
                          checkLeave = false;
                        } else {
                          openTime = "(Open - " +
                              particularDemocracylist[index]
                                  .jCurrentDay!
                                  .open
                                  .toString();
                          closeTime = " - Close - " +
                              particularDemocracylist[index]
                                  .jCurrentDay!
                                  .close
                                  .toString() +
                              ")";
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
                                  builder: (context) => StoreDetailsScreen(
                                    particularDemocracylist[index].nId!,
                                    particularDemocracylist[index].cName!,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.sp)),
                              child: Column(
                                children: [
                                  Container(
                                    height: 20.5.h,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.sp),
                                            topRight: Radius.circular(10.sp)),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                particularDemocracylist[index]
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: Text(
                                                particularDemocracylist[index]
                                                    .cName!,
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color:
                                                        Style.colors.app_black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: Text(
                                                particularDemocracylist[index]
                                                        .nkilometre! +
                                                    "KM",
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color:
                                                        Style.colors.app_black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                        .category! +
                                                    " : ",
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    color:
                                                        Style.colors.app_black,
                                                    fontFamily:
                                                        Style.montserrat,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Text(
                                                particularDemocracylist[index]
                                                        .cCategory!
                                                        .isNotEmpty
                                                    ? particularDemocracylist[
                                                            index]
                                                        .cCategory!
                                                    : " - ",
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    color:
                                                        Style.colors.app_black,
                                                    fontFamily:
                                                        Style.montserrat,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: checkLeave
                                                    ? Colors.red
                                                    : Style.colors.green,
                                                size: 18.0,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 2.0),
                                                child: Text(
                                                  particularDemocracylist[index]
                                                          .jCurrentDay!
                                                          .days! +
                                                      openTime,
                                                  style: TextStyle(
                                                      fontSize: 13.0,
                                                      color: checkLeave
                                                          ? Colors.red
                                                          : Style.colors.green,
                                                      fontFamily:
                                                          Style.montserrat,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              Container(
                                                width: 100,
                                                padding: const EdgeInsets.only(
                                                    left: 2.0),
                                                child: Text(
                                                  closeTime,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 13.0,
                                                      color: checkLeave
                                                          ? Colors.red
                                                          : Style.colors.green,
                                                      fontFamily:
                                                          Style.montserrat,
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
                ),
        ],
      ),
    );
  }
}
