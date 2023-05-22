class DemographicModel {
  int? nStatus;
  List<DemographicJResult>? jResult;
  String? cMessage;

  DemographicModel({this.nStatus, this.jResult, this.cMessage});

  DemographicModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <DemographicJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new DemographicJResult.fromJson(v));
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

class DemographicJResult {
  String? nId = "";
  String? cDemographic = "";

  DemographicJResult({this.nId, this.cDemographic});

  DemographicJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cDemographic = json['c_demographic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['c_demographic'] = this.cDemographic;
    return data;
  }
}
