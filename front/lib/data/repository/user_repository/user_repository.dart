import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:pingo_front/data/models/user_model/user_mypage_info.dart';
import 'package:mime/mime.dart';

// 스프링 서버와 통신하는 repository
class UserRepository {
  final CustomDio _customDio = CustomDio.instance;

  // 마이페이지 회원 정보 조회
  Future<UserMypageInfo> fetchMyPageInfo(userNo) async {
    final response = await _customDio.get(
      '/user',
      query: {'userNo': userNo},
    );

    UserMypageInfo userInfo = UserMypageInfo.fromJson(response);

    return userInfo;
  }

  // 유저 정보 수정
  Future<bool> fetchSubmitUpdateInfo(Map<String, dynamic> updateInfo) async {
    try {
      final response = await _customDio.post('/user/info', data: updateInfo);

      if (response == true) {
        return true; // 서버 응답이 true면 성공
      } else {
        throw Exception("서버에서 성공 응답을 받지 못했습니다.");
      }
    } catch (e) {
      logger.e("개인 정보 수정 실패: $e");
      throw Exception("개인 정보 수정 요청 실패");
    }
  }

  // 대표 이미지 변경 API 추가
  Future<bool> updateMainProfileImage(
      String currentMainImageNo, String newMainImageNo) async {
    try {
      final response = await _customDio.dio.put(
        '/user/image',
        data: {
          "currentMainImageNo": currentMainImageNo,
          "newMainImageNo": newMainImageNo,
        },
      );

      return response.data['data'] == true;
    } catch (e) {
      logger.e("대표 이미지 변경 실패: $e");
      return false;
    }
  }

  // 유저 이미지 추가
  Future<bool> uploadUserImage(String userNo, File imageFile) async {
    try {
      String mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      FormData formData = FormData.fromMap({
        "userNo": userNo,
        "userImageForAdd": await MultipartFile.fromFile(
          imageFile.path,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response = await _customDio.post(
        "/user/image",
        data: formData,
        contentType: 'multipart/form-data',
      );

      return response == true; // 서버 응답 확인
    } catch (e) {
      logger.e("이미지 업로드 실패: $e");
      return false;
    }
  }

  // 유저 이미지 삭제
  Future<bool> deleteUserImage(String ImageNoForDelete) async {
    try {
      final response = await _customDio.dio.delete(
        '/user/image',
        data: {
          "ImageNoForDelete": ImageNoForDelete,
        },
      );

      return response.data['data'] == true;
    } catch (e) {
      logger.e("이미지 삭제 실패: $e");
      return false;
    }
  }

  // 이메일 인증번호 발송
  Future<String?> fetchVerifyEmail(String userEmail) async {
    final response =
        await _customDio.post('/permit/sendemail', data: userEmail);

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

  // 유저 아이디 찾기
  Future<String?> fetchFindUserId(requestData) async {
    final response =
        await _customDio.get('/permit/finduserid', query: requestData);

    if (response != null) {
      return response;
    } else {
      return null;
    }
  }

  // 유저 비밀번호 재설정으로 이동
  Future<String?> fetchFindUserPw(requestData) async {
    final response =
        await _customDio.get('/permit/finduserpw', query: requestData);

    if (response != null) {
      return response;
    } else {
      return null;
    }
  }

  // 유저 비밀번호 재설정
  Future<bool> fetchResetUserPw(requestData) async {
    final response =
        await _customDio.dio.put('/permit/resetuserpw', data: requestData);

    if (response.data["data"] != null) {
      return response.data["data"];
    } else {
      return false;
    }
  }
}
/**
 * 서버에서 객체로 return
 * http 통신할땐 JSON으로 변환
 * Dio가 다시 받을때 JSON을 Map<String, dynamic> 으로 받음
 *
 * response = Map<String, dynamic>;
 */
