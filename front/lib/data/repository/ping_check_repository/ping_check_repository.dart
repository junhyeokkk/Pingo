import 'package:http/http.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/main_model/Profile.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:pingo_front/data/repository/root_url.dart';

class PingCheckRepository {
  final CustomDio _customDio = CustomDio.instance;

  // PingCheck 메서드
  Future<Map<String, List<Profile>>> checkPing(String userNo) async {
    final response =
        await _customDio.get('/checkping', query: {'userNo': userNo});

    // List<dynamic> responseData = response;
    logger.i(response);

    Map<String, List<Profile>> result = {};

    response.forEach((key, usersList) {
      result[key] = (usersList as List<dynamic>)
          .map((user) => Profile.fromJson(user as Map<String, dynamic>))
          .toList();
    });
    // 데이터를 변환하여 `Map<String, List<Profile>>` 형태로 저장
    // responseData.forEach((swipeType, usersList) {
    //   List<Profile> profiles = (usersList as List).map((user) {
    //     return Profile(
    //       userNo: user['userNo'],
    //       name: user['userName'],
    //       age: user['age'].toString(), // 나이를 문자열로 변환
    //       status: swipeType, // swipeType을 status로 설정
    //       distance: null, // 거리 정보 없음
    //       ImageList: [user['imageUrl']], // 단일 이미지라도 리스트 형태로 저장
    //       imageUrl: user['imageUrl'], // 대표 이미지
    //     );
    //   }).toList();
    //
    //   result[swipeType] = profiles; // Map에 추가
    // });

    return result;
  }
}
