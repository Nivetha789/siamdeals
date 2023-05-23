import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:siamdealz/screens/DashboardScreen.dart';
import 'package:siamdealz/screens/LoginScreen.dart';
import 'package:siamdealz/utils/SharedPreference.dart';
import 'package:siamdealz/utils/style.dart';
import 'package:sizer/sizer.dart';

import 'helper/AppLanguage.dart';
import 'helper/AppLocalizations.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  LineSDK.instance.setup('1657848533').then((_) {
    print('LineSDK Prepared');
  });
  AppLanguage appLanguage = AppLanguage();
  // await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
  // runApp(
  //     DevicePreview(
  //       enabled: true,
  //       builder: (context) => MyApp(), // Wrap your app
  //     ));
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
//  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

/// This "Headless Task" is run when app is terminated.

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final AppLanguage appLanguage;

  MyApp({required this.appLanguage});

  Timer? timer;

  // FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return Sizer(
          builder: (BuildContext context, Orientation orientation,
                  DeviceType deviceType) =>
              MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: model.appLocal,
                  supportedLocales: [
                    Locale('en', 'US'),
                    Locale('th', ''),
                  ],
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  title: 'Phuket',
                  // locale: DevicePreview.locale(context),
                  // builder: DevicePreview.appBuilder,
                  theme: ThemeData(
                      // This is the theme of your application.
                      //
                      // Try running your application with "flutter run". You'll see the
                      // application has a blue toolbar. Then, without quitting the app, try
                      // changing the primarySwatch below to Colors.green and then invoke
                      // "hot reload" (press "r" in the console where you ran "flutter run",
                      // or simply save your changes to "hot reload" in a Flutter IDE).
                      // Notice that the counter didn't reset back to zero; the application
                      // is not restarted.
                      //fontFamily: 'sfui',
                      primarySwatch: Colors.deepOrange,
                      fontFamily: "josefinsans"),
                  home: MyHomePage(title: 'Siam DealZ')),
        );
      }),
    );
    // home: Homescreen());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  String title = "";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // autoPress();
    // firebaseAnalytics();
    checkLogin();
  }

  // firebaseAnalytics() async{
  //   await FirebaseAnalytics.instance
  //       .logBeginCheckout(
  //       value: 10.0,
  //       currency: 'USD',
  //       items: [
  //         AnalyticsEventItem(
  //             itemName: 'Socks',
  //             itemId: 'xjw73ndnw',
  //             price: 10.0
  //         ),
  //       ],
  //       coupon: '10PERCENTOFF'
  //   );
  // }

  var appLanguage1;

  @override
  Widget build(BuildContext context) {
    appLanguage1 = Provider.of<AppLanguage>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // navigation bar color
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset(
                        'images/logo.png',
                        alignment: Alignment.center,
                      ),
                      width: 150.0,
                      height: 150.0,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Text(
                          "The Best DealZ of Thailand",
                          style: TextStyle(
                              color: Style.colors.app_black,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              fontSize: 14.0),
                        )),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  checkLogin() async {
    // if (await SharedPreference().getLanguage == "Phuket") {
    //   appLanguage1.changeLanguage(Locale("th"));
    // } else {
    //
    //   appLanguage1.changeLanguage(Locale("en"));
    // }

    if (await SharedPreference().getLogin() == "1") {
      // var userId = await SharedPreference().getUserId();
      // await SharedPreferenceToken().setToken(android_fcm_token);
      // print("Main User iddd " + userId);

      Timer(
          Duration(seconds: 3),
          () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => DashBoardScreen())));

      // Timer(
      //     Duration(seconds: 3),
      //         () => Navigator.of(context).pushReplacement(MaterialPageRoute(
      //         builder: (BuildContext context) => AddProfileImageScreen())));

    } else {
      await SharedPreference().setLogin("0");
      // await SharedPreferenceToken().setToken(android_fcm_token);
      // Timer(
      //     Duration(seconds: 3),
      //     () => Navigator.of(context).pushReplacement(MaterialPageRoute(
      //         builder: (BuildContext context) =>
      //             LoginScreen(android_fcm_token))));

      Timer(
          Duration(seconds: 3),
          () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => LoginScreen())));
    }
  }
}

void toast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 12.0);
}
