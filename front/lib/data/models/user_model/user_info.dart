class UserInfo {
  String? userNo;
  DateTime? userBirth;
  int? userHeight;
  String? userAddress;
  String? user1stJob;
  String? user2ndJob;
  String? userReligion;
  String? userDrinking;
  String? userSmoking;
  String? userBloodType;

  UserInfo({
    this.userNo,
    this.userBirth,
    this.userHeight,
    this.userAddress,
    this.user1stJob,
    this.user2ndJob,
    this.userReligion,
    this.userDrinking,
    this.userSmoking,
    this.userBloodType,
  });

  Map<String, dynamic> toJson() {
    return {
      "userNo": userNo,
      "userBirth": userBirth?.toIso8601String(),
      "userHeight": userHeight,
      "userAddress": userAddress,
      "user1stJob": user1stJob,
      "user2ndJob": user2ndJob,
      "userReligion": userReligion,
      "userDrinking": userDrinking,
      "userSmoking": userSmoking,
      "userBloodType": userBloodType,
    };
  }

  UserInfo.fromJson(Map<String, dynamic> json)
      : userNo = json['userNo'],
        userBirth = json['userBirth'] != null
            ? DateTime.parse(json['userBirth'])
            : null,
        userHeight = json['userHeight'],
        userAddress = json['userAddress'],
        user1stJob = json['user1stJob'],
        user2ndJob = json['user2ndJob'],
        userReligion = json['userReligion'],
        userDrinking = json['userDrinking'],
        userSmoking = json['userSmoking'],
        userBloodType = json['userBloodType'];

  @override
  String toString() {
    return 'UserInfo{userNo: $userNo, userBirth: $userBirth, userHeight: $userHeight, userAddress: $userAddress, user1stJob: $user1stJob, user2ndJob: $user2ndJob, userReligion: $userReligion, userDrinking: $userDrinking, userSmoking: $userSmoking, userBloodType: $userBloodType}';
  }

  // .copywith 메서드 생성( 깊은 복사로 복사본 만드는 함수 )
  UserInfo copyWith(UserInfo? oldInfo) {
    return UserInfo(
      userNo: oldInfo?.userNo ?? this.userNo,
      userBirth: oldInfo?.userBirth ?? this.userBirth,
      userHeight: oldInfo?.userHeight ?? this.userHeight,
      userAddress: oldInfo?.userAddress ?? this.userAddress,
      user1stJob: oldInfo?.user1stJob ?? this.user1stJob,
      user2ndJob: oldInfo?.user2ndJob ?? this.user2ndJob,
      userReligion: oldInfo?.userReligion ?? this.userReligion,
      userDrinking: oldInfo?.userDrinking ?? this.userDrinking,
      userSmoking: oldInfo?.userSmoking ?? this.userSmoking,
      userBloodType: oldInfo?.userBloodType ?? this.userBloodType,
    );
  }
}
