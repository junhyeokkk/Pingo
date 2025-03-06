import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pingo_front/_core/utils/location.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/global_model/session_user.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:pingo_front/data/repository/location_repository/location_repository.dart';
import 'package:pingo_front/data/repository/sign_repository/user_signin_repository.dart';
import 'package:pingo_front/main.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';

class SigninViewModel extends Notifier<SessionUser> {
  final mContext = navigatorkey.currentContext!;
  UserSigninRepository repository = UserSigninRepository();
  LocationRepository locationRepository = LocationRepository();

  @override
  SessionUser build() {
    return SessionUser();
  }

  // 로그인 체크
  Future<void> checkLoginState() async {
    String? accessToken = await secureStorage.read(key: 'accessToken');
    if (accessToken == null) {
      logger.d('토큰이 없어?');
      throw Exception('토큰 없음');
    }

    Map<String, dynamic> response =
        await repository.loginWithToken(accessToken);

    response = response['data'];

    logger.d(response);

    if (response['message'] == '자동 로그인 성공') {
      // sendLocation에서 CustomDio를 사용중이기 때문에 토큰 설정후 위치전송(자동로그인)
      CustomDio.instance.setToken(accessToken);

      // 현재 위치 가져오기 (기존 위치 없으면 새로 요청)
      Position? currentPosition = LocationService.lastPosition;
      if (currentPosition == null) {
        currentPosition = await LocationService.requestAndGetLocation();
      }

      // 세션 유저 업데이트
      state = SessionUser(
        userNo: response['userNo'],
        userRole: response['userRole'],
        expDate: response['expDate'] != null
            ? DateTime.parse(response['expDate'])
            : null,
        accessToken: accessToken,
        isLogin: true,
      );

      // 현재 위치 서버로 전송
      await locationRepository.sendLocation({
        'userNo': response['userNo'],
        'latitude': currentPosition?.latitude,
        'longitude': currentPosition?.longitude,
      });

      // 로그인 시 위치 추적 시작
      LocationService.startLocationTracking(state);

      // 커스텀 이미지 조회 위젯에 토큰 저장
      CustomImage().setToken(accessToken);

      Navigator.popAndPushNamed(mContext, '/mainScreen');
    } else {
      throw Exception('로그인 실패');
    }
  }

  // 로그인
  Future<void> login(String userId, String userPw) async {
    try {
      Position? currentPosition = LocationService.lastPosition;
      if (currentPosition == null) {
        currentPosition = await LocationService.requestAndGetLocation();
      }

      Map<String, dynamic> loginData = {
        "userId": userId,
        "userPw": userPw,
        "latitude": currentPosition?.latitude,
        "longitude": currentPosition?.longitude,
      };

      Map<String, dynamic> userData =
          await repository.fetchSendSignInData(loginData);

      if (userData.containsKey('error')) {
        throw Exception(userData['error']); // 에러 메시지를 뷰로 전달
      }

      await secureStorage.write(
          key: 'accessToken', value: userData['accessToken']);

      state = SessionUser(
        userNo: userData['userNo'],
        userRole: userData['userRole'],
        expDate: userData['expDate'] != null
            ? DateTime.parse(userData['expDate'])
            : null,
        accessToken: userData['accessToken'],
        isLogin: true,
      );

      CustomDio.instance.setToken(userData['accessToken']);

      LocationService.startLocationTracking(state);
      CustomImage().setToken(userData['accessToken']);

      Navigator.popAndPushNamed(mContext, '/mainScreen');
    } catch (e) {
      throw Exception("아이디 또는 비밀번호가 일치하지 않습니다.");
    }
  }

  // 로그아웃
  void logout() {
    secureStorage.delete(key: 'accessToken');
    state = SessionUser(
      userNo: null,
      userRole: null,
      accessToken: null,
      isLogin: false,
    );

    // 로그아웃 시 위치 추적 중지
    LocationService.stopLocationTracking();

    CustomDio.instance.clearToken();
    Navigator.popAndPushNamed(mContext, '/signin');
  }

  // 멤버쉽 정보 수정
  void updateExpDate(String updateExpDate) {
    state.expDate = DateTime.parse(updateExpDate);
    logger.i(state.expDate);
  }
}

final sessionProvider = NotifierProvider<SigninViewModel, SessionUser>(
  () => SigninViewModel(),
);
