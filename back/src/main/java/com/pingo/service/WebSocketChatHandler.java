


package com.pingo.service;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.pingo.dto.chat.ChatSessionUserDTO;
import com.pingo.dto.chat.ChatUserDTO;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class WebSocketChatHandler extends TextWebSocketHandler {

    // 연결하기
    // 메세지 보내기
    // 연결 끊기 ( 연결을 끊으면 세션 소멸)

    Map<String, List<ChatSessionUserDTO>> chatRooms = new ConcurrentHashMap<>();

    // JSON 변환을 위한 ObjectMapper
    private final ObjectMapper objectMapper = new ObjectMapper();

    // 웹소캣 연결시 방 아이디와 userId,이름을 보낼예정
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String sessionId = session.getId();
        String roomId = getRoomId(session);
        String userId = getUserId(session);

        ChatSessionUserDTO chatUserDTO = new ChatSessionUserDTO(userId, sessionId);

        // 키가 존재할 경우 value 변경없이 존재하는 key의 값을 리턴하고
        // 키가 존재하지 않는 경우에는 람다식을 적용한 값을 해당 key에 저장하고 newvalue를 리턴한다.(null일수도 있고 아닐수도 있고)
        chatRooms.computeIfAbsent(roomId, k -> new ArrayList<>()).add(chatUserDTO);
        System.out.println("WebSocket 연결 성공: " + session.getId());
        System.out.println("방입장 : userNo :" + userId);
        session.sendMessage(new TextMessage("Welcome!"));
    }


    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        System.out.println("수신한 메시지: " + message.getPayload());
        session.sendMessage(new TextMessage("Echo: " + message.getPayload()));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        System.out.println("WebSocket 연결 종료: " + session.getId());
    }


    // URI에서 roomId를 추출
    private String getRoomId(WebSocketSession session) {
        String path = session.getUri().getPath();
        return path.split("/")[3];
    }

    // URI에서 userId를 추출
    private String getUserId(WebSocketSession session) {
        String path = session.getUri().getPath();
        return path.split("/")[4];
    }
}