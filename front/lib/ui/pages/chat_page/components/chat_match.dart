// chat_match.dart
import 'package:flutter/material.dart';
import 'package:pingo_front/data/models/chat_model/chat_room.dart';
import 'package:pingo_front/data/models/chat_model/chat_user.dart';
import 'package:pingo_front/ui/pages/chat_page/chat_msg2_page.dart';
import 'package:pingo_front/ui/widgets/custom_image.dart';

class ChatMatch extends StatelessWidget {
  // final List<Chat> chatList;
  final Map<String, ChatRoom> chatList;
  final String myUserNo;
  final String searchQuery;
  // Constructor
  const ChatMatch(
      {required this.myUserNo,
      required this.chatList,
      required this.searchQuery,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              '새 매치',
              style: TextStyle(
                fontSize: 12, // 크기 수정해야됨
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: chatList.isEmpty
                ? Center(
                    child: Text(
                      '매칭된 상대가 없습니다.',
                      style: TextStyle(fontSize: 15),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: (() {
                        final filteredChatList = chatList.entries
                            .where((each) =>
                                searchQuery.isEmpty ||
                                each.value.chatUser.any((user) =>
                                    user.userNo != null &&
                                    user.userName!
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase())))
                            .toList();

                        return filteredChatList.isNotEmpty
                            ? filteredChatList
                                .map((each) => _newMatchChatItem(
                                    chatList[each.key]!, context))
                                .toList()
                            : [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      '검색된 사용자가 없습니다',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ];
                      })(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _newMatchChatItem(ChatRoom chatRoom, context) {
    ChatUser otherUser = chatRoom.chatUser[0]; ///// 나중에 수정

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatMsg2Page(
                chatRoomName: otherUser.userName ?? '',
                roomId: otherUser.roomId,
                // chatRoom: chatList[otherUser.roomId]!,
                myUserNo: myUserNo),
            settings: RouteSettings(name: 'chat_msg_body'),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CustomImage().token(otherUser.imageUrl!),
                  ),
                ),
                if (true) ///// 나중에 수정
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      child: Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 15,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              otherUser.userName!,
              style: TextStyle(
                fontWeight: FontWeight.w500, // 사이즈수정
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
