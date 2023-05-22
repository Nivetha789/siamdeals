class CategoryModel {
  int? nStatus;
  List<CategoryJResult>? jResult;
  List<CategoryJBanner>? jBanner;
  String? cMessage;

  CategoryModel({this.nStatus, this.jResult, this.cMessage});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    nStatus = json['n_status'];
    if (json['j_result'] != null) {
      jResult = <CategoryJResult>[];
      json['j_result'].forEach((v) {
        jResult!.add(new CategoryJResult.fromJson(v));
      });
    }
    if (json['j_banner'] != null) {
      jBanner = <CategoryJBanner>[];
      json['j_banner'].forEach((v) {
        jBanner!.add(new CategoryJBanner.fromJson(v));
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

class CategoryJResult {
  String? nId;
  String? cCategory;
  String? pCategory;
  String? cCategoryImage;
  bool? addRemove = false;

  CategoryJResult(
      {this.nId,
      this.cCategory,
      this.pCategory,
      this.cCategoryImage,
      this.addRemove});

  CategoryJResult.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cCategory = json['c_category'];
    pCategory = json['p_category'];
    cCategoryImage = json['c_category_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['c_category'] = this.cCategory;
    data['p_category'] = this.pCategory;
    data['c_category_image'] = this.cCategoryImage;
    return data;
  }
}

class CategoryJBanner {
  String? nId = "";
  String? cTitle = "";
  String? cBannerLink = "";
  String? cBannerImage = "";

  CategoryJBanner({this.nId, this.cTitle, this.cBannerLink, this.cBannerImage});

  CategoryJBanner.fromJson(Map<String, dynamic> json) {
    nId = json['n_id'];
    cTitle = json['c_title'];
    cBannerLink = json['c_banner_link'];
    cBannerImage = json['c_banner_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n_id'] = this.nId;
    data['c_title'] = this.cTitle;
    data['c_banner_link'] = this.cBannerLink;
    data['c_banner_image'] = this.cBannerImage;
    return data;
  }
}
