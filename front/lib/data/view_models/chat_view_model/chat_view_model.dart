// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pingo_front/_core/utils/logger.dart';
// import 'package:pingo_front/data/models/chat_model/chat_user.dart';
// import 'package:pingo_front/data/repository/chat_repository/chat_repository.dart';
//
// class ChatViewModel extends Notifier<List<Chat>> {
//   final ChatRepository _repository;
//   ChatViewModel(this._repository);
//
//   @override
//   List<Chat> build() {
//     return [];
//   }
//
//   ///////////////////채팅목록//////////////////////
//   //state는 List<Chat> 인 상태!
//   // 메서드 추가
//   Future<List<Chat>> selectChat(String userNo) async {
//     try {
//       final chatting = await _repository.selectRoomId(userNo);
//       if (chatting == []) {
//         logger.e('빈배열이다');
//         return [];
//       }
//       state = chatting;
//       logger.i("List<Chat> : $chatting");
//       return chatting;
//     } catch (e, traceTrack) {
//       state = [];
//       logger.e('Failed to fetch keywords: $e');
//       return [];
//     }
//   }
//
//   //State는 List<Chat>인 상태이다.
//   // chat의 roomId 먼저 비교 한 후에 맞으면 copyWith써서 lastMessage만 변환때림)
//   void updateLastMessage(String roomId, String newMessage) {
//     state = state.map((chat) {
//       if (chat.roomId == roomId) {
//         return chat.copyWith(lastMessage: newMessage);
//       }
//       return chat;
//     }).toList();
//   }
//
//
//   /////////////////////추후 알람처리///////////////////////////
// }
//
// //창고 관리자 생성하기
// final chatProvider = NotifierProvider<ChatViewModel, List<Chat>>(
//   () {
//     return ChatViewModel(ChatRepository());
//   },
// );
