import 'package:pingo_front/data/models/keyword_model/keyword.dart';
import 'package:pingo_front/data/models/main_model/ProfileDetail.dart';
import 'package:pingo_front/data/models/user_model/user_info.dart';

class Profile {
  final String userNo; // 유저 번호
  final String name; // 이름
  final String age; // 나이
  final String status; // 상태
  final String? distance; // 거리 (거리는 메인 렌더링만 들어가도록)
  final List<String> ImageList; // 여러 개의 이미지 리스트
  final String? imageUrl;
  ProfileDetail? profileDetail;

  Profile({
    required this.userNo,
    required this.name,
    required this.age,
    required this.status,
    required this.distance,
    required this.ImageList, // 전체 리스트로 변경
    this.profileDetail,
    this.imageUrl, // 대표이미지
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userNo: json['userNo'] as String,
      name: json['userName'] as String,
      age: json['age'].toString(), // 정수일 가능성이 있어 문자열 변환
      status: json['status'] as String? ?? 'Unknown', // 기본값 설정
      distance: json['distance'] as String?,
      ImageList: (json['ImageList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
      profileDetail: null,
    );
  }

  @override
  String toString() {
    return 'Profile{userNo: $userNo, name: $name, age: $age, status: $status, distance: $distance, ImageList: $ImageList, imageUrl: $imageUrl, profileDetail: $profileDetail}';
  }
}

// 샘플 데이터
final List<Profile> profiles = [
  Profile(
    userNo: 'US12341234',
    name: '박임제',
    age: '31',
    status: '접속 중',
    distance: '1km 거리',
    ImageList: [
      'assets/images/aa.png',
      'assets/images/pingo1.png',
      'assets/images/pingo2.png'
    ], // ✅ 여러 개의 이미지
    profileDetail: ProfileDetail(
        UserInfo(
            userNo: 'US12341234',
            user1stJob: 'IT직군',
            user2ndJob: '백엔드 개발자',
            userAddress: '부산',
            userBirth: DateTime(2025, 2, 11),
            userBloodType: 'A',
            userDrinking: 'N',
            userHeight: 180,
            userReligion: '천주교',
            userSmoking: 'F'),
        [
          Keyword(
              kwId: 'kw1212',
              kwName: '외향적',
              kwParentId: 'kw111',
              kwMessage: '외향적인 사람',
              kwLevel: '2')
        ],
        '나는 바보입니다.'),
  ),
];
