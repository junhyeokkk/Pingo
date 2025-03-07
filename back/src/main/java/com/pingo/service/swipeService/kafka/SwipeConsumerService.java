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
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Properties;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
@RequiredArgsConstructor
public class SwipeConsumerService {

    private final SwipeMapper swipeMapper;
    private final ObjectMapper objectMapper;
    private final MatchService matchService;
    private final KafkaProducer<String, String> kafkaProducer; // DLQ 메시지 전송을 위한 KafkaProducer

    @KafkaListener(topics = KafkaTopics.SWIPE_EVENTS, concurrency = "3")
    @Transactional
    public void consumeSwipeEvent(ConsumerRecord<String, String> record, Acknowledgment ack) {
        log.info("Kafka 리스너 실행됨 - Partition: {}, Offset: {}", record.partition(), record.offset());

        SwipeRequest swipeRequest;
        try {
            swipeRequest = objectMapper.readValue(record.value(), SwipeRequest.class);

            if (swipeRequest == null || swipeRequest.getFromUserNo() == null ||
                swipeRequest.getToUserNo() == null || swipeRequest.getSwipeType() == null) {
                log.error("[오류] Kafka 메시지 데이터 이상: {}", record.value());
                ack.acknowledge();
                return;
            }

            final SwipeRequest finalSwipeRequest = swipeRequest;
            final String fromUserNo = finalSwipeRequest.getFromUserNo();
            final String toUserNo = finalSwipeRequest.getToUserNo();
            final String swipeType = finalSwipeRequest.getSwipeType();

            CompletableFuture<Void> processingFuture = CompletableFuture.runAsync(() -> {
                try {
                    Swipe swipe = new Swipe(finalSwipeRequest);
                    log.info("[DEBUG] swipe 테이블 INSERT 실행 시작: {}", swipe);
                    swipeMapper.insertUserSwipe(swipe);
                    log.info("[DEBUG] swipe 테이블 INSERT 실행 완료: {} -> {}, type: {}", fromUserNo, toUserNo, swipeType);
                } catch (Exception e) {
                    log.error("[DB 저장 오류] fromUserNo: {}, toUserNo: {}, 오류: {}", fromUserNo, toUserNo, e.getMessage(), e);
                    throw new BusinessException(ExceptionCode.SWIPE_SAVE_FAILED);
                }
            });

            if (!"PANG".equalsIgnoreCase(swipeType)) {
                CompletableFuture<Boolean> checkMatchFuture = CompletableFuture.supplyAsync(() -> {
                    try {
                        boolean result = swipeMapper.isSwipeMatched(fromUserNo, toUserNo);
                        log.info("[DEBUG] 매칭 여부 확인 결과: {} <-> {} => {}", fromUserNo, toUserNo, result);
                        return result;
                    } catch (Exception e) {
                        log.error("[매칭 확인 오류] fromUserNo: {}, toUserNo: {}, 오류: {}", fromUserNo, toUserNo, e.getMessage(), e);
                        throw new BusinessException(ExceptionCode.MATCH_CHECK_FAILED);
                    }
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

            processingFuture.whenComplete((result, ex) -> {
                if (ex != null) {
                    log.error("[스와이프 처리 중 오류 발생] {}", ex.getMessage(), ex);
                    handleFailedMessage(record); // DLQ로 메시지 이동
                } else {
                    ack.acknowledge(); // 정상 처리 후 Offset 커밋
                }
            });

        } catch (Exception e) {
            log.error("[스와이프 저장 오류] 메시지 파싱 실패: {}", record.value(), e);
            handleFailedMessage(record); // DLQ로 메시지 이동
        }
    }

    /**
     * 장애 발생 시 메시지를 DLQ로 이동
     */
    private void handleFailedMessage(ConsumerRecord<String, String> record) {
        log.error("[DLQ 이동] 장애 발생으로 메시지를 DLQ로 보냄: {}", record.value());
        kafkaProducer.send(new ProducerRecord<>(KafkaTopics.SWIPE_EVENTS_DLQ, record.key(), record.value()));
    }

}
