import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {

  setLogin(String stringValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imagepath', stringValue);
    return true;
  }
  getLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('imagepath');
    return stringValue;
  }

  setUserId(String stringValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', stringValue);
    return true;
  }
  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('id');
    return stringValue;
  }

  setuserName(String stringValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', stringValue);
    return true;
  }
  getuserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('userName');
    return stringValue;
  }

  //mail
  setUserEmail(String stringValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', stringValue);
    return true;
  }
  getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('email');
    return stringValue;
  }


  setUserMobile(String stringValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userMobile', stringValue);
    return true;
  }
  getUserMobile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('userMobile');
    return stringValue;
  }

  setAddress(String stringValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('address', stringValue);
    return true;
  }
  getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('address');
    return stringValue;
  }


  //communication info id values
  setCountryId(String stringValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('countryId', stringValue);
    return true;
  }
  getCountryId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('countryId');
    return stringValue;
  }


  setLanguage(String stringValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', stringValue);
    return true;
  }
  getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('language');
    return stringValue;
  }

  clearSharep()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }


}
