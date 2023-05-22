class DownloadCouponModel {
  int? nStatus;
  String? cMessage;

  DownloadCouponModel({this.nStatus, this.cMessage});

  DownloadCouponModel.fromJson(Map<String, dynamic> json) {
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