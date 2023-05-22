class StoreDetailsModel {
  int? nStatus;
  JResult? jResult;
  String? cMessage;

  StoreDetailsModel({this.nStatus, this.jResult, this.cMessage});

  StoreDetailsModel.fromJson(Map json) {
    nStatus = json['n_status'];
    jResult = json['j_result'] != null
        ? new JResult.fromJson(json['j_result'])
        : null;
    cMessage = json['c_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_status'] = this.nStatus;
    if (this.jResult != null) {
      data['j_result'] = this.jResult!.toJson();
    }
    data['c_message'] = this.cMessage;
    return data;
  }
}

class JResult {
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
  List<JImages>? jImages;

  List<JAlbums>? jAlbums;
  List<JCoupons>? jCoupons;
  JCurrentDay? jCurrentDay;
  List<JOpeningHours>? jOpeningHours;

  JResult(
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
      this.jImages,
      this.jAlbums});

  JResult.fromJson(Map<String, dynamic> json) {
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
    if (json['j_images'] != null) {
      jImages = <JImages>[];
      json['j_images'].forEach((v) {
        jImages!.add(JImages.fromJson(v));
      });
    }
    if (json['j_albums'] != null) {
      jAlbums = <JAlbums>[];
      json['j_albums'].forEach((v) {
        jAlbums!.add(JAlbums.fromJson(v));
      });
    }
    if (json['j_coupons'] != null) {
      jCoupons = <JCoupons>[];
      json['j_coupons'].forEach((v) {
        jCoupons!.add(new JCoupons.fromJson(v));
      });
    }
    jCurrentDay = json['j_current_day'] != null
        ? new JCurrentDay.fromJson(json['j_current_day'])
        : null;
    if (json['j_opening_hours'] != null) {
      jOpeningHours = <JOpeningHours>[];
      json['j_opening_hours'].forEach((v) {
        jOpeningHours!.add(new JOpeningHours.fromJson(v));
      });
    }
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
    if (this.jImages != null) {
      data['j_images'] = this.jImages!.map((v) => v.toJson()).toList();
    }
    if (this.jCoupons != null) {
      data['j_coupons'] = this.jCoupons!.map((v) => v.toJson()).toList();
    }
    if (this.jCurrentDay != null) {
      data['j_current_day'] = this.jCurrentDay!.toJson();
    }
    if (this.jOpeningHours != null) {
      data['j_opening_hours'] =
          this.jOpeningHours!.map((v) => v.toJson()).toList();
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

class JAlbums {
  String? cListingImg;

  JAlbums({this.cListingImg});

  JAlbums.fromJson(Map<String, dynamic> json) {
    cListingImg = json['c_listing_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['c_listing_img'] = this.cListingImg;
    return data;
  }
}

class JCoupons {
  String? nCouponId;
  String? nType;
  String? cTerms;
  String? nSpendAmount;
  String? c_coupon_code;
  String? cCoupon;
  String? nDiscountPercentage;
  String? nCouponPrice;
  String? cDescription;
  String? cImage;
  String? nCalltoconfirm;
  String? till_date;

  JCoupons(
      {this.nCouponId,
      this.nType,
      this.cTerms,
      this.nSpendAmount,
      this.c_coupon_code,
      this.cCoupon,
      this.nDiscountPercentage,
      this.nCouponPrice,
      this.cDescription,
      this.cImage,
      this.nCalltoconfirm,
      this.till_date});

  JCoupons.fromJson(Map<String, dynamic> json) {
    nCouponId = json['n_coupon_id'];
    nType = json['n_type'];
    cTerms = json['c_terms'];
    nSpendAmount = json['n_spend_amount'];
    c_coupon_code = json['c_coupon_code'];
    cCoupon = json['c_coupon'];
    nDiscountPercentage = json['n_discount_percentage'];
    nCouponPrice = json['n_coupon_price'];
    cDescription = json['c_description'];
    cImage = json['c_image'];
    nCalltoconfirm = json['n_calltoconfirm'];
    till_date = json['till_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_coupon_id'] = this.nCouponId;
    data['n_type'] = this.nType;
    data['c_terms'] = this.cTerms;
    data['n_spend_amount'] = this.nSpendAmount;
    data['c_coupon_code'] = this.c_coupon_code;
    data['c_coupon'] = this.cCoupon;
    data['n_discount_percentage'] = this.nDiscountPercentage;
    data['n_coupon_price'] = this.nCouponPrice;
    data['c_description'] = this.cDescription;
    data['c_image'] = this.cImage;
    data['n_calltoconfirm'] = this.nCalltoconfirm;
    data['till_date'] = this.till_date;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['days'] = this.days;
    data['open'] = this.open;
    data['close'] = this.close;
    return data;
  }
}

class JOpeningHours {
  String? days;
  String? open;
  String? close;

  JOpeningHours({this.days, this.open, this.close});

  JOpeningHours.fromJson(Map<String, dynamic> json) {
    days = json['days'];
    open = json['open'];
    close = json['close'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['days'] = this.days;
    data['open'] = this.open;
    data['close'] = this.close;
    return data;
  }
}
