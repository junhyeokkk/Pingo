import 'package:pingo_front/data/models/community_model/kakao_search_result.dart';
import 'package:pingo_front/data/models/community_model/review_search_result.dart';
import 'package:flutter/material.dart';

class PlaceReviewSearch {
  KakaoSearchResult kakaoSearchResult;
  ReviewSearchResult reviewSearchResult;

  PlaceReviewSearch(this.kakaoSearchResult, this.reviewSearchResult);

  @override
  String toString() {
    return 'PlaceReviewSearch{kakaoSearchResult: $kakaoSearchResult, reviewSearchResult: $reviewSearchResult}';
  }
}

Map<String, dynamic> kakaoCategory = {
  "음식점": Icons.restaurant,
  "카페": Icons.local_cafe,
  "관광명소": Icons.camera_alt,
  "숙박": Icons.hotel,
  "문화시설": Icons.theater_comedy,
  "대형마트": Icons.store_mall_directory,
  "편의점": Icons.local_convenience_store,
  "공공기관": Icons.apartment,
  "주차장": Icons.local_parking,
  // "주유소, 충전소": Icons.local_gas_station,

  // "어린이집, 유치원": Icons.child_care,
  // "학교": Icons.school,
  // "학원": Icons.menu_book,
  // "지하철역": Icons.directions_subway,
  // "은행": Icons.account_balance,
  // "중개업소": Icons.real_estate_agent,
  // "병원": Icons.local_hospital,
  // "약국": Icons.local_pharmacy,
  // "기타": Icons.pin_drop_outlined,
};
