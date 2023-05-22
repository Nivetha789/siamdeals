class MenuModel {
  int? nStatus;
  List<MenuJResult>? jResult;
  String? cMessage;

  MenuModel({this.nStatus, this.jResult, this.cMessage});

  MenuModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <MenuJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new MenuJResult.fromJson(v));
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

class MenuJResult {
  String? nPageId = "";
  String? cPages = "";
  String? nPageType = "";
  String? cDescription = "";
  String? cPageLink = "";

  MenuJResult(
      {this.nPageId,
      this.cPages,
      this.nPageType,
      this.cDescription,
      this.cPageLink});

  MenuJResult.fromJson(Map<String, dynamic> json) {
    nPageId = json['n_page_id'];
    cPages = json['c_pages'];
    nPageType = json['n_page_type'];
    cDescription = json['c_description'];
    cPageLink = json['c_page_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_page_id'] = this.nPageId;
    data['c_pages'] = this.cPages;
    data['n_page_type'] = this.nPageType;
    data['c_description'] = this.cDescription;
    data['c_page_link'] = this.cPageLink;
    return data;
  }
}
