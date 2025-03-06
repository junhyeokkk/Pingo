import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/community_model/place_review.dart';
import 'package:pingo_front/data/view_models/community_view_model/place_review_search_view_model.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';

class PlaceBox extends ConsumerStatefulWidget {
  final PlaceReview placeReview;
  final Function changePlaceShared;

  const PlaceBox(this.placeReview, this.changePlaceShared, {super.key});
  @override
  ConsumerState<PlaceBox> createState() => _PlaceBoxState();
}

class _PlaceBoxState extends ConsumerState<PlaceBox> {
  bool isExpanded = false; // 크기 조절용
  bool showText = false; // 텍스트 표시 여부

  void _toggleExpanded() {
    if (isExpanded) {
      // 축소할 때는 동시에 처리
      setState(() {
        showText = false;
        isExpanded = false;
      });
    } else {
      // 확장할 때는 크기 변경 후 텍스트 표시
      setState(() {
        isExpanded = true;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          showText = true;
        });
      });
    }
  }

  void _clickPlaceReviewHeart() async {
    String? userNo = ref.read(sessionProvider).userNo;
    String result = await ref
        .read(placeReviewSearchViewModelProvider.notifier)
        .clickThumbUp(userNo!, widget.placeReview.prNo!);
    if (result == 'increase') {
      ref
          .read(placeReviewSearchViewModelProvider)
          .reviewSearchResult
          .changeHeart(widget.placeReview.prNo!, 1);
    } else {
      ref
          .read(placeReviewSearchViewModelProvider)
          .reviewSearchResult
          .changeHeart(widget.placeReview.prNo!, -1);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400), // 크기 변경 애니메이션 지속 시간
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 8.0),
        width: totalWidth * 0.9,
        height: isExpanded
            ? totalWidth * 0.9 / 16 * 11
            : totalWidth * 0.9 / 16 * 7, // 확장/축소 높이
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CustomImage().provider(widget.placeReview.thumb!),
            fit: BoxFit.cover,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 아이콘
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    _clickPlaceReviewHeart();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.heart_fill,
                            size: 20, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.placeReview.heart}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.changePlaceShared(true, widget.placeReview);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.ios_share_outlined,
                        size: 20, color: Colors.white),
                  ),
                )
              ],
            ),
            // 하단 정보 (애니메이션 적용)
            Container(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, // 아래쪽이 진하게
                  end: Alignment.topCenter, // 위쪽이 투명하게
                  colors: [
                    Colors.black.withOpacity(0.8), // 아래쪽 (진한 검은색)
                    Colors.black.withOpacity(0.6), // 중간 (반투명)
                    Colors.black.withOpacity(0.0), // 위쪽 (완전 투명)
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.placeReview.placeName!,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    widget.placeReview.addressName!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  // ✅ 크기 변경 후 텍스트가 나타나도록 수정
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut, // 부드러운 이동
                    opacity: showText ? 1.0 : 0.0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic, // 자연스럽게 멈추는 애니메이션
                      transform: Matrix4.translationValues(
                          0, showText ? 0 : 10, 0), // Y축 이동
                      child: Visibility(
                        visible: showText,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              "🏷 ${widget.placeReview.userNick}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              "💬 ${widget.placeReview.contents}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
