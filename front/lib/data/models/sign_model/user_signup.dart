import 'package:pingo_front/data/models/user_model/user_info.dart';
import 'package:pingo_front/data/models/user_model/users.dart';

class UserSignup {
  Users users;

  UserInfo userInfo;

  String? userMyKeyword;
  String? userFavoriteKeyword;

  UserSignup({
    Users? users,
    UserInfo? userInfo,
    this.userMyKeyword,
    this.userFavoriteKeyword,
  })  : users = users ?? Users(),
        userInfo = userInfo ?? UserInfo();

  factory UserSignup.createEmpty() {
    return UserSignup(
      users: Users(),
      userInfo: UserInfo(),
      userMyKeyword: '',
      userFavoriteKeyword: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "users": users.toJson(),
      "userInfo": userInfo.toJson(),
      "userMyKeyword": userMyKeyword,
      "userFavoriteKeyword": userFavoriteKeyword,
    };
  }

  @override
  String toString() {
    return 'UserSignup{users: $users, userInfo: $userInfo, userMyKeyword: $userMyKeyword, userFavoriteKeyword: $userFavoriteKeyword}';
  }
}
