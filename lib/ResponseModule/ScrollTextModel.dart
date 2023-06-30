class ScrollTextModel {
  int? nStatus;
  List<ScrollTextJResult>? jResult;
  String? cMessage;

  ScrollTextModel({this.nStatus, this.jResult, this.cMessage});

  ScrollTextModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <ScrollTextJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new ScrollTextJResult.fromJson(v));
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

class ScrollTextJResult {
  String? cText = "";
  var cLink;
  var scrolltype;

  ScrollTextJResult({this.cText, this.cLink, this.scrolltype});

  ScrollTextJResult.fromJson(Map<String, dynamic> json) {
    cText = json['c_text'];
    cLink = json['c_link'];
    scrolltype = json["n_scroll_type"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['c_text'] = this.cText;
    data['c_link'] = this.cLink;
    data["n_scroll_type"] = this.scrolltype;
    return data;
  }
}
