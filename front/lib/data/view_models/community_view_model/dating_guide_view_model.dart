import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/community_model/dating_guide.dart';
import 'package:pingo_front/data/models/community_model/dating_guide_search.dart';
import 'package:pingo_front/data/repository/community_repository/dating_guide_repository.dart';

class DatingGuideViewModel extends Notifier<Map<String, DatingGuideSearch>> {
  final DatingGuideRepository _repository;
  DatingGuideViewModel(this._repository);

  @override
  Map<String, DatingGuideSearch> build() {
    selectDatingGuideForInit();
    return {};
  }

  // init - 모든 게시글 인기순으로 조회
  Future<void> selectDatingGuideForInit() async {
    Map<String, DatingGuideSearch> response =
        await _repository.fetchSelectDatingGuideForInit();
    state = response;
  }

  // sort - 각 게시글 카테고리별로 정렬 변경시 조회
  Future<void> changeSearchSort(
      String newSort, int category, String cateName) async {
    List<DatingGuide> response =
        await _repository.fetchSelectDatingGuideWithSort(newSort, category);

    state[cateName]?.changeDatingGuideListBySort(response, newSort);
  }

  // 게시글 작성
  Future<bool> insertDatingGuide(
      Map<String, dynamic> data, File guideImage) async {
    return await _repository.fetchInsertDatingGuide(data, guideImage);
  }

  // 게시글 좋아요
  Future<String> clickThumbUp(String userNo, String dgNo) async {
    return await _repository.fetchClickThumbUp(userNo, dgNo);
  }
}

final datingGuideViewModelProvider =
    NotifierProvider<DatingGuideViewModel, Map<String, DatingGuideSearch>>(
  () => DatingGuideViewModel(DatingGuideRepository()),
);
