import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mime/mime.dart';
import 'package:pingo_front/_core/utils/location.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/keyword_model/keyword.dart';
import 'package:pingo_front/data/models/sign_model/user_signup.dart';
import 'package:pingo_front/data/network/custom_dio.dart';

/// 회원가입 Repository
class UserSignupRepository {
  final CustomDio _customDio = CustomDio();

  /// 아이디 중복 검증
  Future<bool> fetchValidateId(String userId) async {
    final response =
        await _customDio.get('/permit/validateId', query: {'inputId': userId});

    if (response != null) {
      return response as bool;
    } else {
      return false;
    }
  }

  /// 닉네임 중복 검증
  Future<bool> fetchValidateNick(String userNick) async {
    final response = await _customDio
        .get('/permit/validateNick', query: {'inputNick': userNick});

    if (response != null) {
      return response as bool;
    } else {
      return false;
    }
  }

  /// 3차 키워드 조회
  Future<List<Keyword>> fetch3ndKeyword() async {
    List<dynamic> response =
        (await _customDio.get('/permit/3ndKeyword')) as List;
    List<Keyword> result =
        (response as List).map((item) => Keyword.fromJson(item)).toList();
    return result;
  }

  /// 회원가입 데이터 전송
  Future<bool> fetchSignup(UserSignup signupData, File profileImage) async {
    // 파일의 MIME 타입 추론
    String? mimeType = lookupMimeType(profileImage.path) ?? 'image/jpeg';

    // 현재 위치 가져오기 (기존 위치가 없으면 새로 요청)
    Position? currentPosition = LocationService.lastPosition;
    if (currentPosition == null) {
      currentPosition = await LocationService.requestAndGetLocation();
    }

    // 일단 테스트 버튼을 없애면 null 값이 있을 경우 이 함수가 호출이 되지는 않지만
    // 그래도 이 함수에서 전송할 UserSignup 객체에 null이 있는지 확인하는 작업 추가 필요함
    // 이미지 이름도 profile.jpg가 아니라 임의의 사진이름 필요 (백엔드에서 구분 가능하기만 하면 됨)
    FormData formData = FormData.fromMap({
      "userSignUp": MultipartFile.fromString(
        jsonEncode(signupData.toJson()),
        contentType: DioMediaType("application", "json"),
      ),
      "image": await MultipartFile.fromFile(
        profileImage.path,
        filename: "profile.jpg",
        contentType: DioMediaType.parse(mimeType),
      ),
      "latitude": MultipartFile.fromString(
        jsonEncode(currentPosition?.latitude),
        contentType: DioMediaType("application", "json"),
      ),
      "longitude": MultipartFile.fromString(
        jsonEncode(currentPosition?.longitude),
        contentType: DioMediaType("application", "json"),
      ),
    });

    logger.d(formData);

    final response = await _customDio.post(
      '/permit/signup',
      data: formData,
      contentType: 'multipart/form-data',
    );

    return response;
    // 서버 로직 완료 후 성공 실패 처리 남음
  }

  // 이메일 인증번호 발송
  Future<String?> fetchVerifyEmail(String userEmail) async {
    final response =
        await _customDio.post('/permit/sendemailforsignup', data: userEmail);

    if (response != null && response is String) {
      return response;
    } else {
      return null;
    }
  }

  // 이메일 인증번호 체크
  Future<bool> fetchVerifyCode(requestData) async {
    if (!requestData.containsKey("sessionId")) {
      logger.e("세션 ID 없음, 요청 중단");
      return false;
    }

    final response = await _customDio.post(
      '/permit/checkcode',
      data: requestData,
    );

    if (response != null) {
      return response as bool;
    } else {
      return false;
    }
  }
}
