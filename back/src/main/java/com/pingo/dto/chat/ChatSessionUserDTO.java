package com.pingo.dto.chat;

import lombok.*;

@ToString
@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter

// 웹소켓 핸들러에서 사용하기 위함이었으나 STOMP로 변경처리
public class ChatSessionUserDTO {
    private String userId;
    private String sessionId;
}
