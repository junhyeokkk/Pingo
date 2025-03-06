class Users {
  String? userNo;
  String? userId;
  String? userPw;
  String? userName;
  String? userNick;
  String? userGender;
  String? userState;
  DateTime? userrDate;
  String? userEmail; // ✅ 이메일 필드 존재

  Users({
    this.userNo,
    this.userId,
    this.userPw,
    this.userName,
    this.userNick,
    this.userGender,
    this.userState,
    this.userrDate,
    this.userEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      "userNo": userNo,
      "userId": userId,
      "userPw": userPw,
      "userName": userName,
      "userNick": userNick,
      "userGender": userGender,
      "userState": userState,
      "userrDate": userrDate?.toIso8601String(),
      "userEmail": userEmail, // ✅ 이메일도 JSON으로 변환
    };
  }

  Users.fromJson(Map<String, dynamic> json)
      : userNo = json['userNo'],
        userId = json['userId'],
        userPw = json['userPw'],
        userName = json['userName'],
        userNick = json['userNick'],
        userGender = json['userGender'],
        userState = json['userState'],
        userrDate = json['userrDate'] != null
            ? DateTime.parse(json['userrDate'])
            : null,
        userEmail = json['userEmail']; // ✅ 이메일 변환

  @override
  String toString() {
    return 'Users{userNo: $userNo, userId: $userId, userPw: $userPw,'
        'userName: $userName, userNick: $userNick, userGender: $userGender,'
        'userState: $userState, userrDate: $userrDate, userEmail: $userEmail}';
  }

  // 이메일 변경을 위한 copyWith 추가
  Users copyWith({String? userEmail}) {
    return Users(
      userNo: this.userNo,
      userId: this.userId,
      userPw: this.userPw,
      userName: this.userName,
      userNick: this.userNick,
      userGender: this.userGender,
      userState: this.userState,
      userrDate: this.userrDate,
      userEmail: userEmail ?? this.userEmail, // 변경할 이메일 적용
    );
  }
}
