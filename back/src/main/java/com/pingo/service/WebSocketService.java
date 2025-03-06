package com.pingo.service;

import com.pingo.dto.MatchNotiDTO;
import com.pingo.dto.chat.ChatRoomDTO;
import com.pingo.entity.chat.ChatRoom;
import com.pingo.entity.match.MatchUser;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;


@Slf4j
@RequiredArgsConstructor
@Service
public class WebSocketService {

    private final SimpMessagingTemplate messagingTemplate;


    public void sendMatchNotification(Map<String, MatchUser> matchUsers, String toUserNo, String fromUserNo, Map<String, ChatRoomDTO> fromUserMap, Map<String, ChatRoomDTO> toUserMap) {
        String destination = "/topic/match/notification/";
        MatchNotiDTO fromUserMapDTO = new MatchNotiDTO(matchUsers, fromUserMap);
        MatchNotiDTO toUserMapDTO = new MatchNotiDTO(matchUsers, toUserMap);
        log.info("전송되어야 하는 FromUser정보 :" + fromUserMapDTO);
        log.info("전송되어야 하는 ToUser정보 :" + toUserMapDTO);





        // 담아서 보낼 정보 DTO
        messagingTemplate.convertAndSend(destination + toUserNo, toUserMapDTO);
        messagingTemplate.convertAndSend(destination + fromUserNo, fromUserMapDTO);

    }
}
