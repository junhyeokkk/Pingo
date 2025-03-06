package com.pingo.service.chatService;

import com.pingo.dto.ResponseDTO;
import com.pingo.dto.chat.*;
import com.pingo.entity.chat.ChatRoom;
import com.pingo.entity.chat.ChatUser;
import com.pingo.entity.chat.Test;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.mapper.ChatMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Service
public class ChatRoomService {

    private final ChatMapper chatMapper;
    private final ChatMsgService chatMsgService;

    // chatRoom 조회 (채팅방 목록, 메세지, 마지막메세지)
    public ResponseEntity<?> selectChatRoom(String userNo) {

        Test aa = new Test("홍", 20);

        // 유효성 검사 예외처리
        try {
            List<ChatUserDTO> chatUserDTOS = chatMapper.selectChatUser(userNo);
            log.info("값이없나요?" + chatUserDTOS);
            if(chatUserDTOS.isEmpty()) {
                throw new BusinessException(ExceptionCode.MATCHING_FAILED);
            }
            // 결과를 저장할 맵 (채팅방별로 데이터를 구성 : String이 roomId가 되어야한다.) // 비어있는 맵 생성
            Map<String, ChatRoomDTO> chatRoomMap = new HashMap<>();

            // 하나의 List를 추출
            for(ChatUserDTO chatUserDTO : chatUserDTOS) {
                // 채팅방 존재 여부 확인
                String roomId = chatUserDTO.getRoomId();
                log.info("여기 roomId는 있나요? : " + roomId);

                if (chatRoomMap.containsKey(roomId)) {
                    // 이미 방이 존재하면
                    chatRoomMap.get(roomId).insertChatUser(chatUserDTO);
                    log.info("이방은 있나요? : " + chatRoomMap);
                }else {
                    // 방이 없으면
                    // ChatRoomDTO 초기화 시키기
                    ChatRoomDTO chatRoomDTO = new ChatRoomDTO(new ArrayList<>(), new ArrayList<>(), null);            // chatUser추가하기
                    chatRoomDTO.insertChatUser(chatUserDTO);
                    log.info("그럼 이 DTO는 있나요? : " + chatRoomDTO);

                    // 해당 방에 해당되는 메세지들 조회하기
                    List<ChatMsgDTO> msgDTO = chatMsgService.selectMessage(roomId);
                    // 모든메세지, 마지막 메세지 저장
                    log.info("여기까지 값은 들어오나요 ? : " + msgDTO);
                    chatRoomDTO.saveMessage(msgDTO);

                    chatRoomMap.put(roomId, chatRoomDTO);
                    log.info("어디서 에러가 나나요? : " + chatRoomMap);
                }
            }
            return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", chatRoomMap));
        }catch (Exception e) {
            log.error(e.getMessage());
            throw new BusinessException(ExceptionCode.NOT_FOUND_CHAT_ROOM);
        }
    }

    // 채팅방 만들기
    @Transactional
    public void createChatRoomAndUser(List<String> userNoList) {
        ChatRoom chatRoom = new ChatRoom();
        chatRoom.createRoomId();

        chatMapper.insertChatRoom(chatRoom);

        for(String user : userNoList) {
            ChatUser chatUser = new ChatUser();
            chatUser.insertUserAndRoom(user, chatRoom.getRoomId());
            chatMapper.insertChatUser(chatUser);
        }
    }
// 죽은코드임 제거해야함
//    // 채팅방 user조회
//    public Map<String,List<String>> selectChatRoomUser(String userNo) {
//        List<ChatUserListDTO> chatUserListDTOS = chatMapper.selectChatUserList(userNo);
//        Map<String, List<String>> roomUserMap = new HashMap<>();
//        for(ChatUserListDTO chatUser : chatUserListDTOS) {
//            roomUserMap.computeIfAbsent(chatUser.getRoomId(), k -> new ArrayList<>()).add(chatUser.getUserNo());
//        }
//
//        return roomUserMap;
//    }

//    // 채팅방 생성
//    public ResponseEntity<?> insertChatRoom(List<String> userNoList){
//        boolean result = createChatRoomAndUser(userNoList);
//        return ResponseEntity.ok().body("채팅방 생성");
//    }
}
