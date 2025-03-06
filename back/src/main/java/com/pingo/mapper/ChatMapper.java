package com.pingo.mapper;

import com.pingo.dto.chat.ChatUserDTO;
import com.pingo.dto.chat.ChatUserListDTO;
import com.pingo.entity.chat.ChatRoom;
import com.pingo.entity.chat.ChatUser;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ChatMapper {
    List<ChatUserDTO> selectChatUser(String userNo);

    List<ChatUserListDTO> selectChatUserList(String userNo);

    void insertChatRoom(ChatRoom chatRoom);

    void insertChatUser(ChatUser chatUser);


}
