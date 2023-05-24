import 'package:connectivity/connectivity.dart';

Future<bool> check() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

/* 
Future<bool> check() async {
  var connected = false;
  debugPrint("Checking internet...");
  try {
    final result = await InternetAddress.lookup('kalyanamalai.com');
    final result2 = await InternetAddress.lookup('kalyanamalai.com');
    final result3 = await InternetAddress.lookup('kalyanamalai.com');
    if ((result.isNotEmpty && result[0].rawAddress.isNotEmpty) ||
        (result2.isNotEmpty && result2[0].rawAddress.isNotEmpty) ||
        (result3.isNotEmpty && result3[0].rawAddress.isNotEmpty)) {
      debugPrint('connected..');
      connected = true;
    } else {
      debugPrint("not connected from else..");
      connected = false;
    }
  } on SocketException catch (_) {
    debugPrint('not connected...');
    connected = false;
  }
  return connected;
}*/
