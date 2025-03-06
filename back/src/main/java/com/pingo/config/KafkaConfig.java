package com.pingo.config;

import com.pingo.util.KafkaTopics;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class KafkaConfig {

    @Bean
    public NewTopic swipeTopic() {
        return new NewTopic(KafkaTopics.SWIPE_EVENTS, 3, (short) 1);  // ✅ 파티션 3개, 복제본 1개
    }

    @Bean
    public NewTopic matchTopic() {
        return new NewTopic(KafkaTopics.MATCH_EVENTS, 3, (short) 1);
    }
}
