import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:pingo_front/data/models/global_model/session_user.dart';
import 'package:pingo_front/data/repository/location_repository/location_repository.dart';

class LocationService {
  static final Logger _logger = Logger(); // Logger 인스턴스 생성
  static Position? _lastPosition; // 이전 위치 저장
  static final LocationRepository _locationRepository =
      LocationRepository(); // 싱글턴
  static Timer? _locationTimer; // 10분마다 실행되는 Timer
  static SessionUser? _sessionUser; // 현재 로그인한 유저 정보

  // 마지막 위치 가져오기 (전역 접근)
  static Position? get lastPosition => _lastPosition;

  // 앱 실행 시 → 위치 권한 확인 & 현재 위치 저장 (서버 요청 x)
  static Future<void> initializeLocation() async {
    Position? position = await requestAndGetLocation();
    if (position != null) {
      _lastPosition = position; // 위치 저장만 수행 (서버 요청 x)
    }
  }

  // 위치 강제 업데이트 (외부에서 호출 가능)
  static void updateLastPosition(Position position) {
    _lastPosition = position;
  }

  // 로그인 후 위치 추적 시작 (서버 요청 o)
  static void startLocationTracking(SessionUser sessionUser) {
    _sessionUser = sessionUser; // 로그인된 유저 저장

    _locationTimer = Timer.periodic(Duration(minutes: 10), (timer) async {
      Position? position = await requestAndGetLocation();
      if (position != null) {
        _updateAndSendLocation(position);
      }
    });
  }

  // 로그아웃 시 위치 추적 중지
  static void stopLocationTracking() {
    _logger.i("📍 위치 추적 중지 (로그아웃)");
    _locationTimer?.cancel();
    _sessionUser = null; // 유저 정보 초기화
  }

  // 현재 위치 가져오기 (1회 요청)
  static Future<Position?> requestAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.e("위치 서비스가 비활성화됨.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.w("위치 권한이 거부됨.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.e("위치 권한이 영구적으로 거부됨. 설정에서 변경 필요.");
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _logger.i("위치 가져오기 성공: ${position.latitude}, ${position.longitude}");
    return position;
  }

  // 500m 이상 이동했는지 확인 후 서버 전송
  static void _updateAndSendLocation(Position newPosition) {
    if (_sessionUser == null) {
      _logger.w("[위치 전송 취소] 로그인하지 않음.");
      return;
    }

    if (_lastPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      if (distance < 500) {
        _logger.i("이동 거리 $distance m → 500m 미만이므로 전송 안 함.");
        return;
      }
    }

    // 500m 이상 이동 → 서버 전송
    _sendLocationToServer(newPosition);
    _lastPosition = newPosition; // 최신 위치 저장
  }

  // 서버로 위치 전송
  static Future<void> _sendLocationToServer(Position position) async {
    if (_sessionUser == null) {
      _logger.w("[위치 전송 취소] 로그인 정보 없음.");
      return;
    }

    _logger.i("서버로 위치 정보 전송: ${position.latitude}, ${position.longitude}");

    await _locationRepository.sendLocation({
      'userNo': _sessionUser!.userNo, // 로그인한 유저 정보 활용
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }
}
