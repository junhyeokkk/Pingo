import 'package:flutter/material.dart';
import 'package:pingo_front/_core/utils/logger.dart';

// 전역관리 안할 시 각 페이지에서 수동으로 등록해주어야함
class RouteObserverService extends RouteObserver<PageRoute<dynamic>> {
  RouteObserverService._observer(); // 생성자

  static final RouteObserverService observerService =
      RouteObserverService._observer();

  factory RouteObserverService() => observerService; // 같은 인스턴스 반환

  // 현재 활성화된 페이지 이름을 지정하는 전역 변수
  String? currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) {
      currentRoute = route.settings.name;
      logger.i('📍 현재 페이지 (PUSH): $currentRoute'); // 현재 페이지 로깅
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute is PageRoute) {
      currentRoute = previousRoute.settings.name;
    }
    super.didPop(route, previousRoute);
  }
}

// 전역 객체
final RouteObserverService routeObserver = RouteObserverService();
