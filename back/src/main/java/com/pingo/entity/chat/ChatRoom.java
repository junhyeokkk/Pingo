package com.pingo.entity.chat;

import lombok.*;

import java.util.ArrayList;
import java.util.UUID;

@ToString
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class ChatRoom {

    private String roomId;
    private String roomStatus;

    public void createRoomId(){
        String uuid = UUID.randomUUID().toString();
        this.roomId = "CR" + uuid.substring(0, 8);
        this.roomStatus = "ACTIVE";
    }

}
