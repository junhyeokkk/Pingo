package com.pingo.controller;

import com.pingo.dto.chat.ChatMsgDTO;
import com.pingo.repository.ChatMsgRepository;
import com.pingo.service.chatService.ChatMsgService;
import com.pingo.service.chatService.ChatRoomService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Slf4j
@RequiredArgsConstructor
@Controller
public class ChatWebSocketController {

    // 서버에서 클라이언트로 메세지를 전송하기 위해서
    private final SimpMessagingTemplate messagingTemplate;
    private final ChatMsgService chatMsgService;
    // private final ChatRoomService chatRoomService;


// DestinationVariable 메시징의 경우 파라미터값을 받아오기 위해 사용
// STOMP에서는 requestBody X -> Payload 로 사용해야 함
// 파라미터의값을 받아온 것을 SendTo("/sub/{chatNo})로 사용할 수 없음 // SendTo는 정적인 값만 지원하기 때문에 {chatNo}와 같은 동적인 값을 지원하지 않음
// 그래서 messagingTemplate를 쓰는것이 낫다.

    // 채팅 주고 받는 메서드
    @MessageMapping("/msg/{roomId}") // pub 클라이언트 -> 서버로 메시지 전송 / WebsocketConfig prefixes에서 pub 적용한 것 삭제
    public void chatMessage(@DestinationVariable String roomId, @Payload ChatMsgDTO messageResponseDTO) {
        log.info("Chat Message: " + messageResponseDTO);

        ChatMsgDTO dto = chatMsgService.insertMessage(messageResponseDTO);
        log.info("asdf :" + dto);
        messagingTemplate.convertAndSend("/topic/msg/" + roomId, dto);
        //DB에 메세지 저장하기

    }
//
//    @MessageMapping("/main/{userNo}")
//    public void checkUser(@DestinationVariable String userNo) {
//        // Map<String, List<String>> chatUserList 맵 채우기
//        // userNo로 roomId 조회하고 roomId에 들어있는 user정보를 Map<String,List<String>>에 저장하기
//        Map<String,List<String>> MapUser = chatRoomService.selectChatRoomUser(userNo);
//        for(String roomId : MapUser.keySet()){
//            List<String> users = MapUser.get(roomId);
//            chatUserList.put(roomId, users);
//        }
//        log.info("chatUserList:챗유저리스트: " + chatUserList);
//        // map에서 포문 더ㅗㄹ려서 하나씩 ㅣㅈ벙넣기
//
//    }

}

