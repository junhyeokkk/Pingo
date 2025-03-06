class MatchModel {
  final String? userName;
  final String? userBirth;
  final String? imageUrl;

  MatchModel({
    this.userName,
    this.userBirth,
    this.imageUrl,
  });

  MatchModel.fromJson(Map<String, dynamic> json)
      : userName = json['userName'] ?? '',
        userBirth = json['userBirth'] ?? '',
        imageUrl = json['imageUrl'] ?? '';

  @override
  String toString() {
    return 'MatchModel{userName: $userName, userAge: $userBirth, userImage: $imageUrl}';
  }
}
