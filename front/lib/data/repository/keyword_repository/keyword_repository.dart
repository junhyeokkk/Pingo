import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/main_model/Profile.dart';
import 'package:pingo_front/data/network/custom_dio.dart';

import '../../models/keyword_model/keyword_group.dart';

// 스프링 서버와 통신하는 repository
class KeywordRepository {
  final CustomDio _customDio = CustomDio.instance;

  // localhost:8080/pingo/keyword로 http 통신
  // 통신의 결과를 ResponseDTO.validation로 검증하고 알맞은 데이터 타입으로 매핑
  Future<Map<String, KeywordGroup>> fetchKeyword() async {
    final response = await _customDio.get('/keyword');

    Map<String, KeywordGroup> keywordGroup = {};

    for (var key in response.keys) {
      keywordGroup.addAll({key: KeywordGroup.fromJson(response[key])});
    }
    return keywordGroup;
  }

  // 키워드로 조회
  Future<List<Profile>> fetchSelectedKeyword(userNo, kwId) async {
    final response = await _customDio.get(
      '/recommend',
      query: {'userNo': userNo, 'sKwId': kwId},
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

    logger.i("✅ fetchSelectedKeyword 주변 유저 불러오기 성공: ${users.length}명");
    return users;
  }
}
