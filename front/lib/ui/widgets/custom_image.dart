import 'package:flutter/material.dart';
import 'package:pingo_front/data/repository/root_url.dart';

/// 서버에 있는 데이터를 조회하기 위한 커스텀 이미지 위젯
/// CustomImage().token('url'); 로 호출
/// 이 위젯은 사진의 크기를 제한하지 않으므로 사용시 바깥에 SizedBox같은 위젯으로 크기 지정
/// 이 위젯은 싱글톤으로 만들어져 로그인시 자동으로 해당 사용자으 JWT 토큰 추가됨
class CustomImage {
  static final CustomImage _instance = CustomImage._internal();

  CustomImage._internal();

  String? _token;

  factory CustomImage() {
    return _instance;
  }

  void setToken(String token) {
    _token = token;
  }

  /// DecorationImage에서 사용할 수 있도록 ImageProvider 반환 메서드 추가
  ImageProvider getImageProvider(String url) {
    return NetworkImage(
      '$rootURL/uploads$url',
      headers: {'Authorization': '$_token'},
    );
  }

  /// 토큰 인증 기반의 이미지 호출 메서드
  /// url : 이미지가 존재하는 서버의 주소
  Image token(String url) {
    return Image(
      image: NetworkImage(
        '$rootURL/uploads$url',
        headers: {'Authorization': '$_token'},
      ),
      fit: BoxFit.cover,
    );
  }

  /// 토큰 인증 기반의 Provider 이미지 호출 메서드
  /// url : 이미지가 존재하는 서버의 주소
  ImageProvider provider(String url) {
    return NetworkImage(
      '$rootURL/uploads$url',
      headers: {'Authorization': '$_token'},
    );
  }
}
