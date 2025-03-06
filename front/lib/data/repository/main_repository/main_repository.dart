import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/main_model/Profile.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:pingo_front/data/network/response_dto.dart';

class MainRepository {
  final CustomDio _customDio = CustomDio.instance;

  // 메인 렌더링 - 주변 유저 불러오기
  Future<List<Profile>> fetchNearbyUsers(String userNo, int distanceKm) async {
    final response = await _customDio.get(
      '/user/nearby',
      query: {'userNo': userNo, 'distanceKm': distanceKm},
    );

    List<dynamic> usersData = response;

    List<Profile> users = usersData
        .map((user) => Profile(
            userNo: user['userNo'],
            name: user['userName'],
            age: user['age'],
            status: user['status'],
            distance: user['distance'],
            ImageList: List<String>.from(user['imageList'] ?? [])))
        .toList();

    logger.i("✅ fetchNearbyUsers 주변 유저 불러오기 성공: ${users.length}명");
    return users;
  }

  // 스와이프 등록 요청
  Future<void> insertSwipe(Map<String, dynamic> reqData) async {
    final response = await _customDio.post(
      '/insertSwipe',
      data: reqData,
    );
  }
}
