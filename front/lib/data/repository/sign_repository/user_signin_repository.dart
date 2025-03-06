import 'package:dio/dio.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:pingo_front/data/network/response_dto.dart';
import 'package:pingo_front/data/repository/root_url.dart';

class UserSigninRepository {
  final Dio _dio = Dio();
  final CustomDio _customDio = CustomDio();

  // 로그인 체크
  Future<Map<String, dynamic>> loginWithToken(String accessToken) async {
    Response response = await _dio.post(
      '$rootURL/auto-signin',
      options: Options(
        headers: {'Authorization': accessToken},
      ),
    );

    return response.data;
  }

  // 로그인
  Future<dynamic> fetchSendSignInData(loginData) async {
    try {
      Response response =
          await _dio.post('$rootURL/permit/signin', data: loginData);

      dynamic userData = ResponseDTO.validation(response.data);

      logger.d(userData);

      if (userData.containsKey('error')) {
        return {"error": userData['error']}; // 에러 메시지 반환
      }

      return userData;
    } catch (e) {
      logger.e(e.toString());
      return {"error": "아이디 또는 비밀번호가 일치하지 않습니다."}; // 기본 에러 메시지 반환
    }
  }
}
