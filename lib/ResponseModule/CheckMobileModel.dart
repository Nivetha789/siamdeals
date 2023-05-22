class CheckMobileModel {
  int? nStatus;
  String? cMessage;

  CheckMobileModel({this.nStatus, this.cMessage});

  CheckMobileModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    cMessage = json['c_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_status'] = this.nStatus;
    data['c_message'] = this.cMessage;
    return data;
  }
}