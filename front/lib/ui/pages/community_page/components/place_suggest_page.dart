import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/data/models/chat_model/chat_msg_model.dart';
import 'package:pingo_front/data/models/chat_model/chat_room.dart';
import 'package:pingo_front/data/models/chat_model/chat_user.dart';
import 'package:pingo_front/data/models/community_model/place_review.dart';
import 'package:pingo_front/data/view_models/chat_view_model/chat_room_view_model.dart';
import 'package:pingo_front/data/view_models/community_view_model/place_review_search_view_model.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/data/view_models/stomp_view_model.dart';
import 'package:pingo_front/ui/pages/community_page/components/place_list.dart';
import 'package:pingo_front/ui/pages/community_page/components/place_search.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';

class PlaceSuggestPage extends ConsumerStatefulWidget {
  const PlaceSuggestPage({super.key});

  @override
  ConsumerState<PlaceSuggestPage> createState() => _PlaceSuggestPageState();
}

class _PlaceSuggestPageState extends ConsumerState<PlaceSuggestPage>
    with AutomaticKeepAliveClientMixin<PlaceSuggestPage> {
  int _placeIndex = 0;
  late String userNo;
  // 장소 검색
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  // 공유하기
  bool isShared = false;
  PlaceReview? sharedPlace;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 입력 감지 함수 (1초 동안 입력이 없으면 실행)
  void _onSearchChanged() async {
    _debounceTimer?.cancel(); // 기존 타이머 취소

    _debounceTimer = Timer(Duration(seconds: 1), () {
      String query = _searchController.text.trim();

      if (query.isNotEmpty) {
        print("자동 검색 실행: $query");

        ref
            .read(placeReviewSearchViewModelProvider.notifier)
            .kakaoPlaceSearchApi(query, 1)
            .then((_) {
          setState(() {
            _placeIndex = 1;
          });
        });
      } else {
        _onSearchCleared();
      }
    });
  }

  // 검색창이 비었을 때 실행할 함수
  void _onSearchCleared() {
    _placeIndex = 0;
    FocusScope.of(context).unfocus();
    setState(() {});
    ref
        .read(placeReviewSearchViewModelProvider.notifier)
        .searchLastPlaceReview();
  }

  // place suggest 내의 index 변경 함수
  void changePlaceIndex(int newIndex) {
    if (newIndex < 0 || newIndex >= 2) return;
    setState(() {
      _placeIndex = newIndex;
    });
  }

  // place shared 변경 함수
  void changePlaceShared(bool changeShared, PlaceReview placeReview) {
    setState(() {
      isShared = changeShared;
      sharedPlace = placeReview;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext buildContext) {
    final searchReviewState = ref.watch(placeReviewSearchViewModelProvider);
    final searchReviewProvider =
        ref.read(placeReviewSearchViewModelProvider.notifier);
    final chatUserMap = ref.watch(chatProvider);
    userNo = ref.watch(sessionProvider).userNo!;

    super.build(buildContext);
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // search
                  _placeSearchBox(),
                  Expanded(
                    child: IndexedStack(
                      index: _placeIndex,
                      children: [
                        PlaceList(searchReviewState, searchReviewProvider,
                            changePlaceShared, _onSearchCleared),
                        PlaceSearch(searchReviewState, searchReviewProvider,
                            _onSearchCleared),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: isShared,
              child: Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, -1),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isShared = false;
                              });
                            },
                            icon: Icon(Icons.close),
                          ),
                          Text(
                            '공유하기 [${sharedPlace?.placeName ?? ''}]',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 82,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: chatUserMap.length,
                          itemBuilder: (context, index) {
                            final entry = chatUserMap.entries.elementAt(index);
                            final String roomId = entry.key;
                            final ChatRoom chatRoom = entry.value;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: _placeShareUser(roomId, chatRoom),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _placeShareUser(String roomId, ChatRoom chatRoom) {
    List<ChatUser> chatUsers = chatRoom.chatUser;

    final ChatUser otherUser = chatUsers.firstWhere(
      (each) => each.userNo != userNo,
    );

    return InkWell(
      onTap: () {
        ChatMessage message = ChatMessage(
          isRead: false,
          msgContent: '${sharedPlace?.thumb}',
          fileName: '${sharedPlace?.placeName}@#${sharedPlace?.addressName}',
          msgTime: DateTime.now(),
          msgType: 'place',
          roomId: roomId,
          userNo: userNo,
        );

        final stompViewModel = ref.read(stompViewModelProvider.notifier);
        stompViewModel.sendMessage(message, roomId, null, null);
        isShared = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('장소가 공유되었습니다.'),
            duration: Duration(seconds: 2), // 스낵바 표시 시간
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                image: CustomImage().provider(otherUser.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            otherUser.userName ?? '',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _placeSearchBox() {
    return TextField(
      controller: _searchController,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: "장소 검색",
        hintStyle: TextStyle(color: Color(0xFF4A4A4A)),
        prefixIcon: Icon(Icons.search, color: Color(0xFF4A4A4A), size: 24),
        filled: true,
        fillColor: Color(0xFFE0E0E0),
        contentPadding: const EdgeInsets.symmetric(vertical: 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: const BorderSide(color: Colors.black12, width: 0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: const BorderSide(color: Colors.black12, width: 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: const BorderSide(color: Colors.black12, width: 0),
        ),
      ),
    );
  }
}
