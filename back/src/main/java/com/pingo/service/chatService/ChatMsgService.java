package com.pingo.service.chatService;

import com.pingo.document.ChatMsgDocument;
import com.pingo.dto.chat.ChatMsgDTO;
import com.pingo.repository.ChatMsgRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
@Service
public class ChatMsgService {

    private final ChatMsgRepository chatMsgRepository;

    Pageable pageable = PageRequest.of(0, 100);

    // 전체 메세지 조회 ( --> 끝에서 100개정도 가져오는 걸로 수정해야함)
    public List<ChatMsgDTO> selectMessage(String roomId){
        List<ChatMsgDTO> chatMsgDTO = chatMsgRepository.findByRoomId(roomId,pageable);
        log.info("너의 값은? : " + chatMsgDTO);

        return chatMsgDTO;
    }

    // 스크롤시 100개 정도의 oldMessage 조회(로컬 디비 저장시 해당 메서드 필요없음)
    public List<ChatMsgDTO> selectOldMessage(String msgId, String roomId){
        List<ChatMsgDTO> chatMsgDTO2 = chatMsgRepository.findByMsgId(roomId, msgId, pageable);

        return chatMsgDTO2;
    }

    // 메세지 삽입
    public ChatMsgDTO insertMessage(ChatMsgDTO chatMsgDTO){
        ChatMsgDocument chatMsgDsgDocument = ChatMsgDocument.builder()
                .roomId(chatMsgDTO.getRoomId())
                .msgContent(chatMsgDTO.getMsgContent())
                .fileName(chatMsgDTO.getFileName())
                .msgTime(chatMsgDTO.getMsgTime())
                .isRead(chatMsgDTO.isRead())
                .userNo(chatMsgDTO.getUserNo())
                .msgType(chatMsgDTO.getMsgType())
                .build();
        ChatMsgDocument savedDocument = chatMsgRepository.save(chatMsgDsgDocument);
        log.info("챗저장 값 : " +savedDocument);
        chatMsgDTO.setMsgId(savedDocument.getMsgId());
        return chatMsgDTO;

    }

}
