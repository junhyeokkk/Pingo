package com.pingo.service.swipeService.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pingo.dto.swipe.SwipeRequest;
import com.pingo.entity.swipe.Swipe;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import com.pingo.mapper.SwipeMapper;
import com.pingo.service.swipeService.MatchService;
import com.pingo.util.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
@RequiredArgsConstructor
public class SwipeConsumerService {

    private final SwipeMapper swipeMapper;
    private final ObjectMapper objectMapper;
    private final MatchService matchService;

    @KafkaListener(topics = KafkaTopics.SWIPE_EVENTS, concurrency = "3")
    @Transactional // ✅ Kafka 메시지 처리가 DB 트랜잭션과 함께 진행되도록 보장
    public void consumeSwipeEvent(ConsumerRecord<String, String> record, Acknowledgment ack) {
        log.info("Kafka 리스너 실행됨 - Partition: {}, Offset: {}", record.partition(), record.offset());

        SwipeRequest swipeRequest = null;

        try {
            swipeRequest = objectMapper.readValue(record.value(), SwipeRequest.class);

            if (swipeRequest == null || swipeRequest.getFromUserNo() == null ||
                    swipeRequest.getToUserNo() == null || swipeRequest.getSwipeType() == null) {
                log.error("[오류] Kafka 메시지 데이터 이상: {}", record.value());
                ack.acknowledge(); // ✅ 데이터가 이상하면 즉시 Offset을 커밋하여 재처리 방지
                return;
            }

            final SwipeRequest finalSwipeRequest = swipeRequest;
            final String fromUserNo = finalSwipeRequest.getFromUserNo();
            final String toUserNo = finalSwipeRequest.getToUserNo();
            final String swipeType = finalSwipeRequest.getSwipeType();

            // ✅ 비동기 작업을 하나의 CompletableFuture로 묶기
            CompletableFuture<Void> processingFuture = CompletableFuture.runAsync(() -> {
                Swipe swipe = new Swipe(finalSwipeRequest);
                log.info("[DEBUG] swipe 테이블 INSERT 실행 시작: {}", swipe.toString());
                swipeMapper.insertUserSwipe(swipe);
                log.info("[DEBUG] swipe 테이블 INSERT 실행 완료: {} -> {}, type: {}", fromUserNo, toUserNo, swipeType);
            });

            if (!"PANG".equalsIgnoreCase(swipeType)) {
                CompletableFuture<Boolean> checkMatchFuture = CompletableFuture.supplyAsync(() -> {
                    boolean result = swipeMapper.isSwipeMatched(fromUserNo, toUserNo);
                    log.info("[DEBUG] 매칭 여부 확인 결과: {} <-> {} => {}", fromUserNo, toUserNo, result);
                    return result;
                });

                processingFuture = processingFuture.thenCombine(checkMatchFuture, (voidResult, isMatched) -> {
                    if (isMatched) {
                        log.info("매칭 성공! {} <-> {}", fromUserNo, toUserNo);
                        matchService.processMatch(fromUserNo, toUserNo);
                    } else {
                        log.info("매칭 실패! {} <-> {}", fromUserNo, toUserNo);
                    }
                    return null;
                });
            }

            // ✅ 모든 작업이 끝난 후 Offset을 확실히 커밋
            processingFuture.whenComplete((result, ex) -> {
                if (ex != null) {
                    log.error("[스와이프 처리 중 오류 발생] {}", ex.getMessage(), ex);
                }
                ack.acknowledge(); // ✅ Kafka Offset을 확실히 커밋하여 중복 처리 방지
            });

        } catch (Exception e) {
            log.error("[스와이프 저장 오류] fromUserNo: {}, toUserNo: {}, 오류: {}",
                    swipeRequest != null ? swipeRequest.getFromUserNo() : "null",
                    swipeRequest != null ? swipeRequest.getToUserNo() : "null",
                    e.getMessage(), e);
            ack.acknowledge(); // ✅ 예외 발생 시에도 Kafka Offset을 커밋하여 무한 재처리 방지
            throw new BusinessException(ExceptionCode.SWIPE_SAVE_FAILED);
        }
    }


}