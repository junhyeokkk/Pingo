import 'package:flutter/material.dart';
import 'package:pingo_front/data/models/keyword_model/keyword.dart';
import 'package:pingo_front/data/models/user_model/user_info.dart';

// 프로필 상세 정보를 담는 모델 클래스
class ProfileDetail {
  UserInfo? userInfo;
  List<Keyword>? userKeyword;
  String? userIntroduction;

  ProfileDetail(this.userInfo, this.userKeyword, this.userIntroduction);
}
