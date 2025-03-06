package com.pingo.dto.chat;

import com.pingo.entity.chat.ChatUser;
import lombok.*;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
@Setter
@Getter
@Slf4j
// Map<String,ChatRoom>을 사용하기 위한 DTO
public class ChatRoomDTO {

    private List<ChatUserDTO> chatUser;
    private List<ChatMsgDTO> message;
    private String lastMessage;

    public void insertChatUser(ChatUserDTO chatUser) {
        this.chatUser.add(chatUser);
    }

    // 모든메세지, 마지막 메세지 저장
    public void saveMessage(List<ChatMsgDTO> messageList) {
        if (messageList == null || messageList.isEmpty()) {
            log.warn("메시지 리스트가 null이거나 비어 있습니다.");
            return;
        }
        String lastMessage = messageList.get(0).getMsgContent();
        this.message.addAll(messageList);
        this.lastMessage = lastMessage;
    }

}
