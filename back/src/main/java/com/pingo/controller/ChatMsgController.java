package com.pingo.controller;


import com.pingo.dto.ResponseDTO;
import com.pingo.dto.chat.ChatMsgDTO;
import com.pingo.service.ImageService;
import com.pingo.service.chatService.ChatMsgService;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Value;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.List;
import java.util.UUID;

@Slf4j
@RequiredArgsConstructor
@Controller
public class ChatMsgController {

    private final ChatMsgService chatMsgService;
    private final ImageService imageService;

    //해당 채팅방의 메세지 전체 조회
    @GetMapping("/select/message")
    public ResponseEntity<?> selectMessage(@RequestParam String roomId){
        log.info("룸아이디는?:"+roomId);
        List<ChatMsgDTO> chatMsgDTOS = chatMsgService.selectMessage(roomId);
        log.info("해당갑승ㄴ? : " + chatMsgDTOS);
        return ResponseEntity.ok().body(ResponseDTO.of("1", "성공", chatMsgDTOS));

    }

    // 스크롤시 그보다 위의 채팅 메세지 일부 조회(만약 로컬디비 사용시 해당 부분 필요없음)
    @GetMapping("/select/oldMessage")
    public ResponseEntity<?> selectOldMessage(@RequestParam String msgId, @RequestParam String roomId) {
        log.info("룸아이디와 MSGID는?:"+roomId,msgId);
        List<ChatMsgDTO> chatMsgDTOS = chatMsgService.selectOldMessage(msgId,roomId);
        log.info("과거채팅목록조회 : " + chatMsgDTOS);
        return ResponseEntity.ok().body(ResponseDTO.of("1","성공", chatMsgDTOS));
    }


    // 받은 메세지에서 이미지파일 서버에 저장하기
    // fromData는 RequestParam or RequestPart로 받는다.
    @PostMapping("/chat/save/chatFile")
    public ResponseEntity<?> saveImage(@RequestPart("roomId") String roomId,
                            @RequestPart("chatFile") MultipartFile chatFile) {
        log.info("roomId : " + roomId);
        log.info("chatFile : " + chatFile.getOriginalFilename());

        String chatFileName = "CI_" + UUID.randomUUID().toString();
        String chatFilePath = "chatFiles" + File.separator + chatFileName;
        String fileUrl = imageService.imageUpload(chatFile,chatFilePath,chatFileName);
        log.info("이거 주소 머임 ? : "+ fileUrl);
        return ResponseEntity.ok().body(ResponseDTO.of("1","성공", fileUrl));
    }
}
