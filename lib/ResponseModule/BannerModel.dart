class BannerModel {
  int? nStatus;
  List<BannerJResult>? jResult;
  String? cMessage;

  BannerModel({this.nStatus, this.jResult, this.cMessage});

  BannerModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <BannerJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new BannerJResult.fromJson(v));
      });
    }
    cMessage = json['c_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_status'] = this.nStatus;
    if (this.jResult != null) {
      data['j_result'] = this.jResult!.map((v) => v.toJson()).toList();
    }
    data['c_message'] = this.cMessage;
    return data;
  }
}

class BannerJResult {
  String? nId;
  String? cBanner;
  String? cBannerImage;
  var cBannerLink;

  BannerJResult({this.nId, this.cBanner, this.cBannerImage, this.cBannerLink});

  BannerJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cBanner = json['c_banner'];
    cBannerImage = json['c_banner_image'];
    cBannerLink = json['c_banner_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['c_banner'] = this.cBanner;
    data['c_banner_image'] = this.cBannerImage;
    data['c_banner_link'] = this.cBannerLink;
    return data;
  }
}
