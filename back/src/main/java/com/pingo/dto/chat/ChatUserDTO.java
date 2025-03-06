package com.pingo.dto.chat;


import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
@Setter
@Getter

// Map<String,ChatRoom>의 List<ChatUser>에 사용하기 위한 DTO
public class ChatUserDTO {

    private String userNo;
    private String roomId;
    private String imageUrl;
    private String userName;

}
