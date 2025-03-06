import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/_core/utils/navigator_observer.dart';
import 'package:pingo_front/data/models/chat_model/chat_room.dart';
import 'package:pingo_front/data/models/chat_model/chat_user.dart';
import 'package:pingo_front/data/models/chat_model/chat_msg_model.dart';
import 'package:pingo_front/data/models/setting_model/AppSettings.dart';
import 'package:pingo_front/data/view_models/chat_view_model/chat_room_view_model.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:pingo_front/data/view_models/stomp_view_model.dart';
import 'package:pingo_front/ui/pages/main_screen.dart';
import 'package:pingo_front/ui/pages/observer_page.dart';
import 'package:pingo_front/ui/widgets/appbar/chat_appbar.dart';

import 'components/chat_match.dart';
import 'components/chat_room_list.dart';
import 'components/chat_search_header.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({super.key});

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatRoomPage> {
  late observerPage _lifecycleObserver;
  late String? myUserNo;
  late String? msgId = '';
  late Map<String, String> chatAlarms;
  late String? msgContent;

  String searchQuery = '';

  void _updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  // initState는 비동기를 직접 사용할 수 없음.
  @override
  void initState() {
    super.initState();

    final sessionUser = ref.read(sessionProvider);
    myUserNo = sessionUser.userNo;

    // 여기서 chat 뷰모델의 초기 데이터 조회하는 로직 수행 (userNo)
    // 여기에서 모든 정보 다 받아오기 (페이징처리 필요)
    Future<void> _fetchChatList() async {
      final chatProviders = ref.read(chatProvider.notifier);

      Map<String, ChatRoom> chatList =
          await chatProviders.selectChatRoom(myUserNo ?? '사용자없음');

      //키 RoomId를 가져온다.
      List<String> roomIds = chatList.keys.toList();
      final websocketProvider = ref.read(stompViewModelProvider.notifier);

      //키를 전달한다.
      //각각의 키로 웹소캣을 구독하고 receive 호출만 하면 stompview모델에서 알아서 view모델의 메서드로 message를 전달한다.
      for (var roomId in roomIds) {
        websocketProvider.receive(roomId);
      }
    }

    _fetchChatList();
  }

  // chatList는 Map<String,ChatRoom>의 형태를 지닌다.
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider(myUserNo!));
    final chatList = ref.watch(chatProvider); // 상태를 한번 읽어오기
    logger.i('room process......0 - 시작');

    // 리스트, 매치로 구별하기 위한 빈 함수
    Map<String, ChatRoom> listChat = {};
    Map<String, ChatRoom> matchChat = {};

    //키 별로 반복(맵을 우선 펼쳐서)
    for (var entry in chatList.entries) {
      logger.i('room process......1 - for문 시작');

      String roomKey = entry.key;
      ChatRoom chatRoom = entry.value;

      // 파싱처리 (내가 아닌 사용자 정보)
      List<ChatUser> filterUsers =
          chatRoom.chatUser.where((user) => user.userNo != myUserNo).toList();
      logger.i('chat room process......2 - 파싱처리');

      // 채팅리스트로 보낼지, 매치로 보낼지 결정
      if (chatRoom.lastMessage != '') {
        listChat[roomKey] = ChatRoom(
            chatUser: filterUsers,
            message: chatRoom.message,
            lastMessage: chatRoom.lastMessage);
      } else {
        matchChat[roomKey] = ChatRoom(
            chatUser: filterUsers,
            message: chatRoom.message,
            lastMessage: chatRoom.lastMessage);
      }

      // 메세지가 비어있으면 로직 중지
      if (chatRoom.message.isEmpty) {
        logger.i('chat room process...... - 메세지가 비었음');
        continue;
      }

      // 마지막 메세지 정보 추출
      ChatMessage? lastMessage = chatRoom.message.last;

      // 내가 보낸건지 확인 내가 보낸거면 로직 끝
      if (lastMessage.userNo == myUserNo) {
        logger.i('chat room process...... - 라스트 메세지가 내가 보낸거임');
        continue;
      }

      // 위젯이 화면에 그려진 뒤에 실행 됨
      // WidgetsBinding.instance.addPostFrameCallback(
      //   (_) {
      final alarm = ref.read(settingsProvider(myUserNo!));
      logger.i(alarm);

      chatAlarms = alarm.chatAlarms;
      //   },
      // );

      if (chatAlarms[roomKey] == lastMessage.msgId) {
        logger.i('chat room process...... - 이미 보낸 메세지 알림임');
        continue;
      }

      //내가 보내지 않은 메세지이고 null이 아니라면
      if (lastMessage.msgContent != null) {
        // sharePreference read 하기 (UI 다 실행된 다음에 콜백 함수 호출)
        logger.i('chat room process...... - 4 내가 안보냈는데 null도 아님');

        // 첫번째 String = key(roomId), 두번째 String = value(msgId)

        // 상대방 유저이름
        String userName = filterUsers.map((e) => e.userName).join(', ');
        logger.i('이 유저이름 : $userName');

        // 알림 전송
        showNotification(
            lastMessage.msgContent ?? '', roomKey, myUserNo!, userName);

        logger.i(chatAlarms[lastMessage.roomId!]);
        logger.i(lastMessage.msgId!);

        //UI 다시 그리기 (상태)
        setState(() {
          chatAlarms[lastMessage.roomId!] = lastMessage.msgId!;
        });

        // 디비 저장 // 위젯트리가 완전히 빌드된 다음에 상태를 변경하는 것 , 위젯이 완전히 그려진 후에 실행될 필요가 없으니까
        Future.microtask(() {
          ref
              .read(settingsProvider(myUserNo!).notifier)
              .updateSettings(settings.copyWith(chatAlarms: chatAlarms));
        });

        // --> 어플 재로딩시 다시 알람이 호출 됨 // 로컬DB에 알람기록을 저장해서 비교해서 띄워야 함
        logger.i('chat room process...... - 5 for문 끝');
      }
    }

    return Scaffold(
      appBar: chatAppbar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ChatSearchHeader(
                chatList: chatList, onSearchChanged: _updateSearchQuery),
            const SizedBox(height: 8),
            ChatMatch(
              chatList: matchChat,
              myUserNo: myUserNo!,
              searchQuery: searchQuery,
            ),
            const SizedBox(height: 8),
            ChatRoomList(listChat, myUserNo!, searchQuery),
          ],
        ),
      ),
    );
  }

  // 알람 띄우는 메서드
  Future<void> showNotification(String messageContent, String roomKey,
      String myUserNo, String userName) async {
    logger.i('showNotification process......1 - 시작');
    logger.i(
        'messageContent : $messageContent | roomKey : $roomKey | myUserNo : $myUserNo | userName : $userName');

    // if 조건문 걸어서 내 메세지면 return 시켜 버림
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'chat_channel_id', // 채널 ID
      '채팅 알림', // 채널 이름
      importance: Importance.high,
      priority: Priority.high,
    );
    logger.i('showNotification process......2 - 내 메세지 거르기 후');

    // WidgetsBindingObserver ---> 앱이 백그라운지 포그라운드인지 확인 가능
    // "백그라운드에서 받은 알림"을 앱 진입 시 무시하도록 처리(시간 기준으로)

    // 앱이 포그라운드일 때 → 상단 배너(Snackbar) 표시
    // 앱이 백그라운드일 때 → 푸시 알림 표시

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    logger.i('showNotification process......3 -');

    // 매개변수로 받은 데이터를 객체로 변환시키기
    String payloadData = jsonEncode({
      'roomId': roomKey,
      'chatRoomName': userName,
      'myUserNo': myUserNo,
    });

    logger.i('showNotification process......4 -');

    // 특정 페이지 (chat_msg_body)에서는 알람을 띄우지 않도록 설정
    if (routeObserver.currentRoute != 'chat_msg_body') {
      await flutterLocalNotificationsPlugin.show(
        roomKey.hashCode.abs(), // 알림 ID 정수형 Id로 변환
        '새 메세지 도착', // 알림 제목
        messageContent, // 메시지 내용
        details,
        payload: payloadData, // Json으로 변환해서 전달 가능
      );
      logger.i('showNotification process......5 - 끝');
    }
  }
}
//리스트 뷰 자동으로 가로,세로 설정 됨
// // 내가 보낸게 아닌 메세지
// List<ChatMessage> filterMessages =
//     chatRoom.message.where((msg) => msg.userNo != myUserNo).toList();
// logger.i('chat room process......3 - 내가 안보낸 메세지 필터링 후');
//
// // 남이 보낸 메세지 중 마지막 메세지
// String? finalMessage = filterMessages
//     .firstWhere((e) => e.msgContent == chatRoom.lastMessage,
//         orElse: () =>
//             ChatMessage(userNo: null, msgContent: null) // 기본값 반환
//         )
//     .msgContent;
// logger.i('chat room process......4 - 남이 보낸 메세지 중 마지막');

// chatList의 List<ChatRoom> 안에 userNo가 아닌 ChatRoom List를 들고오기

// fromEntiries : 필터링 된 데이터를 다시 Map 형태로 변환
// entires 펼쳐서 키, 벨류로 펼침
// final matchChat = Map.fromEntries(
//   chatList.entries.where((e) => (e.value.lastMessage == '')),
// );
// // final listChat = Map.fromEntries(
// //   chatList.entries.where((e) => (e.value.lastMessage != '')),
// // );

// DB에서 chatList를 먼저 불러온다 (몽고도 사용해서 마지막메세지를 가져옴)
// 그 후 웹소캣을 구독해서 새로운 메세지가 온다면
// chatList로 받기
// ChatMessageList의 마지막메세지 내용을 웹소캣으로 변경처리 해주기
// ChatMessageList의 내용을 바꿔주기..

//  옵저버 생성 및 상태 변경 감지
// _lifecycleObserver = observerPage(
//   onStateChanged: (state) {
//     if (state == AppLifecycleState.resumed) {
//       logger.i('이곳은 ? $state');
//       // showNotification(finalMessage, roomKey, myUserNo!, userName);
//       print(" 앱이 다시 활성화됨!");
//     } else if (state == AppLifecycleState.paused) {
//       logger.i('이곳은 ? $state');
//       print("⏸ 앱이 백그라운드로 이동함.");
//       return;
//     }
//   },
// );
