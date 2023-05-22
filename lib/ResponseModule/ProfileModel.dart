class ProfileModel {
  int? nStatus;
  List<ProfileJResult>? jResult;
  String? cMessage;

  ProfileModel({this.nStatus, this.jResult, this.cMessage});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <ProfileJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new ProfileJResult.fromJson(v));
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

class ProfileJResult {
  String? nId = "";
  String? cLine = "";
  String? cFullName = "";
  String? cShortName = "";
  String? cEmailid = "";
  String? cAddress = "";
  String? cUserSince = "";
  String? cProfile = "";

  ProfileJResult(
      {this.nId,
      this.cLine,
      this.cFullName,
      this.cShortName,
      this.cEmailid,
      this.cAddress,
      this.cUserSince,
      this.cProfile});

  ProfileJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cLine = json['c_line'];
    cFullName = json['c_full_name'];
    cShortName = json['c_short_name'];
    cEmailid = json['c_emailid'];
    cAddress = json['c_address'];
    cUserSince = json['c_user_since'];
    cProfile = json['c_profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['c_line'] = this.cLine;
    data['c_full_name'] = this.cFullName;
    data['c_short_name'] = this.cShortName;
    data['c_emailid'] = this.cEmailid;
    data['c_address'] = this.cAddress;
    data['c_user_since'] = this.cUserSince;
    data['c_profile'] = this.cProfile;
    return data;
  }
}
