package com.pingo.service.swipeService;

import com.pingo.dto.ResponseDTO;
import com.pingo.dto.TransferDtoToEntity;
import com.pingo.dto.profile.CheckPingProfileResponseDTO;
import com.pingo.dto.swipe.SwipeRequest;
import com.pingo.entity.swipe.Swipe;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.mapper.SwipeMapper;
import com.pingo.service.swipeService.kafka.SwipeProducerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
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
public class SwipeService {

    private final SwipeMapper swipeMapper;
    private final SwipeProducerService swipeProducerService;

    // 스와이프 저장
    public ResponseEntity<?> saveSwipe(SwipeRequest swipeRequest) {
        // 1차 예외 처리 (매개변수 값 검증)
        if (swipeRequest == null) {
            log.error("[오류] 스와이프 요청 데이터 없음.");
            throw new BusinessException(ExceptionCode.INVALID_SWIPE_REQUEST);
        }

        if (swipeRequest.getFromUserNo() == null || swipeRequest.getFromUserNo().trim().isEmpty()) {
            log.error("[오류] 발신자 사용자 번호 없음.");
            throw new BusinessException(ExceptionCode.MISSING_USER_NO);
        }

        if (swipeRequest.getToUserNo() == null || swipeRequest.getToUserNo().trim().isEmpty()) {
            log.error("[오류] 수신자 사용자 번호 없음.");
            throw new BusinessException(ExceptionCode.MISSING_TARGET_USER_NO);
        }

        if (swipeRequest.getSwipeType() == null || swipeRequest.getSwipeType().trim().isEmpty()) {
            log.error("[오류] 스와이프 타입 없음.");
            throw new BusinessException(ExceptionCode.MISSING_SWIPE_TYPE);
        }

        // 매개변수 검증을 이렇게 하나로 합칠지 리팩토링 디벨롭 (ㅇ)
//        if (swipeRequest == null ||
//                swipeRequest.getFromUserNo() == null || swipeRequest.getFromUserNo().trim().isEmpty() ||
//                swipeRequest.getToUserNo() == null || swipeRequest.getToUserNo().trim().isEmpty() ||
//                swipeRequest.getSwipeType() == null || swipeRequest.getSwipeType().trim().isEmpty()) {
//
//            log.error("🚨 [오류] 잘못된 스와이프 요청: {}", swipeRequest);
//            throw new BusinessException(ExceptionCode.INVALID_SWIPE_REQUEST);
//        }

        // Kafka 이벤트 전송
        swipeProducerService.sendSwipeEvent(
                swipeRequest.getFromUserNo(),
                swipeRequest.getToUserNo(),
                swipeRequest.getSwipeType()
        );

        //

        // 성공 응답 반환
        return ResponseEntity.ok().body(ResponseDTO.of("1", "스와이프가 저장되었습니다.", true));
    }

    // 나를 SuperPing, Ping 한 사람들 조회
    public ResponseEntity<?> selectSuperPingOrPingByMe(String userNo) {

        List<CheckPingProfileResponseDTO> checkPingProfileResponseDTO = swipeMapper.selectPingorSuperpingbyme(userNo);

        // SwipeType을 key값으로 프론트에 보내줄 Map 생성
        Map<String, List<Map<String, Object>>> swipeMap = new HashMap<>();

        for(CheckPingProfileResponseDTO c : checkPingProfileResponseDTO) {
            c.calculateAge(c.getUserBirth());
            c.getImagesAsList();
            log.info(c.toString());

            Map<String, Object> userMap = new HashMap<>();
            userMap.put("userNo", c.getUserNo());
            userMap.put("userName", c.getUserName());
            userMap.put("age", c.getAge());
            userMap.put("imageUrl", c.getImageUrl());
            userMap.put("ImageList", c.getImageList());

            // swipeType을 키로 사용하여 리스트에 추가
            swipeMap.computeIfAbsent(c.getSwipeType(), k -> new ArrayList<>()).add(userMap);
        }

        log.info("맵으로 변환된 데이터" + swipeMap);

        // 성공 응답 반환
        return ResponseEntity.ok().body(ResponseDTO.of("1", "스와이프가 저장되었습니다.", swipeMap));
    }

}
