class DownloadedCouponListModel {
  int? nStatus;
  int? nTotalRecords;
  int? nTotalPage;
  List<DownloadedCouponListJResult>? jResult;
  String? cMessage;

  DownloadedCouponListModel(
      {this.nStatus,
        this.nTotalRecords,
        this.nTotalPage,
        this.jResult,
        this.cMessage});

  DownloadedCouponListModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    nTotalRecords = json['n_total_records'];
    nTotalPage = json['n_total_page'];
    if (json['j_result'] != null) {
      jResult = <DownloadedCouponListJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new DownloadedCouponListJResult.fromJson(v));
      });
    }
    cMessage = json['c_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_status'] = this.nStatus;
    data['n_total_records'] = this.nTotalRecords;
    data['n_total_page'] = this.nTotalPage;
    if (this.jResult != null) {
      data['j_result'] = this.jResult!.map((v) => v.toJson()).toList();
    }
    data['c_message'] = this.cMessage;
    return data;
  }
}

class DownloadedCouponListJResult {
  String? nId = "";
  String? nCalltoconfirm = "";
  String? cSpend = "";
  String? cCouponCode = "";
  String? cCoupon = "";
  String? cDescription = "";
  String? cTerms = "";
  String? cCouponImage = "";
  String? cName = "";
  String? cNameInThai = "";
  String? cMobileNumbers = "";
  String? cEmailids = "";
  String? flLatitude = "";
  String? flLongitude = "";
  String? cAddress = "";
  String? dtDownloadedOn = "";
  List<DownloadedCouponListJImages>? jImages;
  String? tillDate = "";

  DownloadedCouponListJResult(
      {this.nId,
        this.nCalltoconfirm,
        this.cSpend,
        this.cCouponCode,
        this.cCoupon,
        this.cDescription,
        this.cTerms,
        this.cCouponImage,
        this.cName,
        this.cNameInThai,
        this.cMobileNumbers,
        this.cEmailids,
        this.flLatitude,
        this.flLongitude,
        this.cAddress,
        this.dtDownloadedOn,
        this.jImages,
        this.tillDate});

  DownloadedCouponListJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    nCalltoconfirm = json['n_calltoconfirm'];
    cSpend = json['c_spend'];
    cCouponCode = json['c_coupon_code'];
    cCoupon = json['c_coupon'];
    cDescription = json['c_description'];
    cTerms = json['c_terms'];
    cCouponImage = json['c_coupon_image'];
    cName = json['c_name'];
    cNameInThai = json['c_name_in_thai'];
    cMobileNumbers = json['c_mobile_numbers'];
    cEmailids = json['c_emailids'];
    flLatitude = json['fl_latitude'];
    flLongitude = json['fl_longitude'];
    cAddress = json['c_address'];
    dtDownloadedOn = json['dt_downloaded_on'];
    if (json['j_images'] != null) {
      jImages = <DownloadedCouponListJImages>[];
      json['j_images'].forEach((v) {
        jImages!.add(new DownloadedCouponListJImages.fromJson(v));
      });
    }
    tillDate = json['till_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['n_calltoconfirm'] = this.nCalltoconfirm;
    data['c_spend'] = this.cSpend;
    data['c_coupon_code'] = this.cCouponCode;
    data['c_coupon'] = this.cCoupon;
    data['c_description'] = this.cDescription;
    data['c_terms'] = this.cTerms;
    data['c_coupon_image'] = this.cCouponImage;
    data['c_name'] = this.cName;
    data['c_name_in_thai'] = this.cNameInThai;
    data['c_mobile_numbers'] = this.cMobileNumbers;
    data['c_emailids'] = this.cEmailids;
    data['fl_latitude'] = this.flLatitude;
    data['fl_longitude'] = this.flLongitude;
    data['c_address'] = this.cAddress;
    data['dt_downloaded_on'] = this.dtDownloadedOn;
    if (this.jImages != null) {
      data['j_images'] = this.jImages!.map((v) => v.toJson()).toList();
    }
    data['till_date'] = this.tillDate;
    return data;
  }
}

class DownloadedCouponListJImages {
  String? cListingImg = "";

  DownloadedCouponListJImages({this.cListingImg});

  DownloadedCouponListJImages.fromJson(Map<String, dynamic> json) {
    cListingImg = json['c_listing_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['c_listing_img'] = this.cListingImg;
    return data;
  }
}