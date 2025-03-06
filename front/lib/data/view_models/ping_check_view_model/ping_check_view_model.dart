import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/keyword_model/keyword.dart';
import 'package:pingo_front/data/models/main_model/Profile.dart';
import 'package:pingo_front/data/models/main_model/ProfileDetail.dart';
import 'package:pingo_front/data/models/user_model/user_info.dart';
import 'package:pingo_front/data/repository/ping_check_repository/ping_check_repository.dart';

class PingCheckViewModel extends Notifier<Map<String, List<Profile>>> {
  final PingCheckRepository _repository;
  PingCheckViewModel(this._repository);

  Future<void> pingcheck(String userNo) async {
    state = await _repository.checkPing(userNo);
    logger.i(state);
  }

  @override
  Map<String, List<Profile>> build() {
    return {};
  }
}

final pingCheckViewModelProvider =
    NotifierProvider<PingCheckViewModel, Map<String, List<Profile>>>(
  () => PingCheckViewModel(PingCheckRepository()),
);
