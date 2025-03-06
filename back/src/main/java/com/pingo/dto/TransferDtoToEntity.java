package com.pingo.dto;

import com.pingo.dto.swipe.SwipeRequest;
import com.pingo.entity.swipe.Swipe;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class TransferDtoToEntity {


    public Swipe swipeDtoToEntity(SwipeRequest swipeRequest) {
        return Swipe.builder()
                .toUserNo(swipeRequest.getToUserNo())
                .fromUserNo(swipeRequest.getFromUserNo())
                .swipeType(swipeRequest.getSwipeType())
                .swipeTime(LocalDateTime.now())
                .build();
    };

}
