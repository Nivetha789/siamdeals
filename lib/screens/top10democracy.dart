import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loadmore/loadmore.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
// import 'package:getwidget/getwidget.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:siamdealz/ResponseModule/DemographicModel/DemographicModel.dart';
import 'package:siamdealz/core/ApiProvider/api_provider.dart';
import 'package:siamdealz/utils/style.dart';
import 'package:sizer/sizer.dart';

import '../ResponseModule/SearchVendorModule/SearchVendorModel.dart';
import '../Utils/ProgressDialog.dart';
import '../helper/AppLocalizations.dart';
import '../utils/handler/toast_handler.dart';
import 'StoreDetailsScreen.dart';

class Top10Democracy extends StatefulWidget {
  final id;
  final cityid;
  final name;

  Top10Democracy({Key? key, this.id, this.cityid, this.name}) : super(key: key);

  @override
  State<Top10Democracy> createState() => _Top10DemocracyState();
}

class _Top10DemocracyState extends State<Top10Democracy>
    with TickerProviderStateMixin {
  bool checkInbox = false;
  bool haspermission = false;
  String long = "", lat = "";
  List<SearchVendorJResult> particularDemocracylist = [];
  bool isDemographList = true;
  bool isDemographListNoData = false;
  late LocationPermission permission;
  late StreamSubscription<Position> positionStream;
  bool servicestatus = false;

  int offset = 0;
  int limit = 10;
  int n_page = 1;
  int total = 0;
  bool loadmore = false;

  String _currentAddress = "";
  late Position _currentPosition;
  List<String> items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

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

  List<Category> categories = [];

  List distancelist = [];
  List<Map<String, dynamic>> distancecategoryList = [];
  List<MultiSelectItem<Object?>> distanceconvertedList = [];

  List<Map<String, dynamic>> districtlist = [];

  List<Category> categoryList1 = [];
  List<String> selectedValues = [];

  List multipleSelected = [];

  String selectedDistanceId = "";

  String selecteddistrict = "";
  List<dynamic> selectedCategories = [];

  // List? selectedsubcategory = [];
  String noDataText = 'Data Not Found';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      this.getLocation();
      this.getDistancefilterList();
      this.getTownfilterList();
      this.getcategorylist();
    });

    // getDistanceList();
    // getSharedPrefs();
  }

  getLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    debugPrint(_currentPosition.longitude.toString()); //Output: 80.24599079
    debugPrint(_currentPosition.latitude.toString()); //Output: 29.6593457
    setState(() {
      long = _currentPosition.longitude.toString();
      lat = _currentPosition.latitude.toString();
      //refresh UI on update
    });
    distancelist.clear();
    selectedsubcategory.clear();
    selectedtowncategory.clear();
    offset = 0;
    limit = 10;
    particulardemocracywithsort("1", "");
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
      debugPrint(e.toString());
    });
  }

  updateisDemographList(List<SearchVendorJResult> particularDemocracylist1) {
    setState(() {
      particularDemocracylist.clear();
      particularDemocracylist.addAll(particularDemocracylist1);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                          getLocation();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              InkWell(
                  onTap: () {
                    getLocation();
                  },
                  child: Container(
                      height: 35,
                      alignment: Alignment.center,
                      width: 30,
                      decoration: BoxDecoration(
                        // color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1.0,
                          // assign the color to the border color
                          color: Colors.grey,
                        ),
                      ),
                      child: const Text("All"))),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  _showCategoryDialog(context);
                },
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1.0,
                        // assign the color to the border color
                        color: Colors.grey,
                      ),
                    ),
                    width: 90,
                    padding: const EdgeInsets.all(5),
                    height: 35,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Category",
                          style: TextStyle(fontSize: 12),
                        ),
                        Icon(Icons.filter_list_sharp, size: 15)
                      ],
                    )),

                // child: MultiSelectDialogField(
                //   // backgroundColor: Colors.transparent,
                //   items: convertedList,
                //   separateSelectedItems: false,
                //   chipDisplay: MultiSelectChipDisplay<String>(
                //     chipWidth: 70,
                //     height: 0,
                //     scroll: true,
                //     chipColor: Colors.blue,
                //     textStyle: const TextStyle(color: Colors.white),
                //   ),
                //   // chipDisplay: ,
                //   buttonText:
                //       // selectedsubcategory.isEmpty ||
                //       //         selectedsubcategory == null ||
                //       //         selectedsubcategory.length == 0
                //       //     ? Text("selectText")
                //       // :
                //       const Text(
                //     "Category",
                //     style: TextStyle(fontSize: 12),
                //     overflow: TextOverflow.ellipsis,
                //   ),

                //   selectedColor: Colors.blue,
                //   decoration: BoxDecoration(
                //     // color: Colors.blue.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(10),
                //     border: Border.all(
                //       width: 1.0,
                //       // assign the color to the border color
                //       color: Colors.grey,
                //     ),
                //   ),
                //   buttonIcon: const Icon(
                //     Icons.filter_list_sharp,
                //     size: 15,
                //     // color: Colors.blue,
                //   ),

                //   onConfirm: (results) {
                //     setState(() {
                //       selectedsubcategory = results;
                //     });
                //     particulardemocracywithsort(2);
                //     //_selectedAnimals = results;
                //   },
                //   onSaved: (results) {
                //     debugPrint("Sdsfsdfsdfsdf $results");
                //     setState(() {
                //       selectedsubcategory = results!;
                //     });
                //     debugPrint("selectedsubcategory $selectedsubcategory");
                //     //_selectedAnimals = results;
                //   },
                // ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 90,
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
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  // chipDisplay: ,
                  buttonText:
                      // selectedsubcategory.isEmpty ||
                      //         selectedsubcategory == null ||
                      //         selectedsubcategory.length == 0
                      //     ? Text("selectText")
                      // :
                      const Text(
                    "Town",
                    style: TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),

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
                    size: 15,
                    // color: Colors.blue,
                  ),

                  onConfirm: (results) {
                    debugPrint("Sdsfsdfsdfsdf $results");
                    setState(() {
                      selectedtowncategory = results;
                    });
                    debugPrint(selectedtowncategory.join(', '));

                    debugPrint("selectedSubcategories $selectedtowncategory");
                    particulardemocracywithsort(1, "");
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
              /* Container(
              width: 90,
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
              height: 35,

              //padding: const EdgeInsets.only(bottom: 10.0, top: 0),
              child: DropdownButtonFormField(
                isDense: true,
                isExpanded: true,
                alignment: Alignment.center,
                // value: selectedOption,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 13.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                //elevation: 5,
                style: const TextStyle(color: Colors.black),
                icon: const Icon(
                  Icons.filter_list,
                  size: 15,
                ),
                items: distancelist.map((Map<String, dynamic> option) {
                  return DropdownMenuItem(
                    alignment: Alignment.center,
                    value: option['distance_id'].toString(),
                    child: Container(
                        alignment: Alignment.center,
                        width: 100,
                        child: Text(
                          option['distance_val'],
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        )),
                  );
                }).toList(),
                hint: const Text(
                  "Distance",
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
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
            ),*/
              SizedBox(
                width: 90,
                height: 47,
                child: MultiSelectDialogField(
                  // backgroundColor: Colors.transparent,
                  items: distanceconvertedList,
                  separateSelectedItems: false,

                  chipDisplay: MultiSelectChipDisplay<String>(
                    chipWidth: 70,
                    height: 0,
                    scroll: true,
                    chipColor: Colors.blue,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  // chipDisplay: ,
                  buttonText:
                      // selectedsubcategory.isEmpty ||
                      //         selectedsubcategory == null ||
                      //         selectedsubcategory.length == 0
                      //     ? Text("selectText")
                      // :
                      const Text(
                    "Distance",
                    style: TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),

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
                    size: 15,
                    // color: Colors.blue,
                  ),

                  onConfirm: (results) {
                    debugPrint("selectedDistanceId $results");
                    setState(() {
                      distancelist = results;
                    });
                    offset = 0;
                    particulardemocracywithsort(2, "");
                    //_selectedAnimals = results;
                  },
                  onSaved: (results) {
                    debugPrint("Sdsfsdfsdfsdf $results");
                    setState(() {
                      distancelist = results!;
                    });
                    //_selectedAnimals = results;
                  },
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
          isDemographListNoData
              ? Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 250),
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
                  child: LoadMore(
                    isFinish: particularDemocracylist.length >= total,
                    onLoadMore: _loadMore,
                    whenEmptyLoad: false,
                    delegate: const DefaultLoadMoreDelegate(),
                    textBuilder: DefaultLoadMoreTextBuilder.english,
                    child: ListView(
                      children: [
                        Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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
                                            particularDemocracylist[index].nId!,
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
                                                        Radius.circular(10.sp),
                                                    topRight:
                                                        Radius.circular(10.sp)),
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
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 15.0),
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
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 15.0),
                                                        child: Text(
                                                          particularDemocracylist[
                                                                  index]
                                                              .nKilometre!,
                                                          maxLines: 1,
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
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5.0),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "${AppLocalizations.of(context)!.category!} : ",
                                                        style: TextStyle(
                                                            fontSize: 13.0,
                                                            color: Style.colors
                                                                .app_black,
                                                            fontFamily: Style
                                                                .montserrat,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      Flexible(
                                                        child: Text(
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
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time,
                                                        color: checkLeave
                                                            ? Colors.red
                                                            : Style
                                                                .colors.green,
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
                                                              fontSize: 13.0,
                                                              color: checkLeave
                                                                  ? Colors.red
                                                                  : Style.colors
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
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 13.0,
                                                              color: checkLeave
                                                                  ? Colors.red
                                                                  : Style.colors
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
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<bool> _loadMore() async {
    print("onLoadMore");
    await Future.delayed(const Duration(seconds: 0, milliseconds: 100));
    // setState(() {
    //   progressbar = false;
    //   loadmore = false;
    // });
    particulardemocracywithsort("1", "loadmore");
    return false;
  }

  particulardemocracywithsort(nview, String loadmore) async {
    ProgressDialog().showLoaderDialog(context);
    Dio dio = new Dio();
    var bodyFields = {
      "n_limit": limit,
      'n_offset': offset,
      'c_demographic': widget.id,
      'n_latitude': lat,
      'n_longitude': long,
      'n_view': nview.toString(),
      'n_distance': distancelist.join(', ').toString(),
      'n_category': selectedsubcategory.join(', ').toString(),
      'n_district': selectedtowncategory.join(', ').toString(),
      'n_town': "",
    };
    print("bodyfields " + bodyFields.toString());
    dio.options.contentType = Headers.formUrlEncodedContentType;
    final response = await dio.post(
        "${ApiProvider.BASE_URL}demographic/getDemographicListing",
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: bodyFields);
    print("resDemoGraph " + response.toString());
    if (response.statusCode == 200) {
      //   Map<String, dynamic> map =
      //   jsonDecode(await response.stream.bytesToString());
      //   print("responsssss "+response.stream.bytesToString().toString());
      //
      //   ProgressDialog().dismissDialog(context);
      //   if (map["j_result"].length > 0) {
      //     for (var i = 0; i <= map["j_result"].length; i++) {
      //       particularDemocracylist
      //           .add(SearchVendorJResult.fromJson(map["j_result"][i]));
      //     }
      //     // ProgressDialog().dismissDialog(context);
      //
      //     // debugPrint("pavithra ${await response.stream.bytesToString()}");
      //   }else{
      //     particularDemocracylist=[];
      //   }
      // }else {
      //   ProgressDialog().dismissDialog(context);
      //
      //   debugPrint(" ${response.reasonPhrase}");
      // }
      Map<String, dynamic> map = jsonDecode(response.toString());
      SearchVendorModel searchVendorJResult = SearchVendorModel.fromJson(map);

      if (searchVendorJResult.nStatus == 1) {
        ProgressDialog().dismissDialog(context);
        setState(() {
          isDemographList = true;
          isDemographListNoData = false;
          offset = searchVendorJResult.offset!;
          limit = limit;
          total = searchVendorJResult.nTotalRecords!;
        });
        // setState(() {
        //   noDataLoader=false;
        // });
        updateisDemographList(searchVendorJResult.jResult!);
      } else {
        ProgressDialog().dismissDialog(context);
        // setState(() {
        //   noDataLoader=false;
        // });
        setState(() {
          isDemographList = false;
          isDemographListNoData = true;
        });

        // Fluttertoast.showToast(
        //     msg: getSendExpressInterestModel.message,
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.CENTER,
        //     textColor: Colors.white,
        //     backgroundColor: MyColor().pink,
        //     timeInSecForIosWeb: 1);
      }
    }

// getDistanceList() async {
//   try {
//     ProgressDialog().showLoaderDialog(context);
//
//     Dio dio = Dio();
//
//     final response = await dio.get(
//       ApiProvider.getDistanceList,
//       options: Options(contentType: Headers.formUrlEncodedContentType),
//     );
//
//     debugPrint("PAVITHRAM2132434234 ${response.toString()}");
//     if (response.statusCode == 200) {
//       ProgressDialog().dismissDialog(context);
//       Map<String, dynamic> map = jsonDecode(response.toString());
//       distancelist = List<Map<String, dynamic>>.from(map["data"]);
//     } else {
//       ProgressDialog().dismissDialog(context);
//       ToastHandler.showToast(message: "Bad Network Connection try again..");
//     }
//   } catch (e) {
//     ProgressDialog().dismissDialog(context);
//     debugPrint("Response22: $e");
//   }
// }
  }

  getDistancefilterList() async {
    try {
      ProgressDialog().showLoaderDialog(context);

      Dio dio = new Dio();
      // dio.options.connectTimeout = 5000; //5s
      // dio.options.receiveTimeout = 3000;

      var parameters = {"n_city": widget.cityid};
      dio.options.contentType = Headers.formUrlEncodedContentType;
      final response = await dio.post(ApiProvider.getfilterList,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      // if (response.statusCode == 200) {
      //   Map<String, dynamic> map = jsonDecode(response.toString());
      //   DemographicModel demographicModel =
      //   DemographicModel.fromJson(map);
      //
      //   if (demographicModel.nStatus == 1) {
      //       ProgressDialog().dismissDialog(context);
      //     distancelist =
      //     List<Map<String, dynamic>>.from(map["data"]["distance_list"]);
      //     setState(() {
      //       distancelist = distancelist;
      //     });
      //     for (var i = 0; i < map["data"]["distance_list"].length; i++) {
      //       selectedOption =
      //           map["data"]["distance_list"][i]["distance_id"].toString();
      //     }
      //   } else {
      //       ProgressDialog().dismissDialog(context);
      //
      //     Fluttertoast.showToast(
      //         msg: map["message"].toString(),
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.CENTER,
      //         textColor: Colors.white,
      //         backgroundColor: Colors.purpleAccent,
      //         timeInSecForIosWeb: 1);
      //   }
      // }
      if (response.statusCode == 200) {
        ProgressDialog().dismissDialog(context);

        Map<String, dynamic> map = jsonDecode(response.toString());
        distancelist =
            List<Map<String, dynamic>>.from(map["data"]["distance_list"]);
        // selectedtowncategory = [map["data"]["town_list"][0]["district_id"]];

        Set<String> uniquetownItems = {};
        distancecategoryList = [];
        // debugPrint(
        //     "fdghjhghjdrghjdfghjfgf $selectedOption $selectedtowncategory $selectedsubcategory");
        if (distancelist.isNotEmpty) {
          for (var distrctt in distancelist) {
            var districtString = distrctt.toString(); // Convert to string
            if (!uniquetownItems.contains(districtString)) {
              distancecategoryList.add(distrctt);
              uniquetownItems.add(districtString);
            }
          }
        }
        // debugPrint(
        //     "fdghjhghjdrghjdfghjfgf $selectedOption $selectedtowncategory $selectedsubcategory");
        // setState(() {
        distanceconvertedList = distancecategoryList.map((town) {
          return MultiSelectItem<Object?>(
            town['distance_id'],
            town['distance_val'],
          );
        }).toList();
        // });
      } else {
        ProgressDialog().dismissDialog(context);

        Fluttertoast.showToast(
            msg: "Bad Network Connection try again..",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
            backgroundColor: Colors.purpleAccent,
            timeInSecForIosWeb: 1);
      }

      // print(response);
    } catch (e) {
      if (mounted) {
        ProgressDialog().dismissDialog(context);
      }
      print("Response: " + e.toString());
    }
  }

  getTownfilterList() async {
    // ProgressDialog().showLoaderDialog(context);
    Dio dio = Dio();
    var parameters = {"n_city": widget.cityid};
    final response = await dio.post(ApiProvider.getfilterList,
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: parameters);

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.toString());
      districtlist = List<Map<String, dynamic>>.from(map["data"]["town_list"]);
      // selectedtowncategory = [map["data"]["town_list"][0]["district_id"]];
      debugPrint(selectedtowncategory.toString());

      Set<String> uniquetownItems = {};
      towncategoryList = [];
      // debugPrint(
      //     "selectedOptionsss $selectedOption $selectedtowncategory $selectedsubcategory");
      if (districtlist.isNotEmpty) {
        for (var distrctt in districtlist) {
          var districtString = distrctt.toString(); // Convert to string
          if (!uniquetownItems.contains(districtString)) {
            towncategoryList.add(distrctt);
            uniquetownItems.add(districtString);
          }
        }
      }
      // debugPrint(
      //     "fdghjhghjdrghjdfghjfgf $selectedDistanceId $selectedtowncategory $selectedsubcategory");
      // setState(() {
      townconvertedList = towncategoryList.map((town) {
        return MultiSelectItem<Object?>(
          town['district_id'],
          town['c_town'],
        );
      }).toList();
      // });
      // ProgressDialog().dismissDialog(context);
    } else {
      // ProgressDialog().dismissDialog(context);
      ToastHandler.showToast(message: "Bad Network Connection try again..");
    }
  }

  getcategorylist() async {
    try {
      Dio dio = Dio();
      var parameters = {"n_city": widget.cityid};
      final response = await dio.post(ApiProvider.getfilterList,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: parameters);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.toString());
        categories = List<Category>.from(
            map["data"]["category_list"].map((x) => Category.fromJson(x)));
        print("sdfnksdfhhdfkjsfkjsdhfkhf $map");
        categoryList =
            List<Map<String, dynamic>>.from(map["data"]["category_list"]);
        // selectedsubcategory = [
        //   map["data"]["category_list"][0]['sub_category'][0]["subcategory_id"]
        // ];
        Set<String> uniqueItems = {};
        subcategoryList = [];
        for (var category in categoryList) {
          var subCategories = category['sub_category'];

          if (subCategories != null && subCategories.isNotEmpty) {
            for (var subCategory in subCategories) {
              var subCategoryString =
                  subCategory.toString(); // Convert to string
              if (!uniqueItems.contains(subCategoryString)) {
                subcategoryList.add(subCategory);
                uniqueItems.add(subCategoryString);
              }
            }
          }
        }
        // List list = ['add'];
        setState(() {
          // subcategoryList.add(list as Map<String, dynamic>);

          convertedList = subcategoryList.map((subcategory) {
            return MultiSelectItem<Object?>(
              subcategory['subcategory_id'],
              subcategory['c_category'],
            );
          }).toList();
        });
      } else {
        ToastHandler.showToast(message: "Bad Network Connection try again..");
      }
    } catch (e) {
      //  ProgressDialog().dismissDialog(context);
      debugPrint("Response23: $e");
    }
  }

  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (
        BuildContext context,
      ) {
        return AlertDialog(
          title: const Text('Selected Categories'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: 400,
                height: MediaQuery.of(context).size.height / 1.8,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categoryList.length,
                  itemBuilder: (context, index) {
                    final category = categoryList[index];
                    return ExpansionTile(
                      title: Text(category['c_category']),
                      children: List.generate(
                        category['sub_category'].length,
                        (subIndex) {
                          final subCategory =
                              category['sub_category'][subIndex];
                          return Column(
                            children: [
                              CheckboxListTile(
                                title: Text(subCategory['c_category']),
                                value: selectedsubcategory
                                    .contains(subCategory["subcategory_id"]),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      selectedsubcategory
                                          .add(subCategory["subcategory_id"]);
                                    } else {
                                      selectedsubcategory.remove(
                                          subCategory["subcategory_id"]);
                                    }
                                  });
                                },
                              ),
                              if (subCategory.containsKey('kid_category'))
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        subCategory['kid_category'].length,
                                    itemBuilder: (context, kidIndex) {
                                      final kidCategory =
                                          subCategory['kid_category'][kidIndex];
                                      return CheckboxListTile(
                                        title: Text(kidCategory['c_category']),
                                        value: selectedsubcategory.contains(
                                            kidCategory["kidcategory_id"]),
                                        onChanged: (value) {
                                          print("value $value");
                                          setState(() {
                                            if (value!) {
                                              selectedsubcategory.add(
                                                  kidCategory[
                                                      "kidcategory_id"]);
                                              print(
                                                  "valuesubcategoryyy $selectedCategories");
                                            } else {
                                              selectedsubcategory.remove(
                                                  kidCategory[
                                                      "kidcategory_id"]);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    selectedsubcategory.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    particulardemocracywithsort(1, "");
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
