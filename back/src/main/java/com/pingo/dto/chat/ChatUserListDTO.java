package com.pingo.dto.chat;

import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
@Setter
@Getter

// 프론트에서 웹소켓 연결을 위해 UserNo를 보냈었는데 그것을 처리하기 위한 DTO였음
public class ChatUserListDTO {
    private String userNo;
    private String roomId;
}
