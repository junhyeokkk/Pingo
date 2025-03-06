import 'package:dio/dio.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/network/response_dto.dart';
import 'package:pingo_front/data/repository/root_url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomDio {
  static final CustomDio _instance = CustomDio();
  final Dio dio;

  CustomDio()
      : dio = Dio(
          BaseOptions(
            baseUrl: rootURL,
            connectTimeout: const Duration(seconds: 10), // 연결 시간 초과
            receiveTimeout: const Duration(seconds: 10), // 응답 시간 초과
            headers: {'Accept': 'application/json'},
            contentType: 'application/json;charset=utf-8',
            validateStatus: (status) => true,
          ),
        );

  static CustomDio get instance => _instance;

  /// Get 요청 커스텀 메서드 (통신 + 검증 후 데이터 반환)
  /// final CustomDio _dio = CustomDio.instance; 로 주입받아 사용
  /// - path : 요청 주소의 path 부분
  /// - query : get 요청시 전송할 데이터 (Map 형태)
  /// - contentType : 기본값 application/json, 변경 필요시 입력
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query,
      String contentType = 'application/json'}) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: query,
        options: Options(headers: {'Content-Type': contentType}),
      );

      dynamic result = ResponseDTO.validation(response.data);
      return result;
    } on DioException catch (e) {
      return _dioException(e);
    } catch (e) {
      logger.e("서버 데이터 처리 오류");
      return null;
    }
  }

  /// Post 요청 커스텀 메서드 (통신 + 검증 후 데이터 반환)
  /// final CustomDio _dio = CustomDio.instance; 로 주입받아 사용
  /// - path : 요청 주소의 path 부분
  /// - data : post 요청시 전송할 데이터 (객체)
  /// - contentType : 기본값 application/json, 변경 필요시 입력
  Future<dynamic> post(String path,
      {dynamic data, String contentType = 'application/json'}) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        options: Options(
          headers: {'Content-Type': contentType},
        ),
      );

      dynamic result = ResponseDTO.validation(response.data);
      return result;
    } on DioException catch (e) {
      return _dioException(e);
    } catch (e) {
      logger.e("서버 데이터 처리 오류 (resultCode : 2)");
      return null;
    }
  }

  // case1 - 통신 성공 (서버로 요청을 보내고 응답을 받는건 성공)
  // - 정상적으로 통신 성공 (resultCode = 1)
  // -- responseDTO의 data를 꺼내 반환
  // - 서버에서 검증 중에 실패 (resultCode = 2)
  // -- 전역 예외로 던지니까 data를 반환하면 에러 내용이 들어 있음

  // case2 - 통신 실패
  // - 서버로 요청을 보내지 못함
  // - 서버로부터 응답을 받지 못함

  // dio 통신 공통 예외 처리
  dynamic _dioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        logger.e('연결 시간 초과!');
        break;
      case DioExceptionType.receiveTimeout:
        logger.e('응답 시간 초과!');
        break;
      case DioExceptionType.badResponse:
        logger.e('잘못된 응답 (${e.response?.statusCode}): ${e.response?.data}');
        break;
      case DioExceptionType.cancel:
        logger.e('요청이 취소됨');
        break;
      case DioExceptionType.unknown:
        logger.e('알 수 없는 네트워크 오류 발생: ${e.message}');
        break;
      default:
        logger.e('네트워크 오류 발생: (${e.response?.statusCode}) ${e.message}');
        break;
    }
    return null;
  }

  // 토큰 추가
  Future<void> setToken(String token) async {
    dio.options.headers['Authorization'] = token;
    logger.i("토큰 추가 성공");

    await Future.delayed(Duration(milliseconds: 100));
  }

  // 토큰을 삭제
  Future<void> clearToken() async {
    dio.options.headers.remove('Authorization');
    logger.i("토큰이 CustomDio에서 삭제됨");

    await Future.delayed(Duration(milliseconds: 100));
  }
}

// 디바이스(핸드폰)에는 각 운영체제에 맞는 보안 저장소가 있음
// secureStorage는 flutter에서 디바이스 내의 보안 저장소를 이용하게 해주는 패키지
// 즉, secureStorage는 저장소가 아니라 디바이스 내의 보안 저장소를 손쉽게 사용하게 해주는 패키지
// secureStorage는 Key-Value 구조로 디바이스 내의 보안 저장소에 데이터를 저장
// 보안 저장소인 이유는 데이터를 단순히 저장하는게 아니라 암호화 알고리즘을 이용해 저장
// secureStorage 패키지는 read / write / delete 함수를 이용해 손쉽게 데이터를 저장
const secureStorage = FlutterSecureStorage();
