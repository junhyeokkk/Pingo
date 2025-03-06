import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/match_model.dart';

// MatchModel Model로 변경!
class NotificationViewModel extends Notifier<Map<String, MatchModel>> {
  @override
  build() {
    return {};
  }

  // 매치한 사람들 상태 넣기
  void matchNotification(Map<String, MatchModel> matchUserMap) {
    state = matchUserMap;
  }

  // 상태 null로 넣기
  void emptyNotification() {
    state = {};
  }
}

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, Map<String, MatchModel>>(
  () {
    return NotificationViewModel();
  },
);
