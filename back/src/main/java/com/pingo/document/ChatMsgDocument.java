package com.pingo.document;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Document(collection = "chatMsg")
@Builder
public class ChatMsgDocument {

    @Id
    private String msgId;

    private String roomId;
    private String userNo;
    private String msgContent;
    private String fileName;
    private boolean isRead;
    private String msgType;
    private LocalDateTime msgTime;
}
