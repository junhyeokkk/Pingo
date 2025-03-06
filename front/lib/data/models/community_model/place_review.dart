class PlaceReview {
  String? prNo;
  String? placeName;
  String? thumb;
  String? addressName;
  String? roadAddressName;
  String? userNo;
  String? contents;
  String? category;
  double? latitude; // 위도
  double? longitude; // 경도
  int? heart;

  String? userNick;
  String? imageUrl;

  PlaceReview(
      this.prNo,
      this.placeName,
      this.thumb,
      this.addressName,
      this.roadAddressName,
      this.userNo,
      this.contents,
      this.category,
      this.latitude,
      this.longitude,
      this.heart,
      this.userNick,
      this.imageUrl);

  PlaceReview.fromJson(Map<String, dynamic> json)
      : prNo = json['prNo'],
        placeName = json['placeName'],
        thumb = json['thumb'],
        addressName = json['addressName'],
        roadAddressName = json['roadAddressName'],
        userNo = json['userNo'],
        contents = json['contents'],
        category = json['category'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        heart = json['heart'],
        userNick = json['userNick'],
        imageUrl = json['imageUrl'];

  Map<String, dynamic> toJson() {
    return {
      "prNo": prNo,
      "placeName": placeName,
      "thumb": thumb,
      "addressName": addressName,
      "roadAddressName": roadAddressName,
      "userNo": userNo,
      "contents": contents,
      "category": category,
      "latitude": latitude,
      "longitude": longitude,
      "heart": heart,
      "userNick": userNick,
      "imageUrl": imageUrl,
    };
  }

  @override
  String toString() {
    return 'PlaceReview{prNo: $prNo, placeName: $placeName, thumb: $thumb, addressName: $addressName, roadAddressName: $roadAddressName, userNo: $userNo, contents: $contents, category: $category, latitude: $latitude, longitude: $longitude, heart: $heart, userName: $userNick, imageUrl: $imageUrl}';
  }
}
