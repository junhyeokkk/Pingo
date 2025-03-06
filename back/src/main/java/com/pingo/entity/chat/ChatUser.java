package com.pingo.entity.chat;

import lombok.*;

import java.util.UUID;

@ToString
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class ChatUser {
    private String CUId;
    private String userNo;
    private String roomId;

    public void insertUserAndRoom(String userNo, String roomId) {
        this.CUId = createCuId();
        this.userNo = userNo;
        this.roomId = roomId;
    }

    public String createCuId() {
        String uuid = UUID.randomUUID().toString();
        return "CU" + uuid.substring(0,8);
    }
}
