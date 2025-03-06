import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/main_model/Profile.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

class ProfileRepository {
  // 목데이터 반환 (서버 요청 대신 사용)
  Future<List<Profile>> fetchProfiles() async {
    await Future.delayed(const Duration(seconds: 1)); // 1초 지연
    return [
      Profile(
        userNo: 'user123',
        name: '박임제',
        age: '31',
        status: '접속 중',
        distance: '1km 거리',
        ImageList: [
          'assets/images/aa.png',
          'assets/images/pingo1.png',
          'assets/images/pingo2.png'
        ],
      ),
      Profile(
        userNo: 'user456',
        name: '하나',
        age: '28',
        status: '접속 중',
        distance: '2km 거리',
        ImageList: [
          'assets/images/bb.png',
          'assets/images/bb0005.jpg',
          'assets/images/pingo3.png'
        ],
      ),
    ];
  }
}
