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
        jResult!.add( PopupJResult.fromJson(v));
      });
    }
    cMessage = json['c_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['n_status'] = nStatus;
    if (jResult != null) {
      data['j_result'] = jResult!.map((v) => v.toJson()).toList();
    }
    data['c_message'] = cMessage;
    return data;
  }
}

class PopupJResult {
  String? nId;
  String? cBannerImage;
  var cBannerLink;
  var npopuptype;
  var cdescription;

  PopupJResult({this.nId, this.cBannerImage, this.cBannerLink,this.npopuptype,this.cdescription});

  PopupJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cBannerImage = json['c_banner_image'];
    cBannerLink = json['c_popup_link'];
    npopuptype=json['n_popup_type'];
    cdescription=json['c_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = nId;
    data['c_banner_image'] = cBannerImage;
    data['c_popup_link'] = cBannerLink;
    data['n_popup_type']=npopuptype;
    data['c_description']=cdescription;
    return data;
  }
}
