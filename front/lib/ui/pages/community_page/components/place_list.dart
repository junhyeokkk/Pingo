import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/community_model/place_review.dart';
import 'package:pingo_front/data/models/community_model/place_review_search.dart';
import 'package:pingo_front/data/models/community_model/review_search_result.dart';
import 'package:pingo_front/data/view_models/community_view_model/place_review_search_view_model.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/ui/pages/community_page/components/place_box.dart';
import 'package:pingo_front/ui/pages/community_page/components/place_write_page.dart';
import 'package:pingo_front/ui/widgets/kakao_map_screen.dart';

class PlaceList extends ConsumerStatefulWidget {
  final PlaceReviewSearch searchReviewState;
  final PlaceReviewSearchViewModel searchReviewProvider;
  final Function changePlaceShared;
  final Function _onSearchCleared;
  const PlaceList(this.searchReviewState, this.searchReviewProvider,
      this.changePlaceShared, this._onSearchCleared,
      {super.key});

  @override
  ConsumerState<PlaceList> createState() => _PlaceListState();
}

class _PlaceListState extends ConsumerState<PlaceList> {
  @override
  Widget build(BuildContext buildContext) {
    ReviewSearchResult searchResult =
        widget.searchReviewState.reviewSearchResult;

    List<PlaceReview>? searchList =
        widget.searchReviewState.reviewSearchResult.placeReviewList;

    final userNo = ref.read(sessionProvider).userNo;

    return Column(
      children: [
        // cate
        if (searchList!.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(
                  kakaoCategory.length,
                  (index) {
                    var key = kakaoCategory.keys.toList()[index];
                    var value = kakaoCategory[key];

                    return _placeCateBox(
                        buildContext, key, value, searchResult.cateSort);
                  },
                )
              ],
            ),
          ),
        // sort
        if (searchList.isNotEmpty)
          Row(
            children: [
              _placeSortBtn(
                  buildContext, '인기순', 'popular', searchResult.searchSort),
              _placeSortBtn(
                  buildContext, '최신순', 'newest', searchResult.searchSort),
              _placeSortBtn(
                  buildContext, '거리순', 'location', searchResult.searchSort),
            ],
          ),
        // list
        Expanded(
          child: searchList.isEmpty
              ? ListView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: KakaoMapScreen(
                              widget.searchReviewProvider.lastSearch),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            '${widget.searchReviewProvider.lastSearch.placeName}에 대한 리뷰가 없습니다.',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF906FB7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PlaceWritePage(
                                        widget.searchReviewProvider, userNo!)),
                              );
                              widget._onSearchCleared();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                Text('리뷰 작성',
                                    style: Theme.of(buildContext)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(color: Colors.white)),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchList.length ?? 0,
                  itemBuilder: (context, index) => PlaceBox(
                    key: ValueKey(searchList[index].prNo),
                    searchList[index],
                    widget.changePlaceShared,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _placeCateBox(buildContext, text, icon, cateIndex) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: cateIndex == text ? Color(0xFF906FB7) : Color(0xFF4A4A4A),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: Theme.of(buildContext).textTheme.titleLarge?.copyWith(
                    color: cateIndex == text
                        ? Color(0xFF906FB7)
                        : Color(0xFF4A4A4A),
                  ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await widget.searchReviewProvider.changeCateSort(text);
        setState(() {});
      },
    );
  }

  Widget _placeSortBtn(buildContext, title, index, sortIndex) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 0),
          backgroundColor:
              sortIndex == index ? Color(0xFF906FB7) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () async {
          await widget.searchReviewProvider.changeSearchSort(index);
          setState(() {});
        },
        child: Text(
          title,
          style: Theme.of(buildContext).textTheme.titleMedium?.copyWith(
                color: sortIndex == index ? Colors.white : Colors.black,
              ),
        ),
      ),
    );
  }
}
