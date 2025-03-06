import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MypageMenu {
  final String title;
  final IconData iconData;

  MypageMenu({required this.title, required this.iconData});
}

final List<MypageMenu> MypageMenu1 = [
  MypageMenu(title: '내 동네 설정', iconData: FontAwesomeIcons.mapMarkerAlt),
  MypageMenu(title: '동네 인증하기', iconData: FontAwesomeIcons.compressArrowsAlt),
  MypageMenu(title: '키워드 알림', iconData: FontAwesomeIcons.tag),
  MypageMenu(title: '모아보기', iconData: FontAwesomeIcons.borderAll)
];

final List<MypageMenu> MypageMenu2 = [
  MypageMenu(title: '동네생활 글', iconData: FontAwesomeIcons.edit),
  MypageMenu(title: '동네생활 댓글', iconData: FontAwesomeIcons.commentDots),
  MypageMenu(title: '동네생활 주제 목록', iconData: FontAwesomeIcons.star)
];

final List<MypageMenu> MypageMenu3 = [
  MypageMenu(title: '비즈프로필 관리', iconData: FontAwesomeIcons.store),
  MypageMenu(title: '지역광고', iconData: FontAwesomeIcons.bullhorn)
];
