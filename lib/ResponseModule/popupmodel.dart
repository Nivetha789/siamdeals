class PopupModel {
  int? nStatus;
  List<PopupJResult>? jResult;
  String? cMessage;

  PopupModel({this.nStatus, this.jResult, this.cMessage});

  PopupModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <PopupJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new PopupJResult.fromJson(v));
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

class PopupJResult {
  String? nId;
  String? cBannerImage;
  var cBannerLink;

  PopupJResult({this.nId, this.cBannerImage, this.cBannerLink});

  PopupJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cBannerImage = json['c_banner_image'];
    cBannerLink = json['c_popup_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['c_banner_image'] = this.cBannerImage;
    data['c_popup_link'] = this.cBannerLink;
    return data;
  }
}
