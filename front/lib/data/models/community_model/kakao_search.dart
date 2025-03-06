class KakaoSearch {
  String? placeName;
  String? addressName;
  String? roadAddressName;
  String? category;
  String? placeUrl;
  double? latitude; // 위도
  double? longitude; // 경도

  KakaoSearch(
      {this.placeName,
      this.addressName,
      this.roadAddressName,
      this.category,
      this.latitude,
      this.longitude});

  KakaoSearch.fromJson(Map<String, dynamic> json)
      : placeName = json['place_name'],
        addressName = json['address_name'],
        roadAddressName = json['road_address_name'],
        category = json['category_group_name'],
        placeUrl = json['place_url'],
        latitude = double.parse(json['y']),
        longitude = double.parse(json['x']);
}
