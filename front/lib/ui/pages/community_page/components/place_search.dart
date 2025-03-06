import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/community_model/kakao_search.dart';
import 'package:pingo_front/data/models/community_model/place_review_search.dart';
import 'package:pingo_front/data/view_models/community_view_model/place_review_search_view_model.dart';

class PlaceSearch extends ConsumerStatefulWidget {
  final PlaceReviewSearch searchReviewState;
  final PlaceReviewSearchViewModel searchReviewProvider;
  final Function _onSearchCleared;
  PlaceSearch(
      this.searchReviewState, this.searchReviewProvider, this._onSearchCleared,
      {super.key});

  @override
  ConsumerState<PlaceSearch> createState() => _PlaceSearchState();
}

class _PlaceSearchState extends ConsumerState<PlaceSearch> {
  @override
  Widget build(BuildContext context) {
    List<KakaoSearch> searchList =
        widget.searchReviewState.kakaoSearchResult.kakaoSearchList;

    return searchList.isNotEmpty
        ? ListView.builder(
            itemCount: searchList.length,
            itemBuilder: (context, index) {
              return resultBox(searchList[index]);
            },
          )
        : const Center(child: Text('결과 없음', style: TextStyle(fontSize: 18)));
  }

  Widget resultBox(resultList) {
    return GestureDetector(
      onTap: () async {
        print(resultList.addressName);
        await widget.searchReviewProvider
            .searchPlaceReviewWithKeyword(resultList);
        widget._onSearchCleared();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black),
          ),
        ),
        child: Row(
          children: [
            parsePlaceIcon(resultList.category),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(resultList.placeName,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4.0),
                Text(resultList.addressName),
                Text(resultList.roadAddressName),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget parsePlaceIcon(String category) {
    switch (category) {
      case "대형마트":
        return const Icon(Icons.store_mall_directory, color: Colors.blue);
      case "편의점":
        return const Icon(Icons.local_convenience_store, color: Colors.green);
      case "어린이집, 유치원":
        return const Icon(Icons.child_care, color: Colors.orange);
      case "학교":
        return const Icon(Icons.school, color: Colors.blueAccent);
      case "학원":
        return const Icon(Icons.menu_book, color: Colors.deepPurple);
      case "주차장":
        return const Icon(Icons.local_parking, color: Colors.grey);
      case "주유소, 충전소":
        return const Icon(Icons.local_gas_station, color: Colors.red);
      case "지하철역":
        return const Icon(Icons.directions_subway, color: Colors.indigo);
      case "은행":
        return const Icon(Icons.account_balance, color: Colors.green);
      case "문화시설":
        return const Icon(Icons.theater_comedy, color: Colors.purple);
      case "중개업소":
        return const Icon(Icons.real_estate_agent, color: Colors.brown);
      case "공공기관":
        return const Icon(Icons.business, color: Colors.blueGrey);
      case "관광명소":
        return const Icon(Icons.camera, color: Colors.amber);
      case "숙박":
        return const Icon(Icons.hotel, color: Colors.deepOrange);
      case "음식점":
        return const Icon(Icons.restaurant, color: Colors.redAccent);
      case "카페":
        return const Icon(Icons.local_cafe, color: Colors.brown);
      case "병원":
        return const Icon(Icons.local_hospital, color: Colors.pink);
      case "약국":
        return const Icon(Icons.local_pharmacy, color: Colors.teal);
      default:
        return const Icon(Icons.location_on, color: Colors.grey);
    }
  }
}
