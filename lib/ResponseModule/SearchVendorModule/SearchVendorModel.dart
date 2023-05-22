class SearchVendorModel {
  int? nStatus;
  int? nNextPage;
  int? nPrePage;
  int? nTotalRecords;
  int? nTotalPage;
  List<SearchVendorJResult>? jResult;
  String? cMessage;

  SearchVendorModel(
      {this.nStatus,
      this.nNextPage,
      this.nPrePage,
      this.nTotalRecords,
      this.nTotalPage,
      this.jResult,
      this.cMessage});

  SearchVendorModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    nNextPage = json['n_next_page'];
    nPrePage = json['n_pre_page'];
    nTotalRecords = json['n_total_records'];
    nTotalPage = json['n_total_page'];
    if (json['j_result'] != null) {
      jResult = <SearchVendorJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new SearchVendorJResult.fromJson(v));
      });
    }
    cMessage = json['c_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_status'] = this.nStatus;
    data['n_next_page'] = this.nNextPage;
    data['n_pre_page'] = this.nPrePage;
    data['n_total_records'] = this.nTotalRecords;
    data['n_total_page'] = this.nTotalPage;
    if (this.jResult != null) {
      data['j_result'] = this.jResult!.map((v) => v.toJson()).toList();
    }
    data['c_message'] = this.cMessage;
    return data;
  }
}

class SearchVendorJResult {
  String? nId;
  String? nLatitude;
  String? nLongitude;
  String? cPlaceType;
  String? cSinceType;
  String? nCityId;
  String? cCity;
  String? nDistrictId;
  String? cDistrict;
  String? nTownId;
  String? cTown;
  String? nCategoryId;
  String? cCategory;
  String? cName;
  String? cNameInThai;
  String? cMobileNumbers;
  String? cEmailids;
  String? cAddress;
  String? cTerms;
  String? nkilometre;
  List<JImages>? jImages;
  JCurrentDay? jCurrentDay;

  SearchVendorJResult(
      {this.nId,
      this.nLatitude,
      this.nLongitude,
      this.cPlaceType,
      this.cSinceType,
      this.nCityId,
      this.cCity,
      this.nDistrictId,
      this.cDistrict,
      this.nTownId,
      this.cTown,
      this.nCategoryId,
      this.cCategory,
      this.cName,
      this.cNameInThai,
      this.cMobileNumbers,
      this.cEmailids,
      this.cAddress,
      this.cTerms,
      this.nkilometre,
      this.jImages});

  SearchVendorJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    nLatitude = json['n_latitude'];
    nLongitude = json['n_longitude'];
    cPlaceType = json['c_place_type'];
    cSinceType = json['c_since_type'];
    nCityId = json['n_city_id'];
    cCity = json['c_city'];
    nDistrictId = json['n_district_id'];
    cDistrict = json['c_district'];
    nTownId = json['n_town_id'];
    cTown = json['c_town'];
    nCategoryId = json['n_category_id'];
    cCategory = json['c_category'];
    cName = json['c_name'];
    cNameInThai = json['c_name_in_thai'];
    cMobileNumbers = json['c_mobile_numbers'];
    cEmailids = json['c_emailids'];
    cAddress = json['c_address'];
    cTerms = json['c_terms'];
    nkilometre = json['n_kilometre'];
    if (json['j_images'] != null) {
      jImages = <JImages>[];
      json['j_images'].forEach((v) {
        jImages!.add(new JImages.fromJson(v));
      });
    }
    jCurrentDay = json['j_current_day'] != null
        ? new JCurrentDay.fromJson(json['j_current_day'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['n_latitude'] = this.nLatitude;
    data['n_longitude'] = this.nLongitude;
    data['c_place_type'] = this.cPlaceType;
    data['c_since_type'] = this.cSinceType;
    data['n_city_id'] = this.nCityId;
    data['c_city'] = this.cCity;
    data['n_district_id'] = this.nDistrictId;
    data['c_district'] = this.cDistrict;
    data['n_town_id'] = this.nTownId;
    data['c_town'] = this.cTown;
    data['n_category_id'] = this.nCategoryId;
    data['c_category'] = this.cCategory;
    data['c_name'] = this.cName;
    data['c_name_in_thai'] = this.cNameInThai;
    data['c_mobile_numbers'] = this.cMobileNumbers;
    data['c_emailids'] = this.cEmailids;
    data['c_address'] = this.cAddress;
    data['c_terms'] = this.cTerms;
    data['n_kilometre'] = this.nkilometre;
    if (this.jImages != null) {
      data['j_images'] = this.jImages!.map((v) => v.toJson()).toList();
    }
    if (this.jCurrentDay != null) {
      data['j_current_day'] = this.jCurrentDay!.toJson();
    }
    return data;
  }
}

class JImages {
  String? cListingImg;

  JImages({this.cListingImg});

  JImages.fromJson(Map<String, dynamic> json) {
    cListingImg = json['c_listing_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['c_listing_img'] = this.cListingImg;
    return data;
  }
}

class JCurrentDay {
  String? days;
  String? open;
  String? close;

  JCurrentDay({this.days, this.open, this.close});

  JCurrentDay.fromJson(Map<String, dynamic> json) {
    days = json['days'];
    open = json['open'];
    close = json['close'];
  }

  Map<String, dynamic> toJson() => {
        "days": days,
        "open": open,
        "close": close,
      };
}
