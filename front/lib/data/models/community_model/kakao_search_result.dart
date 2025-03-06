import 'package:pingo_front/data/models/community_model/kakao_search.dart';

class KakaoSearchResult {
  int searchPage = 1;
  List<KakaoSearch> kakaoSearchList;

  KakaoSearchResult(this.kakaoSearchList);

  @override
  String toString() {
    return 'KakaoSearchResult{searchPage: $searchPage, kakaoSearchList: $kakaoSearchList}';
  }

  void changeKakaoSearchList(List<KakaoSearch> newList) {
    kakaoSearchList.clear();
    kakaoSearchList.addAll(newList);
  }
}
