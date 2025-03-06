package com.pingo.dto;

import com.pingo.dto.chat.ChatRoomDTO;
import com.pingo.entity.match.MatchUser;
import lombok.*;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;

@NoArgsConstructor
@AllArgsConstructor
@ToString
@Setter
@Getter
public class MatchNotiDTO {

    private Map<String, MatchUser> matchUsers;
    private Map<String, ChatRoomDTO> chatRoomUsers;

    public void insertMatchUserAndChatRoomDTO(Map<String, MatchUser> matchUsers , Map<String, ChatRoomDTO> chatRoomUsers) {
        this.matchUsers = matchUsers;
        this.chatRoomUsers = chatRoomUsers;

    }
}
