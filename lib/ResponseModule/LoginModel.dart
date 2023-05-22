class LoginModel {
  int? nStatus;
  String? cMessage;
  List<LoginJResult>? jResult;

  LoginModel({this.nStatus, this.cMessage, this.jResult});

  LoginModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    cMessage = json['c_message'];
    if (json['j_result'] != null) {
      jResult = <LoginJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new LoginJResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_status'] = this.nStatus;
    data['c_message'] = this.cMessage;
    if (this.jResult != null) {
      data['j_result'] = this.jResult!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LoginJResult {
  String? nId;
  String? cFullName;
  String? cShortName;
  String? cAddress;
  String? cEmailid;
  String? cLine;
  String? cDefaultLanguage;

  LoginJResult(
      {this.nId,
        this.cFullName,
        this.cShortName,
        this.cAddress,
        this.cEmailid,
        this.cLine,
        this.cDefaultLanguage});

  LoginJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cFullName = json['c_full_name'];
    cShortName = json['c_short_name'];
    cAddress = json['c_address'];
    cEmailid = json['c_emailid'];
    cLine = json['c_line'];
    cDefaultLanguage = json['c_default_language'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['c_full_name'] = this.cFullName;
    data['c_short_name'] = this.cShortName;
    data['c_address'] = this.cAddress;
    data['c_emailid'] = this.cEmailid;
    data['c_line'] = this.cLine;
    data['c_default_language'] = this.cDefaultLanguage;
    return data;
  }
}