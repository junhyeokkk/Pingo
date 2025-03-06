import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/main_model/Profile.dart';
import 'package:pingo_front/data/models/match_model.dart';
import 'package:pingo_front/data/view_models/main_view_model/main_page_viewmodel.dart';
import 'package:pingo_front/data/view_models/notification_view_model.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/data/view_models/stomp_view_model.dart';
import 'package:pingo_front/ui/pages/chat_page/chat_msg2_page.dart';
import 'package:pingo_front/ui/pages/chat_page/components/chat_msg_body.dart';
import 'package:pingo_front/ui/pages/community_page/community_page.dart';
import 'package:pingo_front/ui/pages/ping_check_page/signal_page.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';
import 'chat_page/chat_room_page.dart';
import 'keyword_page/keyword_page.dart';
import 'main_page/main_page.dart';
import 'user_page/user_page.dart';

// 상단 알림 초기화
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // 기본적으로 메인 페이지로 설정
  // Map<int, AppBar> indexTitle = {
  //   0: mainAppbar(context, ref),
  // };
  String? userNo;
  MatchModel? otherUser;

  @override
  void initState() {
    super.initState();

    // 안드로이드 핸들러 초기화
    _requestNotificationPermission();
    // localNotification 초기화
    _initialization();

    userNo = ref.read(sessionProvider).userNo; // 내아이디

    // STOMP 웹소캣 연결
    // 현재 코드 실행이 끝난 직후에 실행할 비동기 작업을 예약
    // IndexedStack은 한 번 빌드된 위젯을 계속 유지함(아래 페이지 모두 웹소켓 연결된 상태)
    Future.microtask(() {
      final stompViewModel = ref.read(stompViewModelProvider.notifier);
      stompViewModel.stompConnect(); // STOMP 연결
      stompViewModel.notification(userNo!); // 알림 구독
    });
  }

  void changeStackPages(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 키워드로 조회 - 유저 조회 후 페이지 전환 & main state 변경
  void changePageForKeyword(int index, List<Profile> users) async {
    logger.i('새 유저 ${users.length}');

    // ✅ 이미 사용 중인 ViewModel 가져오기 (기존 TickerProvider 유지)
    final viewModel = ref.read(mainPageViewModelProvider.notifier);

    // ✅ 기존 ViewModel 상태 변경 (새 인스턴스 생성하지 않음)
    await viewModel.changeStateForKeyword(users);

    setState(() {
      _selectedIndex = index;
    });
  }

  /**
   * Provider에 this (TickerProvider)를 넘기면서 새 Provider 인스턴스가 생성됨
   * StateNotifierProvider.family<T, P>는 동적인 파라미터(P)에 따라 서로 다른 Provider 인스턴스를 생성합니다.
      즉, A 페이지에서 사용된 mainPageViewModelProvider(this)와 B 페이지에서 사용된 mainPageViewModelProvider(this)가 서로 다른 인스턴스로 간주될 가능성이 있습니다.
      ⚠️ 문제: IndexedStack 내에서 A 페이지와 B 페이지가 같은 mainPageViewModelProvider를 공유하는 게 아니라,
      각각 다른 vsync 값을 전달하여 서로 다른 ViewModel 인스턴스를 참조할 수 있음.

      즉, B에서 ref.read(mainPageViewModelProvider(this).notifier).updateState()를 호출해도,
      A에서 사용 중인 mainPageViewModelProvider(this)는 해당 변경 사항을 감지하지 못할 가능성이 큼.

      family를 사용하면 TickerProvider (this)가 달라질 때마다 새로운 ViewModel 인스턴스가 생성됩니다.
      즉, A 페이지에서 this (TickerProvider)를 넘길 때마다 새로운 ViewModel 인스턴스를 참조하게 됩니다.
      따라서 B 페이지에서 mainPageViewModelProvider(this)를 변경하더라도, A 페이지`에서 다시 접근할 때 새로운 인스턴스를 참조하여 상태 변경이 반영되지 않습니다.

      1. family를 제거하고, TickerProvider 없이 StateNotifierProvider만 사용 -> TickerProvider를 쓰는 이유를 몰라서 안 해봄

      2. ref.invalidate()를 사용하여 강제 새로고침 -> SingleTickerProviderStateMixin인데 인스턴스 여러개되버리는 에러

      3. ref.listen()을 사용하여 상태 변화를 감지 -> SingleTickerProviderStateMixin인데 인스턴스 여러개되버리는 에러
   */

  @override
  Widget build(BuildContext context) {
    Map<String, MatchModel> matchModel =
        ref.watch(notificationViewModelProvider);

    // 내가 아닌 다른 매칭 유저의 정보 조건에 해당하는 첫번째 요소를 가져옴.
    if (matchModel.isNotEmpty) {
      otherUser =
          matchModel.entries.firstWhere((entry) => entry.key != userNo).value;
      logger.i('otherUser가 왜.. $otherUser');
    } else {
      logger.i('안됨');
    }

    logger.i('match모델머임 ? : ${matchModel.toString()}');
    // 레이아웃이 모두 구성된 이후 호출하기
    if (matchModel.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMatchDialog(context, matchModel, otherUser!);
        ref
            .read(notificationViewModelProvider.notifier)
            .emptyNotification(); // 상태 초기화
      });
    }
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            MainPage(),
            SignalPage(changePageForKeyword),
            CommunityPage(),
            ChatRoomPage(),
            UserPage(),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigatorBar(),
    );
  }

  Widget _bottomNavigatorBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        changeStackPages(index);
      },
      items: [
        BottomNavigationBarItem(label: '홈', icon: Icon(Icons.home_filled)),
        BottomNavigationBarItem(label: '키워드', icon: Icon(Icons.electric_bolt)),
        BottomNavigationBarItem(
            label: '커뮤니티', icon: Icon(Icons.connected_tv_outlined)),
        BottomNavigationBarItem(label: '채팅', icon: Icon(Icons.chat)),
        BottomNavigationBarItem(label: '사용자', icon: Icon(Icons.person)),
      ],
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }

  @override
  void dispose() {
    // 앱 꺼지면 웹소캣 해제
    ref.read(stompViewModelProvider.notifier).stompDisconnect();
    super.dispose();
  }

  // 다이얼로그 메서드
  void showMatchDialog(BuildContext context, Map<String, MatchModel> matchModel,
      MatchModel otherUser) {
    showDialog(
      context: context,
      barrierDismissible: false, // 외부 클릭 시 닫히지 않도록 설정
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)), // 둥근 테두리 적용
          backgroundColor: Colors.transparent, // 배경 투명
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 빛나는 효과를 위한 블러 배경
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // 매치 다이얼로그 내용
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade500,
                      Colors.deepPurple.shade300
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 타이틀
                    Text(
                      "It's a Match",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 6,
                                color: Colors.black26)
                          ]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${otherUser.userName ?? ''}님과 매치되었어요!',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 20),

                    // 프로필 이미지 (좌우 배치)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProfileImage(otherUser.imageUrl ?? ''),
                        SizedBox(width: 20),
                        _buildProfileImage(matchModel[userNo]?.imageUrl ?? ''),
                      ],
                    ),
                    SizedBox(height: 20),

                    // 확인 버튼
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        "확인",
                        style: TextStyle(color: Colors.purple, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// 둥근 프로필 이미지 위젯
  Widget _buildProfileImage(String imageUrl) {
    return CircleAvatar(
      radius: 40,
      backgroundImage: CustomImage().provider(imageUrl),
    );
  }

  // 알람권한 핸들러 설정
  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // LocalNotificaion 설정(모든 페이지에서 알람을 받을 수 있도록 설정하는 역할)
  void _initialization() async {
    AndroidInitializationSettings android = const AndroidInitializationSettings(
        "@mipmap/ic_launcher"); //앱의 기본 아이콘 사용
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      // 클릭했을 때 여기로 들어옴
      //onSelectNotification --> 최신버전에선 onDidReceiveNotificationResponse로 변경되었음
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print("✅ 알림 클릭됨");
        logger.i('알람클릭됨');
        if (response.payload != null) {
          Map<String, dynamic> data = jsonDecode(response.payload!);
          print("✅ 알림 클릭됨");
          logger.i('채팅방 클릭했을 때 들어오는 곳');
          logger.i('채팅방이름 : ${data['chatRoomName'].toString()}');

          navigateToChatScreen(data['roomId'], data['chatRoomName'].toString(),
              data['myUserNo']);
        } else {
          logger.i('채팅방 클릭 ');
          print("✅ 알림 클릭 실패");
        }
      },
    );
  }

  void navigateToChatScreen(String roomId, String userNo, String myUserNo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatMsg2Page(
          chatRoomName: userNo,
          roomId: roomId,
          myUserNo: myUserNo,
        ),
      ),
    );
  }
}
