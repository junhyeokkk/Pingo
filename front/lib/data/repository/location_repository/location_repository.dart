import 'package:dio/dio.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:pingo_front/data/network/response_dto.dart';
import 'package:pingo_front/data/repository/root_url.dart';

class LocationRepository {
  final CustomDio _customDio = CustomDio.instance;

  // 서버로 위치 전송
  Future<bool> sendLocation(Map<String, dynamic> reqData) async {
    print('위치 전송 프론트 요청 입성?');
    final response = await _customDio.post(
      '/location/update',
      data: reqData,
    );
    return response;
  }
}
