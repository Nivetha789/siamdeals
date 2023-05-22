class ParticularDemocracy {
  ParticularDemocracy({
    required this.nId,
    required this.nLatitude,
    required this.nLongitude,
    required this.nKilometre,
    required this.cPlaceType,
    required this.cSinceType,
    required this.nCityId,
    required this.cCity,
    required this.nDistrictId,
    required this.cDistrict,
    required this.nTownId,
    required this.cTown,
    required this.nCategoryId,
    required this.cCategory,
    required this.cName,
    required this.cNameInThai,
    required this.cMobileNumbers,
    required this.cEmailids,
    required this.cAddress,
    required this.cTerms,
    required this.nDormant,
    required this.jCurrentDay,
    required this.jOpeningHours,
    required this.jImages,
    required this.jAlbums,
  });

  String nId;
  String nLatitude;
  String nLongitude;
  String nKilometre;
  String cPlaceType;
  String cSinceType;
  String nCityId;
  String cCity;
  String nDistrictId;
  String cDistrict;
  String nTownId;
  String cTown;
  String nCategoryId;
  String cCategory;
  String cName;
  String cNameInThai;
  String cMobileNumbers;
  String cEmailids;
  String cAddress;
  String cTerms;
  String nDormant;
  JCurrentDay jCurrentDay;
  List<JCurrentDay> jOpeningHours;
  List<JImage> jImages;
  List<dynamic> jAlbums;

  factory ParticularDemocracy.fromJson(Map<String, dynamic> json) =>
      ParticularDemocracy(
        nId: json["n_id"],
        nLatitude: json["n_latitude"],
        nLongitude: json["n_longitude"],
        nKilometre: json["n_kilometre"],
        cPlaceType: json["c_place_type"],
        cSinceType: json["c_since_type"],
        nCityId: json["n_city_id"],
        cCity: json["c_city"],
        nDistrictId: json["n_district_id"],
        cDistrict: json["c_district"],
        nTownId: json["n_town_id"],
        cTown: json["c_town"],
        nCategoryId: json["n_category_id"],
        cCategory: json["c_category"],
        cName: json["c_name"],
        cNameInThai: json["c_name_in_thai"],
        cMobileNumbers: json["c_mobile_numbers"],
        cEmailids: json["c_emailids"],
        cAddress: json["c_address"],
        cTerms: json["c_terms"],
        nDormant: json["n_dormant"],
        jCurrentDay: JCurrentDay.fromJson(json["j_current_day"]),
        jOpeningHours: List<JCurrentDay>.from(
            json["j_opening_hours"].map((x) => JCurrentDay.fromJson(x))),
        jImages:
            List<JImage>.from(json["j_images"].map((x) => JImage.fromJson(x))),
        jAlbums: List<dynamic>.from(json["j_albums"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "n_id": nId,
        "n_latitude": nLatitude,
        "n_longitude": nLongitude,
        "n_kilometre": nKilometre,
        "c_place_type": cPlaceType,
        "c_since_type": cSinceType,
        "n_city_id": nCityId,
        "c_city": cCity,
        "n_district_id": nDistrictId,
        "c_district": cDistrict,
        "n_town_id": nTownId,
        "c_town": cTown,
        "n_category_id": nCategoryId,
        "c_category": cCategory,
        "c_name": cName,
        "c_name_in_thai": cNameInThai,
        "c_mobile_numbers": cMobileNumbers,
        "c_emailids": cEmailids,
        "c_address": cAddress,
        "c_terms": cTerms,
        "n_dormant": nDormant,
        "j_current_day": jCurrentDay.toJson(),
        "j_opening_hours":
            List<dynamic>.from(jOpeningHours.map((x) => x.toJson())),
        "j_images": List<dynamic>.from(jImages.map((x) => x.toJson())),
        "j_albums": List<dynamic>.from(jAlbums.map((x) => x)),
      };
}

class JCurrentDay {
  JCurrentDay({
    required this.days,
    required this.open,
    required this.close,
  });

  String? days;
  String? open;
  String? close;

  factory JCurrentDay.fromJson(Map<String, dynamic> json) => JCurrentDay(
        days: json["days"],
        open: json["open"],
        close: json["close"],
      );

  Map<String, dynamic> toJson() => {
        "days": days,
        "open": open,
        "close": close,
      };
}

class JImage {
  JImage({
    required this.cListingImg,
  });

  String cListingImg;

  factory JImage.fromJson(Map<String, dynamic> json) => JImage(
        cListingImg: json["c_listing_img"],
      );

  Map<String, dynamic> toJson() => {
        "c_listing_img": cListingImg,
      };
}
