import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/chat_model/chat_msg_model.dart';
import 'package:pingo_front/data/models/chat_model/chat_room.dart';
import 'package:pingo_front/data/models/match_model.dart';
import 'package:pingo_front/data/network/custom_dio.dart';
import 'package:pingo_front/data/repository/chat_repository/chat_repository.dart';
import 'package:pingo_front/data/repository/root_url.dart';
import 'package:pingo_front/data/view_models/chat_view_model/chat_room_view_model.dart';
import 'package:pingo_front/data/view_models/notification_view_model.dart';
import 'package:pingo_front/data/view_models/sign_view_model/signin_view_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class StompViewModel extends Notifier<bool> {
  StompClient? stompClient;
  String? userNo;

  // 웹소캣 값을 bool로 관리하기
  //build를 오버라이드 해줌, state값을 bool로 관리할 예정 / false면 웹소캣 연결 해제
  @override
  bool build() {
    return false;
  }

  // 웹소캣 연결하기 initState일때사용하기
  void stompConnect() async {
    final sessionUser = ref.read(sessionProvider);
    userNo = sessionUser.userNo;

    if (stompClient != null) return;
    String? accessToken = await secureStorage.read(key: 'accessToken');
    // stompclient 콜백메서드를 등록할 수 있는 웹소캣의 객체
    stompClient = StompClient(
      config: StompConfig(
        url: wsRootURL,
        webSocketConnectHeaders: {
          'Authorization': accessToken,
        },
        onConnect: _onConnect, // 연결 성공시 실행할 콜백 함수
        onWebSocketError: (dynamic error) =>
            print('연결안되자너 $error.toString()'), // 웹소캣 자체 오류 감지 , 서버 문제
        onStompError: (dynamic error) =>
            print('잘못된 메세지 형식'), // stomp 프로토콜 오류 감지, 잘못된 메시지 형식
        onDisconnect: (StompFrame frame) => print('연결해지'), // 웹소켓 연결 해제 감지
      ),
    );
    stompClient?.activate(); // 웹소캣 활성화
    state = true;
  }

  //frame은 명령(command)와 추가적인 헤더(Header, 키 벨류 형태)와 추가적인 바디(body: payload, 전송되는 데이터)로 구성된다.

  //맨처음 진입했을 때 메시지 갯수를 받아올 수 있는 콜백 메서드를 추가할 필요가 있지 않을까...?

  // 서버에서 메시지 받아오기 받은 메세지를 저장소(chatRoomProvider에 추가할예정)
  // 서버에서 메시지를 받아올 경로
  // 연결되면 연결완료 logger띄우기
  //StompFrame은 서버에서 보낸 연결 응답을 담고 있는 객체인데 onConnect에서는 무조건 인자로 써줘야함 (안쓰더라도)
  void _onConnect(StompFrame frame) {
    stompClient?.send(
      destination: '/pub/main/$userNo',
    );
    logger.i('웹소냥이 연결완료');
    // receive(userNo!);
  }

  // 서버에서 받기 메세지만!! 받기!!! 다른곳에서 상태관리를 하는게 나을 것 같다.
  // chatMain에서 구독시작..?
  // 1. 채팅방 들어갔을 때 메세지 받기
  //구독이 설정되면, 새로운 메시지가 올 때마다 자동으로 callback() 실행됨
  //서버에서 새로운 메시지가 발생하면, 해당 destination을 구독 중인 모든 클라이언트에게 자동 전송
  //Completer는 단순히 Future를 제어할 수 있도록 돕는 비동기 컨트롤러임. 바로 반환 안됨.
  // 웹소캣이라 메세지가 언제올지 모름 바로 return하면 null로 들어갈 수 있어서 메세지 올때까지 Future를 미리 만들어놓고
  // 메세지가 들어오면 completer.complete(message)로 완료시키고 그다음에 future<Message>리턴때리기

  // 비효율적이라 수정 --> return을 하지않고 그대로 message를 필요한 viewModel의 메서드로 전달시켰다.
  // 메세지 받기
  void receive(String roomId) {
    // final Completer<Message> completer = Completer<Message>();
    stompClient?.subscribe(
      destination: '/topic/msg/$roomId',
      callback: (StompFrame frame) {
        final Map<String, dynamic> jsonData = jsonDecode(frame.body!);
        ChatMessage message = ChatMessage.fromJson(jsonData);
        final roomId = message.roomId;
        logger.i('receive로 메세지 받음 $message');
        // 채팅방 목록 뷰모델을 구독하고 바로 필요한 정보만 전달해버리기!! 로 수정!!!
        // 채팅방 메세지 받는 페이지가 아니면!

        // 1. 마지막메세지 업데이트 + List<Message> 업데이트
        ref.read(chatProvider.notifier).updateLastMessage(
            roomId!,
            message.msgType == 'image'
                ? '이미지'
                : message.msgType == 'file'
                    ? '파일'
                    : message.msgContent ?? '');
        ref.read(chatProvider.notifier).addMessage(message, roomId);

        // completer.complete(message);
        // _addMessage(message);
      },
    );
    // return completer.future;
  }

  // 로그인한 사용자에게 알림
  void notification(String userNo) {
    logger.i('여기까지');
    // 알림받기
    stompClient?.subscribe(
      destination: '/topic/match/notification/$userNo',
      // 메세지가 수신될때 frame으로 수신되어서 매개변수로 받음
      callback: (StompFrame frame) {
        logger.i("웹소켓 들");
        // 받아온 정보를 dart Map 객체로 변환
        final Map<String, dynamic> jsonData = jsonDecode(frame.body!);
        logger.i("jsondata $jsonData");
        final Map<String, dynamic> matchUsersJson = jsonData['matchUsers'];
        final Map<String, dynamic> chatRoomUsersJson =
            jsonData['chatRoomUsers'];

        // 새로운 맵 형태로 변환
        final Map<String, MatchModel> matchUserMap = matchUsersJson.map(
          (key, value) => MapEntry(
            key,
            MatchModel.fromJson(value as Map<String, dynamic>),
          ),
        );
        logger.i('매칭성공 후 matchUserMap의 값은? $matchUserMap');

        final Map<String, ChatRoom> chatRoomUserMap = chatRoomUsersJson.map(
          (key, value) => MapEntry(
            key,
            ChatRoom.fromJson(value as Map<String, dynamic>),
          ),
        );

        ref
            .read(notificationViewModelProvider.notifier)
            .matchNotification(matchUserMap);

        ref.read(chatProvider.notifier).updateChatRoomState(chatRoomUserMap);
      },
    );
  }

  // 서버로 채팅 메시지 보내기/ 메세지 보낼 경로, 보내는 메세지 내용
  void sendMessage(ChatMessage message, String roomId, File? chatFile,
      String? fileName) async {
    ChatRepository chatRepository = ChatRepository();
    String? msgContent = message.msgContent;

    // // 이미지일 때 먼저 서버에 업로드 후 그 값을 가져와서 /pub/msg/$roomId 주소로 보내야 한다.
    if (message.msgType == 'image' || message.msgType == 'file') {
      String? uploadUrl = await chatRepository.uploadImageToServer(
          message.roomId!, chatFile!, fileName);
      if (uploadUrl != null) {
        message.msgContent = uploadUrl;
      }
    }
    final messages = jsonEncode(message.toJson());
    stompClient?.send(
      destination: '/pub/msg/$roomId',
      body: messages, // 수정 예정 객체 -> JSON 문자열 변환
    );
    logger.i('머나와 $messages.toString()');
  }

  // 연결 해제 하는 메서드 depose일때
  void stompDisconnect() {
    stompClient?.deactivate();
    stompClient = null;
    state = false;
  }

  // void _addMessage(Message message) {
  //   final messageNotifier = ref.read(chatProvider.notifier);
  //   messageNotifier.addMessage(message);
  //   logger.i(messageNotifier);
  // }
}

// 창고 관리자 + 관리할 창고 설정
final stompViewModelProvider = NotifierProvider<StompViewModel, bool>(
  () {
    return StompViewModel();
  },
);
