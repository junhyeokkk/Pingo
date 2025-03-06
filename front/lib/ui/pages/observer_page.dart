import 'package:flutter/cupertino.dart';

// 추상 클래스
class observerPage extends WidgetsBindingObserver {
  // state를 매개변수로 받는 메서드
  Function(AppLifecycleState) onStateChanged;

  observerPage({required this.onStateChanged}) {
    // 앱의 생명주기를 관찰할 수 있도록 WidgetsBinding에 현재 객체를 등록한다.
    WidgetsBinding.instance.addObserver(this);
  }

  // 앱의 생명주기 상태가 변경될 때 호출된다.
  // 예를 들어 , 앱이 백그라운드로 이동하거나 포그라운드로 돌아올 때 이 메서드가 호출됨
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    onStateChanged(state); // 앱 상태 변경 시 실행할 함수 호출
  }

  // 옵저버 해제
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
