package com.pingo.service.swipeService.kafka;

import com.pingo.util.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.Value;
import lombok.extern.slf4j.Slf4j;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class SwipeProducerService {

    private final KafkaTemplate<String, String> kafkaTemplate;

    public void sendSwipeEvent(String fromUserNo, String toUserNo, String swipeType) {
        String message = String.format("{\"fromUserNo\": \"%s\", \"toUserNo\": \"%s\", \"swipeType\": \"%s\"}",
                fromUserNo, toUserNo, swipeType);
        kafkaTemplate.send(KafkaTopics.SWIPE_EVENTS, message);
        log.info("Kafka 메시지 전송 완료: {}", message);
    }
}