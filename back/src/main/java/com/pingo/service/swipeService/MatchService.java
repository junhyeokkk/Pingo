package com.pingo.service.swipeService;

import com.pingo.dto.ResponseDTO;
import com.pingo.dto.chat.ChatRoomDTO;
import com.pingo.dto.chat.ChatUserDTO;
import com.pingo.entity.chat.ChatRoom;
import com.pingo.entity.chat.ChatUser;
import com.pingo.entity.match.MatchMapperEntity;
import com.pingo.entity.match.MatchUser;
import com.pingo.entity.match.Matching;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.mapper.ChatMapper;
import com.pingo.mapper.MatchMapper;
import com.pingo.mapper.MatchingMapper;
import com.pingo.mapper.UserMapper;
import com.pingo.service.WebSocketService;
import com.pingo.service.chatService.ChatRoomService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;

@RequiredArgsConstructor
@Slf4j
@Service
public class MatchService {
    private final MatchingMapper matchingMapper;
    private final MatchMapper matchMapper;
    private final ChatRoomService chatRoomService;
    private final UserMapper userMapper;
    private final WebSocketService webSocketService;
    private final ChatMapper chatMapper;

    // 매칭이 성공되면 실행
    // 1. 매칭테이블 데이터 삽입
    // 2. 매칭매퍼 테이블 데이터 삽입
    // 3. 매칭된 상대방 데이터 조회 (이름, 사진, 나이) + 채팅방 생성 (비동기 병렬 처리)
    // 4. 웹소켓 연결
    @Transactional
    public void processMatch(String fromUserNo, String toUserNo) {
        try {
            // 1) 매칭 객체 생성 및 저장
            Matching matching = new Matching(fromUserNo, toUserNo);

            matchingMapper.insertMatching(matching);
            log.info("매칭 저장 완료: {} <-> {}", fromUserNo, toUserNo);

            // 2) 매칭 매퍼 테이블에도 삽입 (양방향 저장)
            MatchMapperEntity matchA = new MatchMapperEntity(fromUserNo, toUserNo, matching.getMatchNo());
            MatchMapperEntity matchB = new MatchMapperEntity(toUserNo, fromUserNo, matching.getMatchNo());

            matchMapper.insertMatchMapper(matchA);
            matchMapper.insertMatchMapper(matchB);

            log.info("매칭 매퍼 저장 완료: {} <-> {}", fromUserNo, toUserNo);

            // 3) 상대방 정보 조회 + 채팅방 생성 (비동기 병렬 처리)
            CompletableFuture<Map<String,MatchUser>> fetchOpponentInfoFuture = CompletableFuture.supplyAsync(() -> {
                Map<String,MatchUser> matchusers = new HashMap<>();

                matchusers.put(toUserNo, userMapper.getMatchUser(toUserNo));
                matchusers.put(fromUserNo, userMapper.getMatchUser(fromUserNo));

                return matchusers;
            });

            List<String> userNoList = new ArrayList<>();
            userNoList.add(fromUserNo);
            userNoList.add(toUserNo);



            // 빈 Map 생성해
            Map<String, ChatRoomDTO> chatRoomMap = new HashMap<>();

            Map<String, ChatRoomDTO> fromUserChatRooms = new HashMap<>();
            Map<String, ChatRoomDTO> toUserChatRooms = new HashMap<>();

            CompletableFuture<Void> createChatRoomFuture = CompletableFuture.runAsync(() -> {

                // 채팅방 생성
                chatRoomService.createChatRoomAndUser(userNoList);

                // 그 아이디로 포문 돌려서 chatUSerListDTO 찾기 (내 방이랑 상대방 프로필 등등)

                    List<ChatUserDTO> chatUserDTOS = chatMapper.selectChatUser(userNoList.get(0));

                for(ChatUserDTO chatUserDTO : chatUserDTOS) {
                    // 채팅방 존재 여부 확인
                    String roomId = chatUserDTO.getRoomId();

                    if (chatRoomMap.containsKey(roomId)) {
                        // 이미 방이 존재하면
                        chatRoomMap.get(roomId).insertChatUser(chatUserDTO);
                    } else {
                        // 방이 없으면
                        // ChatRoomDTO 초기화 시키기
                        ChatRoomDTO chatRoomDTO = new ChatRoomDTO(new ArrayList<>(), new ArrayList<>(), null);            // chatUser추가하기
                        chatRoomDTO.insertChatUser(chatUserDTO);
                        chatRoomMap.put(roomId, chatRoomDTO);
                    }

                    // user : 나와 상대방
                    // 내이름으로 찾은 여러ro의 키의 ChatUSerDTO

                    // 그걸 하나의 List로 만들어서
//                    for(ChatUserDTO chatUserDTO : chatUserDTOs) {
//                        log.info("asdfasdf : " + chatUserDTO);
//
//                        // 방아이디를 뺀다(키로 쓸)
//                        String roomId = chatUserDTO.getRoomId();
//
//                        chatRoomMap.computeIfAbsent(roomId, key -> {
//                            ChatRoomDTO chatRoomDTO = new ChatRoomDTO(new ArrayList<>(), new ArrayList<>(), null);
//                            chatRoomDTO.insertChatUser(chatUserDTO);
//                            log.info("chatRoomDTO의 값 : "+ chatRoomDTO);
//                            return chatRoomDTO;
//                        });
//

//                        // 기존 방이 없으면 새로운 방을 추가
//                        ChatRoomDTO chatRoomDTO = chatRoomMap.putIfAbsent(roomId, new ChatRoomDTO(new ArrayList<>(), new ArrayList<>(), null));
                    // 기존 방이 없었던 경우, 방을 가져와서 사용자 추가
//                        if (chatRoomDTO == null) {
//                            chatRoomDTO = chatRoomMap.get(roomId); // 새로 추가된 방 가져오기
//                            chatRoomDTO.insertChatUser(chatUserDTO);
//                        }


////                        // 방 아이디가 있으면 거기에 추가시키고
//                        if(chatRoomMap.containsKey(roomId)) {
//                            chatRoomMap.get(roomId).insertChatUser(chatUserDTO); // 여기수정
//                        }else {
                    // 방 아이디가 없으면 roomDTO를 한번 초기화시키고 그 곳에 chatUserDTO를 넣는다 (새매치이기 때문에 메세지가 없어서 따로 insert하지않음)
//                            ChatRoomDTO chatRoomDTO = new ChatRoomDTO(new ArrayList<>(), new ArrayList<>(), null);
//                            chatRoomDTO.insertChatUser(chatUserDTO);
//                            chatRoomMap.putIfAbsent(roomId, chatRoomDTO);

//                        }

//                    }

                    // 각각의 toUser, fromUSer mapping
                    for (Map.Entry<String, ChatRoomDTO> entry : chatRoomMap.entrySet()) {
                        List<ChatUserDTO> chatUsers = entry.getValue().getChatUser();

                        for (ChatUserDTO oneUser : chatUsers) {
                            if (oneUser.getUserNo().equals(fromUserNo)) {
                                fromUserChatRooms.put(entry.getKey(), entry.getValue());
                            } else if (oneUser.getUserNo().equals(toUserNo)) {
                                toUserChatRooms.put(entry.getKey(), entry.getValue());
                            }
                        }
                    }
                }});



            // 4) 두 작업이 완료되면 웹소켓을 통해 알림 전송
            fetchOpponentInfoFuture.thenCombine(createChatRoomFuture, (opponentProfile, chatRoomId) -> {
                // fetchOpponentInfoFuture의 결과값을 join()으로 가져옴
                Map<String, MatchUser> opponentInfo = fetchOpponentInfoFuture.join();

                webSocketService.sendMatchNotification(opponentInfo, toUserNo, fromUserNo, fromUserChatRooms, toUserChatRooms);
                log.info(" 웹소켓 알림 전송 완료: {} <-> {}", fromUserNo, toUserNo);
                return null;
            }).exceptionally(ex -> {
                log.error("[웹소켓 전송 중 오류 발생] {}", ex.getMessage(), ex);
                return null;
            });

        } catch (Exception e) {
            log.error("[매칭 처리 중 오류 발생] fromUserNo: {}, toUserNo: {}, 오류: {}",
                    fromUserNo, toUserNo, e.getMessage(), e);
            throw new BusinessException(ExceptionCode.MATCHING_FAILED);
        }
    }
}
