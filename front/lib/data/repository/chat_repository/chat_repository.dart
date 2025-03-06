import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:pingo_front/_core/utils/logger.dart';
import 'package:pingo_front/data/models/chat_model/chat_user.dart';
import 'package:pingo_front/data/models/chat_model/chat_msg_model.dart';
import 'package:pingo_front/data/models/chat_model/chat_room.dart';
import 'package:pingo_front/data/network/custom_dio.dart';

class ChatRepository {
  final CustomDio _customDio = CustomDio.instance;

  //채팅방 목록 조회
  Future<Map<String, ChatRoom>> selectRoomId(String userNo) async {
    final Map<String, dynamic> response =
        await _customDio.get('/select/chatRoom', query: {'userNo': userNo});
    logger.i('response: $response');

    // "romm1" : {List<User>, Null, lastMsg}

    // json -> Map<String, ChatRoom>

    // List<ChatRoom> -> 원하는 채팅방을 찾을때 전부다 돌아봐야함
    // Map<String, ChatRoom> -> String 값만 알면 빠르게 원하는 채팅방 찾기 가능

    Map<String, ChatRoom> result = {};

    // Map<String,dynamic> 데이터를 Map<String,ChatRoom>으로 변환해야 한다. response의 각 요소를 순회하면서 ChatRoom객체로 변환해야함
    response.forEach((key, value) =>
        result[key] = ChatRoom.fromJson(value as Map<String, dynamic>));

    logger.i(result);

    return result;
  }

  //채팅방 메세지 조회
  Future<List<ChatMessage>> selectMessage(String roomId) async {
    final response =
        await _customDio.get('/select/message', query: {'roomId': roomId});
    logger.i('messageReponse : $response');

    return List<Map<String, dynamic>>.from(response)
        .map((json) => ChatMessage.fromJson(json))
        .toList();
  }

  // 오래된 메세지 조회하기
  Future<List<ChatMessage>> selectOldMessage(
      String msgId, String roomId) async {
    final response = await _customDio
        .get('/select/oldMessage', query: {'msgId': msgId, 'roomId': roomId});
    logger.i('oldMessageResponse : $response');

    // 백에서 sort X -> reverse 처리
    return List<Map<String, dynamic>>.from(response)
        .map((json) => ChatMessage.fromJson(json))
        .toList()
        .reversed
        .toList();
  }

  //서버에 이미지 전송 후 서버에 저장된 이미지의 주소를 String -> messageContent에 저장
  Future<String?> uploadImageToServer(
      String roomId, File image, String? fileName) async {
    //MultipartFile을 생성하여 multipart/form-data로 변환
    //MultipartFile --> 파일을 multipart/form-data 형식으로 변환할 수 있게 도와줌 즉 파일 데이터를
    // HTTP 요청에 맞는 형식으로 변환하는 역할을 한다.
    // 서버가 파일을 JSON 객체로 해석하려고 하기 때문에 multipart/form-data로 전송해야 함

    // 1. 현재 File 객체의 확장자 추출
    String? mimeType = lookupMimeType(image.path) ?? 'image/jpeg';

    // 2. FromData 변환 (Multipart/form-data)
    FormData formData = FormData.fromMap({
      "roomId": MultipartFile.fromString(
        jsonEncode(roomId),
        contentType: DioMediaType("application", "json"),
      ),
      "chatFile": await MultipartFile.fromFile(
        image.path,
        filename: fileName ?? '',
        contentType: DioMediaType.parse(mimeType),
      ),
    });

    // 3. 서버에 요청 보내기
    final response =
        await _customDio.post('/chat/save/chatFile', data: formData);

    // 4. 서버에 업로드된 이미지의 Url 반환(주소 String값)
    logger.i('반환된 이미지 주소 : $response');

    return response;
  }
}
