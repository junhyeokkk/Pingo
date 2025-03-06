import 'package:flutter/material.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/chat_model/chat_room.dart';
import 'package:pingo_front/data/view_models/chat_view_model/chat_room_view_model.dart';
import 'package:pingo_front/ui/pages/chat_page/components/chat_msg_body.dart';

class ChatMsg2Page extends StatefulWidget {
  final String chatRoomName;
  final String roomId;
  final String myUserNo;

  const ChatMsg2Page({
    required this.chatRoomName,
    required this.roomId,
    required this.myUserNo,
    super.key,
  });

  @override
  State<ChatMsg2Page> createState() => _ChatMsg2PageState();
}

class _ChatMsg2PageState extends State<ChatMsg2Page> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeSettings = ModalRoute.of(context)?.settings;
    logger.i('📍 ChatMsg2Page 감지됨: ${routeSettings?.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(widget.chatRoomName),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ChatMsgBody(
            roomId: widget.roomId,
            myUserNo: widget.myUserNo,
          ),
        ),
      ),
    );
  }
}
