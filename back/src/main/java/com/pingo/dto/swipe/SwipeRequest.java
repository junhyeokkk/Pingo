package com.pingo.dto.swipe;

import com.pingo.dto.TransferDtoToEntity;
import com.pingo.entity.swipe.Swipe;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class SwipeRequest {
    private String toUserNo; // 누구한테?
    private String fromUserNo; // 누가?
    private String swipeType; // PING, PANG, SUPERPING
    private String swipeState; // WAIT, MATCH, CANCEL

    @Override
    public String toString() {
        return "SwipeRequest{" +
                "toUserNo='" + toUserNo + '\'' +
                ", fromUserNo='" + fromUserNo + '\'' +
                ", swipeType='" + swipeType + '\'' +
                ", swipeState='" + swipeState + '\'' +
                '}';
    }


}
