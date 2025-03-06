import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/chat_model/chat_msg_model.dart';
import 'package:pingo_front/data/models/chat_model/chat_room.dart';
import 'package:pingo_front/data/repository/chat_repository/chat_repository.dart';

// 채팅목록과 메세지를 하나의 뷰에서 관리하기
class ChatRoomViewModel extends Notifier<Map<String, ChatRoom>> {
  final ChatRepository _repository;

  ChatRoomViewModel(this._repository);

  @override
  Map<String, ChatRoom> build() {
    return {};
  }

  /// 채팅방 ///
  // [1] 채팅 목록 가져오기 - 시작할 때
  // 수정 - 모델에 fromJson 만들기 / repositroy 점검하고 / 서버에서 Map<String, ChatRoom> 형태로 반환하기
  Future<Map<String, ChatRoom>> selectChatRoom(String userNo) async {
    try {
      final Map<String, ChatRoom> chatRoomMap =
          await _repository.selectRoomId(userNo);
      if (chatRoomMap.isEmpty) {
        logger.e('빈배열이다');
        return {};
      }
      state = chatRoomMap;
      logger.i("chatRoomMap : $chatRoomMap");
      return chatRoomMap;
    } catch (e, traceTrack) {
      state = {};
      logger.e('Failed to fetch keywords: $e');
      return {};
    }
  }

  // [2] 채팅 목록 추가하기 - 새로운 매칭이 생기면 추가해주기
  // - 매칭 성공해서 새로운 채팅방 생기면 Map에 put하기
  void updateChatRoomState(Map<String, ChatRoom> chatRoom) {
    chatRoom.forEach(
      (key, value) {
        state.putIfAbsent(key, () => value);
      },
    );
  }

  // [3] 매칭 취소 (나아아중에)

  // [4] 마지막 메세지 상태 저장
  void updateLastMessage(String roomId, String newMessage) {
    state[roomId]?.lastMessage = newMessage;
    logger.i('여긴? ');

    // state = state.map((chat) {
    //   if (chat.roomId == roomId) {
    //     return chat.copyWith(lastMessage: newMessage);
    //   }
    //   return chat;
    // }).toList();
  }

  /// 메세지 ///
  // [1] 메세지 조회 - 채팅방을 클릭할 때
  Future<void> selectMessage(String roomId) async {
    List<ChatMessage> messages = await _repository.selectMessage(roomId);
    logger.i("메세지 리벌스 : $messages");
    if (messages == []) {
      logger.i('빈배열임당');
    } else {
      state[roomId]?.createNewMessage(messages);
    }
    logger.i('여기머라나오노 $state.toString()');
  }

  // 웹소캣에서 받아온 메세지 추가
  void addMessage(ChatMessage messageList, String roomId) {
    final chatRoom = state[roomId]!;
    logger.i('이곳은?1 : $chatRoom');

    final updatedMessage = [...chatRoom.message, messageList];

    // ✅ 상태가 바뀔 때만 업데이트
    if (!listEquals(chatRoom.message, updatedMessage)) {
      state = {...state, roomId: chatRoom.copyWith(message: updatedMessage)};
    }

    // final updateChatRoom = chatRoom.copyWith(message: updatedMessage);
    // logger.i('state $state');
    //
    // state = {...state, roomId: updateChatRoom};

    // final updatedMessages = [...?chatUser.message, messageList];
    // final updateChatUser = chatUser.message.copyWith
    // state[roomId]?.addNewMessage(messageList);

    // 캡슐화로 ChatRoom 객체의 값을 외부에서 직접 접근, 수정하지 못하게 하기
    // 그래서 ChatRoom 내부에 값을 변경하는 메서드를 만들고 호출하기
    // state == Map<String, ChatRoom>
    // state['값'] == ChatRoom
    // state['값']?.message.addAll(messageList);
  }

  // 채팅방 무한스크롤(이전 채팅목록 가져오기)
  Future<bool> loadOlderMessages(String roomId) async {
    bool check = true;
    if (check == false) {
      logger.i('불러올 메세지가 없음');
      return false;
    }

    // 1. state에서 가장 오래된 아이디를 가지고 서버로 요청
    String? lastMessageId = state[roomId]?.message.first.msgId;
    logger.i('해당 state에 가장 마지막 메세지 $lastMessageId');

    List<ChatMessage> oldChatMessageList =
        await _repository.selectOldMessage(lastMessageId!, roomId);
    logger.i('oldChatMessageList : $oldChatMessageList');

    final updateOldMessage = [...oldChatMessageList, ...state[roomId]!.message];

    // 비어있으면 더이상 요청할 데이터가 없음 false 반환 예정
    if (oldChatMessageList.isEmpty || oldChatMessageList == null) {
      check = false;
      return false;
      // 데이터가 있으면 state에 저장 , true 반환 예정
    } else {
      state = {
        ...state,
        roomId: state[roomId]!.copyWith(message: updateOldMessage)
      };
      logger.i('오래된 채팅메세지의 state : $state');
      check = true;
      return true;
    }
  }
}

//창고 관리자 생성하기
final chatProvider = NotifierProvider<ChatRoomViewModel, Map<String, ChatRoom>>(
  () {
    return ChatRoomViewModel(ChatRepository());
  },
);
