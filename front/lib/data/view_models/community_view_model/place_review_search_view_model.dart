import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/community_model/kakao_search.dart';
import 'package:pingo_front/data/models/community_model/kakao_search_result.dart';
import 'package:pingo_front/data/models/community_model/place_review.dart';
import 'package:pingo_front/data/models/community_model/place_review_search.dart';
import 'package:pingo_front/data/models/community_model/review_search_result.dart';
import 'package:pingo_front/data/models/global_model/session_user.dart';
import 'package:pingo_front/data/repository/community_repository/place_review_search_repository.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';

class PlaceReviewSearchViewModel extends Notifier<PlaceReviewSearch> {
  final PlaceReviewSearchRepository _repository;
  KakaoSearch lastSearch = KakaoSearch();
  PlaceReviewSearchViewModel(this._repository);

  @override
  PlaceReviewSearch build() {
    placeReviewInit();
    return PlaceReviewSearch(KakaoSearchResult([]), ReviewSearchResult([]));
  }

  // init
  Future<void> placeReviewInit() async {
    PlaceReviewSearch initData =
        PlaceReviewSearch(KakaoSearchResult([]), ReviewSearchResult([]));

    dynamic response = await _repository.fetchSearchPlaceReview(
        cateSort: initData.reviewSearchResult.cateSort,
        searchSort: initData.reviewSearchResult.searchSort);

    logger.i(response);

    initData.reviewSearchResult.changePlaceReviewList(response);
    state = initData;
  }

  // 게시글 좋아요
  Future<String> clickThumbUp(String userNo, String prNo) async {
    return await _repository.fetchClickThumbUp(userNo, prNo);
  }

  // 검색 정렬 기준 변경
  Future<void> changeSearchSort(newSort) async {
    List<PlaceReview> response = [];

    if (newSort == 'location') {
      SessionUser sessionUser = ref.read(sessionProvider);

      Position? position = sessionUser.currentLocation;
      if (position == null) {
        return;
      }
      response = await _repository.fetchSearchPlaceReviewWithLocation(
          cateSort: state.reviewSearchResult.cateSort,
          latitude: position.latitude,
          longitude: position.longitude);
    } else {
      response = await _repository.fetchSearchPlaceReview(
          cateSort: state.reviewSearchResult.cateSort, searchSort: newSort);
    }
    state.reviewSearchResult.changePlaceReviewList(response);
    state.reviewSearchResult.changeSearchSort(newSort);
    logger.i(state.reviewSearchResult.placeReviewList);
  }

  // 검색 카테고리 기준 변경
  Future<void> changeCateSort(newSort) async {
    state.reviewSearchResult.changeCateSort(newSort);
    state.reviewSearchResult.changeSearchSort('popular');

    List<PlaceReview> response = await _repository.fetchSearchPlaceReview(
        cateSort: newSort, searchSort: 'popular');

    state.reviewSearchResult.changePlaceReviewList(response);
  }

  // 검색창이 비었을 때 마지막 검색 기록으로 돌리기
  void searchLastPlaceReview() async {
    List<PlaceReview> response = await _repository.fetchSearchPlaceReview(
        cateSort: state.reviewSearchResult.cateSort,
        searchSort: state.reviewSearchResult.searchSort);

    state.reviewSearchResult.changePlaceReviewList(response);
  }

  // 검색으로 리뷰 조회
  Future<void> searchPlaceReviewWithKeyword(KakaoSearch kakaoSearch) async {
    List<PlaceReview> response = await _repository.fetchSearchPlaceReview(
        cateSort: state.reviewSearchResult.cateSort,
        searchSort: state.reviewSearchResult.searchSort,
        keyword: kakaoSearch.addressName);

    if (response.isEmpty) {
      lastSearch = kakaoSearch;
    }

    state.reviewSearchResult.changePlaceReviewList(response);
  }

  // placeReview 작성
  Future<bool> insertPlaceReview(Map<String, dynamic> data) async {
    return await _repository.fetchInsertPlaceReview(data);
  }

  /// 검색 ///
  // kakao search - 카카오 API 주소 검색
  Future<void> kakaoPlaceSearchApi(String keyword, int page) async {
    Map<String, dynamic> result =
        await _repository.fetchSearchKaKaoLocation(keyword, page: page);

    List<KakaoSearch> newList = (result['documents'] as List<dynamic>)
        .map((json) => KakaoSearch.fromJson(json))
        .toList();

    replaceKakaoSearchResultList(newList);
  }

  // 카카오 주소 검색 갱신
  void replaceKakaoSearchResultList(List<KakaoSearch> newList) {
    state =
        PlaceReviewSearch(KakaoSearchResult(newList), state.reviewSearchResult);
  }

  // 카카오 주소 기반 장소 이미지 크롤링
  Future<dynamic> crawlingPlaceImage(String placeUrl) async {
    return await _repository.fetchCrawlingPlaceImage(placeUrl);
  }

  // 장소 공유 채팅 조회
  Future<PlaceReview> searchPlaceForChat(
      String placeName, String placeAddress) async {
    return await _repository.fetchSearchPlaceForChat(placeName, placeAddress);
  }
}

final placeReviewSearchViewModelProvider =
    NotifierProvider<PlaceReviewSearchViewModel, PlaceReviewSearch>(
  () => PlaceReviewSearchViewModel(PlaceReviewSearchRepository()),
);
