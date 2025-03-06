package com.pingo.dto.chat;

import lombok.*;

import java.time.LocalDateTime;

@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
@Setter
@Getter

// 메세지 DTO
public class ChatMsgDTO {
    private String msgId;
    private String roomId;
    private String userNo;
    private String msgContent;
    private String fileName;
    private boolean isRead;
    private String msgType;
    private LocalDateTime msgTime;

}
