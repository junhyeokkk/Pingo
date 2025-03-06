class UserImage {
  String? imageNo;
  String? imageUrl;
  String? imageProfile;
  String? userNo;

  UserImage({
    this.imageNo,
    this.imageUrl,
    this.imageProfile,
    this.userNo,
  });

  Map<String, dynamic> toJson() {
    return {
      "imageNo": imageNo,
      "imageUrl": imageUrl,
      "imageProfile": imageProfile,
      "userNo": userNo,
    };
  }

  UserImage.fromJson(Map<String, dynamic> json)
      : imageNo = json['imageNo'],
        imageUrl = json['imageUrl'],
        imageProfile = json['imageProfile'],
        userNo = json['userNo'];

  UserImage copyWith({
    String? imageNo,
    String? imageUrl,
    String? imageProfile,
    String? userNo,
  }) {
    return UserImage(
      imageNo: imageNo ?? this.imageNo,
      imageUrl: imageUrl ?? this.imageUrl,
      imageProfile: imageProfile ?? this.imageProfile,
      userNo: userNo ?? this.userNo,
    );
  }

  @override
  String toString() {
    return 'UserImage{imageNo: $imageNo, imageUrl: $imageUrl, imageProfile: $imageProfile, userNo: $userNo}';
  }
}
