// ignore_for_file: constant_identifier_names

class ApiProvider {
  static const String BASE_URL = "http://beta.siamdealz.com/api/";

  static const String sendotp = "${BASE_URL}customers/sendOTP";

  static const String verifyotp = "${BASE_URL}customers/verifyOTP";
  static const String checkMobile = "${BASE_URL}customers/checkMobile";
  static const String getCity = "${BASE_URL}city/getCity";
  static const String getBanner = '${BASE_URL}banner/getBanner';

  static const String getPopup = '${BASE_URL}banner/getPopup';
  static const String getCategory = '${BASE_URL}category/getCategory';
  static const String getDemographic = '${BASE_URL}demographic/getDemographic';

  static const String getDistanceList =
      '${BASE_URL}Demographic/getDistanceList';

  static const String getfilterList = '${BASE_URL}demographic/getFilterList';

  static const String gettownList = '${BASE_URL}demographic/getTownList';

  static const String getSearchVendor = '${BASE_URL}vendor/getVendors';

  static const String getSearchlist = '${BASE_URL}search/getSearchResult';
  static const String getVendorDetails = '${BASE_URL}vendor/getVendor/';
  static const String getMenuPages = '${BASE_URL}pages/getPages';
  static const String register = '${BASE_URL}customers/register';
  static const String login = '${BASE_URL}customers/login';
  static const String getDownloadCoupons =
      '${BASE_URL}customers/downloadedCoupons';
  static const String getHtmlContentApi = '${BASE_URL}pages/getPage/';
  static const String getScrollText = '${BASE_URL}pages/getScroll';
  static const String getProfile = '${BASE_URL}customers/profile';
  static const String downloadCoupon = '${BASE_URL}customers/downloadCoupon';
  static const String getCountryList = '${BASE_URL}city/getCountry';
}
