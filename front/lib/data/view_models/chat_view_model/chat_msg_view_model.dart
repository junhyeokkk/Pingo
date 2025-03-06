// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pingo_front/_core/utils/logger.dart';
// import 'package:pingo_front/data/models/chat_model/chat_msg_model.dart';
// import 'package:pingo_front/data/network/custom_dio.dart';
// import 'package:pingo_front/data/repository/chat_repository/chat_repository.dart';
//
// class chatMsgViewModel extends Notifier<List<Message>> {
//   final ChatRepository _repository;
//   chatMsgViewModel(this._repository);
//
//   @override
//   List<Message> build() {
//     return [];
//   }
//
//   void addMessage(Message message) {
//     state = [...state, message];
//   }
//
//   Future<List<Message>> selectMessage(String roomId) async {
//     final message = await _repository.selectMessage(roomId);
//     if (message == []) {
//       logger.i('빈배열임당');
//       return [];
//     }
//     state = message;
//     return message;
//   }
//
// //메서드 추가 예정
// }
//
// //창고 관리자 생성하기
// final chatMsgProvider = NotifierProvider<chatMsgViewModel, List<Message>>(
//   () {
//     return chatMsgViewModel(ChatRepository());
//   },
// );
