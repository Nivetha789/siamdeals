class CountryModel {
  int? nStatus;
  List<CountryJResult>? jResult;
  String? cMessage;

  CountryModel({this.nStatus, this.jResult, this.cMessage});

  CountryModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <CountryJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new CountryJResult.fromJson(v));
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

class CountryJResult {
  String? id = "";
  String? countryId = "";
  String? countryName = "";
  String? countryShortName = "";
  String? display = "";
  String? recordStatus = "";
  String? countryCode = "";
  String? status = "";

  CountryJResult(
      {this.id,
      this.countryId,
      this.countryName,
      this.countryShortName,
      this.display,
      this.recordStatus,
      this.countryCode,
      this.status});

  CountryJResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryId = json['CountryId'];
    countryName = json['CountryName'];
    countryShortName = json['CountryShortName'];
    display = json['Display'];
    recordStatus = json['RecordStatus'];
    countryCode = json['CountryCode'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['CountryId'] = this.countryId;
    data['CountryName'] = this.countryName;
    data['CountryShortName'] = this.countryShortName;
    data['Display'] = this.display;
    data['RecordStatus'] = this.recordStatus;
    data['CountryCode'] = this.countryCode;
    data['status'] = this.status;
    return data;
  }
}
