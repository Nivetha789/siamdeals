class RegisterModel {
  int? nStatus;
  String? cMessage;
  List<RegisterJResult>? jResult;

  RegisterModel({this.nStatus, this.cMessage, this.jResult});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    cMessage = json['c_message'];
    if (json['j_result'] != null) {
      jResult = <RegisterJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new RegisterJResult.fromJson(v));
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

class RegisterJResult {
  String? cDefaultLanguage = "";
  int? nId = 0;
  String? cFullName = "";
  String? cShortName = "";
  String? cEmailid = "";
  String? cAddress = "";
  String? cLine = "";

  RegisterJResult(
      {this.cDefaultLanguage,
      this.nId,
      this.cFullName,
      this.cShortName,
      this.cEmailid,
      this.cAddress,
      this.cLine});

  RegisterJResult.fromJson(Map<String, dynamic> json) {
    cDefaultLanguage = json['c_default_language'];
    nId = json['n_id'];
    cFullName = json['c_full_name'];
    cShortName = json['c_short_name'];
    cEmailid = json['c_emailid'];
    cAddress = json['c_address'];
    cLine = json['c_line'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['c_default_language'] = this.cDefaultLanguage;
    data['n_id'] = this.nId;
    data['c_full_name'] = this.cFullName;
    data['c_short_name'] = this.cShortName;
    data['c_emailid'] = this.cEmailid;
    data['c_address'] = this.cAddress;
    data['c_line'] = this.cLine;
    return data;
  }
}
