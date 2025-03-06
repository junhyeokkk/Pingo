import 'dart:io';

import 'package:uuid/uuid.dart';

class ChatMessage {
  String? msgId; //메세지 번호
  final String? roomId; // 채팅방 번호
  final String? userNo; // 보낸사람과 로그인한 사용자가 동일하면 오른쪽에 메세지 띄우기 / 우선 2면 상대방
  String? msgContent; //메세지 내용
  String? fileName; // 파일 이름
  final DateTime? msgTime; // 메세지 보낸 시간
  final String? msgType; // 타입 enum
  final bool? isRead; // 읽음 여부를 나타내는 카운트 추가

  ChatMessage({
    this.msgId,
    this.roomId,
    this.userNo,
    this.msgContent,
    this.fileName,
    this.msgTime,
    this.msgType,
    this.isRead,
  }) {}

  // copyWith
  ChatMessage copyWith({
    String? msgId,
    String? userNo,
    String? roomId,
    String? msgContent,
    String? fileName,
    DateTime? msgTime,
    String? msgType,
    bool? isRead,
  }) {
    return ChatMessage(
        msgId: msgId ?? this.msgId,
        userNo: userNo ?? this.userNo,
        roomId: roomId ?? this.roomId,
        msgContent: msgContent ?? this.msgContent,
        fileName: fileName ?? this.fileName,
        msgTime: msgTime ?? this.msgTime,
        msgType: msgType ?? this.msgType,
        isRead: isRead ?? this.isRead);
  }

  @override
  String toString() {
    return 'Message{msgId: $msgId, roomId: $roomId, userNo: $userNo, msgContent: $msgContent, fileName: $fileName, msgTime: $msgTime, msgType: $msgType, isRead: $isRead}';
  }

  // Json으로 받아온것을 객체로 변환
  ChatMessage.fromJson(Map<String, dynamic> json)
      : msgId = json['msgId'] ?? '정지현 바보',
        roomId = json['roomId'],
        userNo = json['userNo'],
        msgContent = json['msgContent'],
        fileName = json['fileName'],
        msgTime =
            json['msgTime'] != null ? DateTime.parse(json['msgTime']) : null,
        msgType = json['msgType'],
        isRead = json['isRead'] ?? false;
  // Json으로 변환
  Map<String, dynamic> toJson() {
    return {
      'msgId': msgId,
      'roomId': roomId,
      'userNo': userNo,
      'msgContent': msgContent,
      'fileName': fileName,
      'msgTime': msgTime?.toIso8601String(),
      'msgType': msgType ?? '',
      'isRead': isRead,
    };
  }
}

enum MessageType { text, image, sticker }
// 'messageTime': messageTime?.toIso8601String(),
