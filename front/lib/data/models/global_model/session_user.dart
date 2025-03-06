import 'package:geolocator/geolocator.dart';
import 'package:pingo_front/_core/utils/location.dart';

class SessionUser {
  String? userNo;
  String? userRole;
  String? accessToken;
  bool isLogin;
  DateTime? expDate;
  Position? currentLocation; // 현재 위치 저장

  // 🔥 생성자에서 현재 위치 자동 할당 (서버 요청 ❌)
  SessionUser({
    this.userNo,
    this.userRole,
    this.accessToken,
    this.expDate,
    this.isLogin = false,
  }) {
    _initializeUserLocation();
  }

  @override
  String toString() {
    return 'SessionUser{userNo: $userNo, userRole: $userRole, accessToken: $accessToken, isLogin: $isLogin, membership: $expDate, currentLocation: $currentLocation}';
  }

  // 세션 유저 정보 업데이트
  void updateSessionUser(Map<String, dynamic> userData) {
    userNo = userData['userNo'];
    userRole = userData['userRole'];
    accessToken = userData['accessToken'];
    expDate = userData['expDate'];
    isLogin = true;

    // 로그인 성공 후 위치 추적 시작
    LocationService.startLocationTracking(this);
  }

  // 위치 업데이트 (LocationService와 연동)
  void updateLocation(Position newPosition) {
    currentLocation = newPosition;
    LocationService.updateLastPosition(newPosition);
  }

  // 현재 위치를 가져와 설정하는 함수 (비동기)
  Future<void> _initializeUserLocation() async {
    Position? position = await LocationService.requestAndGetLocation();

    if (position != null) {
      updateLocation(position); // 위치 저장 (로그인 전)
    }
  }
}
