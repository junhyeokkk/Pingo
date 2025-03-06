import 'package:pingo_front/data/models/keyword_model/keyword.dart';
import 'package:pingo_front/data/models/user_model/user_image.dart';
import 'package:pingo_front/data/models/user_model/user_info.dart';
import 'package:pingo_front/data/models/user_model/users.dart';

class UserMypageInfo {
  Users? users;
  UserInfo? userInfo;
  List<UserImage>? userImageList;
  List<Keyword>? myKeywordList;
  List<Keyword>? favoriteKeywordList;
  String? userIntroduction;

  UserMypageInfo(
      {this.users,
      this.userInfo,
      this.userImageList,
      this.myKeywordList,
      this.favoriteKeywordList,
      this.userIntroduction});

  // JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'users': users?.toJson(),
      'userInfo': userInfo?.toJson(),
      'userImageList': userImageList?.map((image) => image.toJson()).toList(),
      'myKeywordList':
          myKeywordList?.map((keyword) => keyword.toJson()).toList(),
      'favoriteKeywordList':
          favoriteKeywordList?.map((keyword) => keyword.toJson()).toList(),
      'userIntroduction': userIntroduction,
    };
  }

  UserMypageInfo copyWith(UserMypageInfo? oldMypageInfo) {
    return UserMypageInfo(
      users: oldMypageInfo?.users ?? this.users,
      userInfo: oldMypageInfo?.userInfo ?? this.userInfo,
      userImageList: oldMypageInfo?.userImageList ?? this.userImageList,
      myKeywordList: oldMypageInfo?.myKeywordList ?? this.myKeywordList,
      favoriteKeywordList:
          oldMypageInfo?.favoriteKeywordList ?? this.favoriteKeywordList,
      userIntroduction:
          oldMypageInfo?.userIntroduction ?? this.userIntroduction,
    );
  }

  UserMypageInfo.fromJson(Map<String, dynamic> json)
      : users = Users.fromJson(json['users']),
        userInfo = UserInfo.fromJson(json['userInfo']),
        myKeywordList = (json['myKeywordList'] as List<dynamic>?)
            ?.map((child) => Keyword.fromJson(child as Map<String, dynamic>))
            .toList(),
        favoriteKeywordList = (json['favoriteKeywordList'] as List<dynamic>?)
            ?.map((child) => Keyword.fromJson(child as Map<String, dynamic>))
            .toList(),
        userImageList = (json['userImageList'] as List<dynamic>?)
            ?.map((child) => UserImage.fromJson(child as Map<String, dynamic>))
            .toList(),
        userIntroduction = json['userIntroduction'];

  @override
  String toString() {
    return 'UserMypageInfo{users: $users, userInfo: $userInfo, userImageList: $userImageList, myKeywordList: $myKeywordList, favoriteKeywordList: $favoriteKeywordList, userIntroduction: $userIntroduction}';
  }
}
