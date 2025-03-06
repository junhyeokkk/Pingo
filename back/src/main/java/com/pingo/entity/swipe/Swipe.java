package com.pingo.entity.swipe;

import com.pingo.dto.swipe.SwipeRequest;
import com.pingo.exception.BusinessException;
import com.pingo.exception.ExceptionCode;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Swipe {
    private String swipeNo;
    private String toUserNo;
    private String fromUserNo;
    private String swipeType;
    private LocalDateTime swipeTime;
    private String swipeState;


    // from, to 유저 둘다 처음 스와이프 엔티티
    public Swipe(SwipeRequest swipeRequest) {
        this.swipeNo = createSwipeNo();
        this.toUserNo = swipeRequest.getToUserNo();
        this.fromUserNo = swipeRequest.getFromUserNo();
        this.swipeType = swipeRequest.getSwipeType();
        this.swipeTime = LocalDateTime.now();

    }

    // swipeNo 생성 로직 (중복 호출시 예외 처리)
    public String createSwipeNo() {
        if(this.swipeNo == null) {
            String uuid = UUID.randomUUID().toString();
            return "SW" + uuid.substring(0, 8);
        }else {
            throw new BusinessException(ExceptionCode.DUPLICATE_SWIPE_NO);
        }
    }

}
