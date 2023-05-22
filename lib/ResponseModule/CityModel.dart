class CityModel {
  int? nStatus;
  List<CityJResult>? jResult;
  String? cMessage;

  CityModel({this.nStatus, this.jResult, this.cMessage});

  CityModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <CityJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new CityJResult.fromJson(v));
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

class CityJResult {
  String? nId = "";
  String? cCity = "";

  CityJResult({this.nId, this.cCity});

  CityJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cCity = json['c_city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['c_city'] = this.cCity;
    return data;
  }
}